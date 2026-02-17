#!/usr/bin/env bash
# Test dotfiles installation in a macOS VM via Tart
# Requires: brew install cirruslabs/cli/tart
# Usage: bash _test/vm-test-macos.sh [--interactive]
#
# How it works:
#   1. Clones a macOS Tahoe base image and resizes the disk to 250 GB
#   2. The guest daemon auto-resizes the APFS container on boot
#   3. Injects an SSH key via tart exec (no sshpass needed)
#   4. Installs Homebrew, links dotfiles, installs all packages
#   5. Validates core tools are working
#
# The base image (macos-tahoe-base) provides:
#   - Passwordless sudo for the admin user (pre-configured)
#   - Automatic APFS disk resize via the guest daemon
#   - tart exec support via the guest agent
set -euo pipefail

# Check prerequisites
if ! command -v tart &>/dev/null; then
  echo "ERROR: tart not found. Install with: brew install cirruslabs/cli/tart"
  exit 1
fi

VM_NAME="test-dotfiles-$(date +%s)"
IMAGE="ghcr.io/cirruslabs/macos-tahoe-base:latest"
DOTFILES="$HOME/.dotfiles"
INTERACTIVE=false
SSH_KEY="/tmp/tart-vm-key-$$"

for arg in "$@"; do
  case $arg in
    -i|--interactive) INTERACTIVE=true ;;
  esac
done

cleanup() {
  echo "==> Cleaning up..."
  tart stop "$VM_NAME" 2>/dev/null || true
  tart delete "$VM_NAME" 2>/dev/null || true
  rm -f "$SSH_KEY" "${SSH_KEY}.pub"
}
trap cleanup EXIT

echo "==> Cloning macOS VM..."
tart clone "$IMAGE" "$VM_NAME"

# The base image disk (~50 GB) is too small for all Homebrew packages + casks.
# Need ~170+ GB: macOS (~15 GB) + formulae (~18 GB) + cask apps (~53 GB)
# + download cache (~80 GB peak) + headroom.
# The guest daemon automatically resizes the APFS container on boot.
echo "==> Resizing VM disk to 250 GB..."
tart set "$VM_NAME" --disk-size 250

echo "==> Starting VM with dotfiles share..."
if $INTERACTIVE; then
  tart run --dir=dotfiles:"$DOTFILES":ro "$VM_NAME" &
else
  tart run --no-graphics --dir=dotfiles:"$DOTFILES":ro "$VM_NAME" &
fi

# Wait for VM to get an IP address
echo "==> Waiting for VM to boot..."
IP=""
for _ in $(seq 1 60); do
  IP=$(tart ip "$VM_NAME" 2>/dev/null || true)
  if [[ -n "$IP" ]]; then break; fi
  sleep 2
done

if [[ -z "$IP" ]]; then
  echo "ERROR: VM did not get IP after 120s"
  exit 1
fi

echo "==> VM ready at $IP"

# Set up SSH key auth to avoid sshpass entirely. sshpass has a fatal flaw:
# it watches for "assword:" in output, and any sudo or other prompt containing
# that pattern corrupts the session. Key-based SSH eliminates this problem.
echo "==> Setting up SSH key authentication..."
ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -q

# Wait for the guest agent to become available, then inject the public key.
echo "  Waiting for guest agent..."
for _ in $(seq 1 60); do
  if tart exec "$VM_NAME" true 2>/dev/null; then break; fi
  sleep 3
done
cat "${SSH_KEY}.pub" | tart exec -i "$VM_NAME" sh -c \
  'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys'

# SSH helper using key auth — no sshpass, no password prompts, no session corruption.
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
-o ConnectTimeout=10 -o ServerAliveInterval=30 -o ServerAliveCountMax=10"

ssh_run() {
  /usr/bin/ssh $SSH_OPTS "admin@$IP" "$1"
}

# Variant with pseudo-TTY for commands that need sudo (e.g. settings.sh
# starts with `sudo -v` which requires a terminal).
ssh_run_tty() {
  /usr/bin/ssh -t $SSH_OPTS "admin@$IP" "$1"
}

# Wait for SSH to become available
echo "==> Waiting for SSH..."
SSH_READY=false
for _ in $(seq 1 60); do
  if ssh_run true 2>/dev/null; then
    SSH_READY=true
    break
  fi
  sleep 3
done

if ! $SSH_READY; then
  echo "ERROR: SSH not available after 180s"
  exit 1
fi

# Wait for the guest daemon to finish auto-resizing the APFS container.
echo "==> Waiting for APFS auto-resize..."
for _ in $(seq 1 30); do
  AVAIL=$(ssh_run 'df -g / | awk "NR==2{print \$4}"' 2>/dev/null || echo 0)
  if [[ "$AVAIL" -gt 100 ]]; then break; fi
  sleep 5
done
ssh_run 'df -h /'

echo "==> Copying dotfiles into VM..."
ssh_run "cp -r '/Volumes/My Shared Files/dotfiles' ~/.dotfiles"

# Remove default dotfiles that ship with the base image so stow can
# create symlinks without conflicts (.zprofile, .zshrc, .gitconfig, etc.)
echo "==> Removing default dotfiles that conflict with stow..."
ssh_run 'rm -f ~/.zshrc ~/.zprofile ~/.zshenv ~/.gitconfig ~/.bash_profile ~/.bashrc'

# Run bootstrap steps inline (not bootstrap.sh, which git-pulls from origin
# and would overwrite the local changes we want to test)
echo "==> Installing Homebrew..."
ssh_run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' || true
ssh_run 'eval "$(/opt/homebrew/bin/brew shellenv)" && brew install just stow'

echo "==> Linking dotfiles..."
ssh_run 'eval "$(/opt/homebrew/bin/brew shellenv)" && cd ~/.dotfiles && just link'

# After linking, .zshenv sources .cargo/env which doesn't exist yet (rustup
# hasn't run). Create an empty placeholder so every subsequent SSH command
# doesn't print an error. rustup will populate it later.
ssh_run 'mkdir -p ~/.cargo && touch ~/.cargo/env'

# Install Homebrew packages in phases so failures are isolated and visible.
# Each phase uses --verbose so individual failures are visible in the log.
# MAS apps are excluded (require Apple ID login, not available in VMs).
BREW_ENV='eval "$(/opt/homebrew/bin/brew shellenv)" && cd ~/.dotfiles'

echo "==> Installing Homebrew taps..."
ssh_run "$BREW_ENV && grep -h '^tap ' brew/Brewfile.* | brew bundle --verbose --file=-"

echo "==> Installing Homebrew formulae..."
ssh_run "$BREW_ENV && grep -h '^brew ' brew/Brewfile.* | brew bundle --verbose --file=-" || {
  echo "  WARNING: Some formulae failed to install (continuing)..."
}

# Fix yarn link conflict: node installs yarn via npm, then the brew yarn
# bottle can't symlink over it. Force-link resolves it.
ssh_run 'eval "$(/opt/homebrew/bin/brew shellenv)" && brew link --overwrite yarn 2>/dev/null' || true

# Purge download cache to free disk space for cask downloads.
# Formulae downloads (~40 GB) are no longer needed after installation.
echo "==> Clearing Homebrew download cache..."
ssh_run 'eval "$(/opt/homebrew/bin/brew shellenv)" && brew cleanup --prune=all -s'
ssh_run 'rm -rf ~/Library/Caches/Homebrew/downloads ~/Library/Caches/Homebrew/Cask; \
  mkdir -p ~/Library/Caches/Homebrew/downloads ~/Library/Caches/Homebrew/Cask'
ssh_run 'df -h /'

echo "==> Installing Homebrew casks..."
ssh_run "$BREW_ENV && grep -h '^cask ' brew/Brewfile.* | brew bundle --verbose --file=-" || {
  echo "  WARNING: Some casks failed to install (continuing)..."
}

echo "==> Applying macOS defaults..."
ssh_run_tty "$BREW_ENV && just macos" || true

echo ""
echo "==> Validating installation..."
ERRORS=0

validate() {
  local desc="$1"
  shift
  if ssh_run "$1" 2>/dev/null; then
    echo "  OK: $desc"
  else
    echo "  FAIL: $desc"
    ERRORS=$((ERRORS + 1))
  fi
}

validate "nvim"      'eval "$(/opt/homebrew/bin/brew shellenv)" && nvim --version | head -1'
validate "starship"  'eval "$(/opt/homebrew/bin/brew shellenv)" && starship --version'
validate "tmux"      'eval "$(/opt/homebrew/bin/brew shellenv)" && tmux -V'
validate "lazygit"   'eval "$(/opt/homebrew/bin/brew shellenv)" && lazygit --version | head -1'
validate "symlinks"  'ls -la ~/.zshrc ~/.gitconfig'
validate "disk"      'df -h / | awk "NR==2 {avail=\$4+0; print \"Available: \" \$4; exit (avail < 5)}"'

echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo "==> $ERRORS validation(s) failed!"
else
  echo "==> All checks passed!"
fi

if $INTERACTIVE; then
  # Disable cleanup trap — user controls VM lifetime
  trap - EXIT
  echo ""
  echo "VM is running. Connect with:"
  echo "  ssh -i $SSH_KEY admin@$IP"
  echo "  Or use the Tart GUI window"
  echo ""
  echo "Press Enter to stop and delete the VM..."
  read -r
  cleanup
fi

exit "$ERRORS"

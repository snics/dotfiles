#!/usr/bin/env bash
# shellcheck disable=SC2016
# Test dotfiles installation in a Linux VM via Lima
# Requires: brew install lima
# Usage: bash _test/vm-test-linux.sh [ubuntu|fedora|debian] [--interactive]
#
# How it works:
#   1. Creates a Lima VM with the chosen distro template
#   2. Installs build prerequisites (build-essential, curl, git, etc.)
#   3. Copies local dotfiles into the VM (tests unpushed changes)
#   4. Installs Homebrew (Linuxbrew), links dotfiles, installs all packages
#   5. Validates core tools are working
#
# This mirrors the macOS VM test (vm-test-macos.sh) to ensure cross-platform
# parity. Casks and MAS entries are skipped (macOS-only). Formulae listed
# in brew/linux-exclude are filtered out.
set -euo pipefail

# Check prerequisites
if ! command -v limactl &>/dev/null; then
  echo "ERROR: lima not found. Install with: brew install lima"
  exit 1
fi

VM_NAME="test-dotfiles-$(date +%s)"
TEMPLATE="ubuntu"
INTERACTIVE=false
DOTFILES="$HOME/.dotfiles"

for arg in "$@"; do
  case $arg in
    -i|--interactive) INTERACTIVE=true ;;
    ubuntu|fedora|debian) TEMPLATE="$arg" ;;
  esac
done

cleanup() {
  echo "==> Cleaning up..."
  limactl stop "$VM_NAME" 2>/dev/null || true
  limactl delete -f "$VM_NAME" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Creating Lima VM ($TEMPLATE)..."
limactl create --name="$VM_NAME" --cpus=4 --memory=8 --disk=100 --vm-type=vz \
  "template://$TEMPLATE" --tty=false

echo "==> Starting VM..."
limactl start "$VM_NAME"

# Helper to run commands in the VM
lima_run() {
  limactl shell "$VM_NAME" -- bash -c "$1"
}

echo "==> Installing build prerequisites..."
# Homebrew on Linux needs: build-essential, procps, curl, file, git
# See: https://docs.brew.sh/Homebrew-on-Linux#requirements
lima_run '
  if command -v apt-get &>/dev/null; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq \
      && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
         build-essential procps curl file git stow
  elif command -v dnf &>/dev/null; then
    sudo dnf groupinstall -y "Development Tools" \
      && sudo dnf install -y procps-ng curl file git stow
  elif command -v apk &>/dev/null; then
    sudo apk add --no-cache build-base procps curl file git stow
  fi
'

# Copy local dotfiles into the VM so we test unpushed changes.
# Lima mounts the host home at the original path (e.g. /Users/<user>).
echo "==> Copying dotfiles into VM..."
lima_run "cp -r '$DOTFILES' ~/.dotfiles"

# Remove skeleton files that conflict with stow
echo "==> Removing default dotfiles that conflict with stow..."
lima_run '
  for f in .zshrc .bashrc .bash_logout .profile .zprofile .zshenv .gitconfig; do
    [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]] && rm -f "$HOME/$f" || true
  done
'

# Run bootstrap steps inline (not bootstrap.sh, which git-pulls from origin
# and would overwrite the local changes we want to test)
echo "==> Installing Homebrew (Linuxbrew)..."
lima_run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' || {
  echo "FATAL: Homebrew installation failed — cannot continue"
  exit 1
}

# Linuxbrew lives under /home/linuxbrew/.linuxbrew (not /opt/homebrew like macOS)
BREW_ENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

echo "==> Installing just and stow via Homebrew..."
lima_run "$BREW_ENV && brew install just stow"

echo "==> Linking dotfiles..."
lima_run "$BREW_ENV && cd ~/.dotfiles && just link-cli"

# After linking, .zshenv sources .cargo/env which doesn't exist yet (rustup
# hasn't run). Create an empty placeholder so subsequent commands don't error.
lima_run 'mkdir -p ~/.cargo && touch ~/.cargo/env'

# Install Homebrew packages in phases so failures are isolated and visible.
# Casks and MAS entries are macOS-only — only install taps and formulae.
# Formulae listed in brew/linux-exclude are filtered out.
BREW_CD="$BREW_ENV && cd ~/.dotfiles"

echo "==> Installing Homebrew taps..."
lima_run "$BREW_CD && grep -h '^tap ' brew/Brewfile.* | brew bundle --verbose --file=-"

echo "==> Installing Homebrew formulae (filtering linux-exclude)..."
# Extract formula names, skip those in linux-exclude, pass the rest to brew bundle.
lima_run "$BREW_CD"' && grep -h "^brew " brew/Brewfile.* | while IFS= read -r line; do
  pkg=$(echo "$line" | sed '\''s/brew "\([^"]*\)".*/\1/'\'')
  if grep -qxF "$pkg" brew/linux-exclude 2>/dev/null; then
    echo "  SKIP (linux-exclude): $pkg" >&2
  else
    echo "$line"
  fi
done | brew bundle --verbose --file=-' || {
  echo "  WARNING: Some formulae failed to install (continuing)..."
}

# Fix yarn link conflict (same as macOS — node installs yarn via npm,
# then the brew yarn bottle can't symlink over it)
lima_run "$BREW_ENV && brew link --overwrite yarn 2>/dev/null" || true

# Purge download cache to free disk space
echo "==> Clearing Homebrew download cache..."
lima_run "$BREW_ENV && brew cleanup --prune=all -s"
lima_run 'df -h /'

echo ""
echo "==> Validating installation..."
ERRORS=0

validate() {
  local desc="$1"
  shift
  if lima_run "$1" 2>/dev/null; then
    echo "  OK: $desc"
  else
    echo "  FAIL: $desc"
    ERRORS=$((ERRORS + 1))
  fi
}

validate "nvim"      "$BREW_ENV && nvim --version | head -1"
validate "starship"  "$BREW_ENV && starship --version"
validate "tmux"      "$BREW_ENV && tmux -V"
validate "lazygit"   "$BREW_ENV && lazygit --version | head -1"
validate "fzf"       "$BREW_ENV && fzf --version"
validate "bat"       "$BREW_ENV && bat --version"
validate "eza"       "$BREW_ENV && eza --version"
validate "zoxide"    "$BREW_ENV && zoxide --version"
validate "ripgrep"   "$BREW_ENV && rg --version | head -1"
validate "jq"        "$BREW_ENV && jq --version"
validate "symlinks"  'ls -la ~/.zshrc ~/.gitconfig'
validate "configs"   'for d in nvim tmux lazygit k9s; do [[ -d "$HOME/.config/$d" ]] || [[ -L "$HOME/.config/$d" ]] || exit 1; done'
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
  echo "  limactl shell $VM_NAME"
  echo ""
  echo "Press Enter to stop and delete the VM..."
  read -r
  cleanup
fi

exit "$ERRORS"

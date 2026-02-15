#!/usr/bin/env bash
# Test dotfiles installation in a macOS VM via Tart
# Requires: brew install cirruslabs/cli/tart sshpass
# Usage: bash _test/vm-test-macos.sh [--interactive]
set -euo pipefail

# Check prerequisites
for cmd in tart sshpass; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd not found. Install with: brew install $cmd"
    exit 1
  fi
done

VM_NAME="test-dotfiles-$(date +%s)"
IMAGE="ghcr.io/cirruslabs/macos-sequoia-base:latest"
DOTFILES="$HOME/.dotfiles"
INTERACTIVE=false

for arg in "$@"; do
  case $arg in
    -i|--interactive) INTERACTIVE=true ;;
  esac
done

cleanup() {
  echo "==> Cleaning up..."
  tart stop "$VM_NAME" 2>/dev/null || true
  tart delete "$VM_NAME" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Cloning macOS VM..."
tart clone "$IMAGE" "$VM_NAME"

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

# SSH helper (default credentials: admin/admin)
# Use /usr/bin/ssh — Homebrew's openssh has routing issues with Virtualization.framework
SSH="sshpass -p admin /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 admin@$IP"

# Wait for SSH to become available
echo "==> Waiting for SSH..."
SSH_READY=false
for _ in $(seq 1 60); do
  if $SSH true 2>/dev/null; then
    SSH_READY=true
    break
  fi
  sleep 3
done

if ! $SSH_READY; then
  echo "ERROR: SSH not available after 180s"
  exit 1
fi

echo "==> Copying dotfiles into VM..."
$SSH "cp -r /Volumes/My\ Shared\ Files/dotfiles ~/.dotfiles"

echo "==> Running bootstrap..."
$SSH "cd ~/.dotfiles && bash bootstrap.sh"

echo ""
echo "==> Validating installation..."
ERRORS=0

validate() {
  local desc="$1"
  shift
  if $SSH "$@" 2>/dev/null; then
    echo "  OK: $desc"
  else
    echo "  FAIL: $desc"
    ERRORS=$((ERRORS + 1))
  fi
}

validate "nvim"      'source ~/.zshrc 2>/dev/null; nvim --version | head -1'
validate "starship"  'source ~/.zshrc 2>/dev/null; starship --version'
validate "tmux"      'source ~/.zshrc 2>/dev/null; tmux -V'
validate "lazygit"   'source ~/.zshrc 2>/dev/null; lazygit --version | head -1'
validate "symlinks"  'ls -la ~/.zshrc ~/.gitconfig'

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
  echo "  ssh admin@$IP  (password: admin)"
  echo "  Or use the Tart GUI window"
  echo ""
  echo "Press Enter to stop and delete the VM..."
  read -r
  cleanup
fi

exit "$ERRORS"

#!/usr/bin/env bash
# Test dotfiles installation in a Linux VM via Lima
# Requires: brew install lima
# Usage: bash _test/vm-test-linux.sh [ubuntu|fedora|debian] [--interactive]
set -euo pipefail

VM_NAME="test-dotfiles-$(date +%s)"
TEMPLATE="ubuntu"
INTERACTIVE=false

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
limactl create --name="$VM_NAME" --cpus=2 --memory=4 --vm-type=vz \
  "template://$TEMPLATE" --tty=false

echo "==> Starting VM..."
limactl start "$VM_NAME"

echo "==> Installing prerequisites..."
# shellcheck disable=SC2016
limactl shell "$VM_NAME" -- bash -c '
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq stow git curl make
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y -q stow git curl make
  elif command -v apk &>/dev/null; then
    sudo apk add --no-cache stow git curl make
  fi
'

echo "==> Installing dotfiles..."
# shellcheck disable=SC2016
limactl shell "$VM_NAME" -- bash -c '
  if [[ -d "$HOME/.dotfiles" ]]; then
    cd "$HOME/.dotfiles"
  else
    git clone https://github.com/snics/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"
  fi

  # Remove skeleton files that conflict with stow
  for f in .zshrc .bashrc .bash_logout .profile; do
    [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]] && rm -f "$HOME/$f"
  done

  echo "==> Linking CLI configs..."
  stow --restow -t "$HOME" zsh git nvim tmux lazygit k9s opencode claude
'

echo ""
echo "==> Validating installation..."
# shellcheck disable=SC2016
RESULT=$(limactl shell "$VM_NAME" -- bash -c '
  ERRORS=0

  echo "Symlinks:"
  for f in ~/.zshrc ~/.gitconfig; do
    if [[ -L "$f" ]]; then
      echo "  OK: $f -> $(readlink "$f")"
    else
      echo "  MISSING: $f"
      ERRORS=$((ERRORS + 1))
    fi
  done

  echo ""
  echo "Config dirs:"
  for d in nvim tmux lazygit k9s; do
    target="$HOME/.config/$d"
    if [[ -d "$target" ]] || [[ -L "$target" ]]; then
      echo "  OK: .config/$d"
    else
      echo "  MISSING: .config/$d"
      ERRORS=$((ERRORS + 1))
    fi
  done

  exit "$ERRORS"
') && ERRORS=0 || ERRORS=$?
echo "$RESULT"

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

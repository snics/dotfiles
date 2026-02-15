#!/usr/bin/env bash
# Validate all stow package symlinks (dry-run)
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CLI_PACKAGES="zsh git nvim tmux lazygit k9s opencode claude"
GUI_PACKAGES="ghostty zed cursor obsidian"
ALL_PACKAGES="$CLI_PACKAGES $GUI_PACKAGES"

errors=0
for pkg in $ALL_PACKAGES; do
  if cd "$DOTFILES" && stow --simulate --restow -t "$HOME" "$pkg" 2>&1 | grep -q "ERROR"; then
    echo "  FAIL: $pkg"
    stow --simulate --restow -t "$HOME" "$pkg" 2>&1 | head -5
    errors=$((errors + 1))
  else
    echo "  OK: $pkg"
  fi
done

if [ "$errors" -gt 0 ]; then
  echo ""
  echo "$errors package(s) failed."
  exit 1
fi
echo "All stow packages OK."

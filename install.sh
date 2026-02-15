#!/usr/bin/env bash
# Dotfiles installer — cross-platform entry point
#
# Called automatically by GitHub Codespaces, DevPod, and VS Code Dev Containers
# when this repo is configured as a dotfiles repository.
#
# Scenarios:
#   macOS (native)     → delegates to just all / make all (full setup)
#   Container/Linux    → installs stow, links CLI configs only (~5 seconds)
#
# Preferred usage:
#   just all          (if just is installed)
#   make all          (universal fallback)
#   ./install.sh      (backwards compatibility + container auto-detection)
#
# First-time macOS setup from scratch:
#   curl -fsSL https://raw.githubusercontent.com/snics/dotfiles/master/bootstrap.sh | bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

# ── Platform detection ──────────────────────────────────
source "$DOTFILES/_lib/platform.sh"

# ── CLI packages (linked in all environments) ──────────
CLI_PACKAGES="zsh git nvim tmux lazygit k9s opencode claude"

# ── Container fast-path ─────────────────────────────────
# Codespaces, DevPod, VS Code Dev Containers, or plain Docker:
# Skip Homebrew and macOS settings — just stow CLI configs.
if $IS_CONTAINER; then
    echo "==> Container detected (codespaces=$IS_CODESPACES devpod=$IS_DEVPOD)"
    echo "==> Installing dotfiles as flavor..."

    # Ensure stow is available
    if ! command -v stow &>/dev/null; then
        echo "==> Installing stow..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y -qq stow
        elif command -v apk &>/dev/null; then
            sudo apk add --no-cache stow
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y -q stow
        else
            echo "Warning: Cannot install stow — unknown package manager"
            exit 1
        fi
    fi

    # Link CLI-only packages
    echo "==> Linking CLI configs..."
    # shellcheck disable=SC2086
    stow --restow -t "$HOME" $CLI_PACKAGES
    echo "==> Dotfiles installed. Open a new shell to apply changes."
    exit 0
fi

# ── macOS / native Linux ────────────────────────────────
# Full setup via justfile or Makefile
if command -v just &>/dev/null; then
    echo "==> Running: just all"
    just all
elif command -v make &>/dev/null; then
    echo "==> just not found, falling back to: make all"
    make all
else
    echo "Error: Neither just nor make found. Run bootstrap.sh first:"
    echo "  curl -fsSL https://raw.githubusercontent.com/snics/dotfiles/master/bootstrap.sh | bash"
    exit 1
fi

#!/usr/bin/env bash
# Dotfiles bootstrap — curl-pipeable first-run script
# Usage: curl -fsSL https://raw.githubusercontent.com/snics/dotfiles/master/bootstrap.sh | bash
#
# What this does:
#   1. Install Xcode Command Line Tools (if missing)
#   2. Install Homebrew (if missing)
#   3. Clone dotfiles to ~/.dotfiles (if missing)
#   4. Install just + stow via Homebrew
#   5. Hand off to: just all

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
REPO="https://github.com/snics/dotfiles.git"

echo "==> Bootstrapping dotfiles..."

# ── 1. Xcode Command Line Tools ────────────────────────
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "    Waiting for Xcode CLT installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi

# ── 2. Homebrew ─────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── 3. Clone dotfiles ──────────────────────────────────
if [[ ! -d "$DOTFILES" ]]; then
    echo "==> Cloning dotfiles..."
    git clone "$REPO" "$DOTFILES"
else
    echo "==> Dotfiles already cloned at $DOTFILES"
    cd "$DOTFILES" && git pull --ff-only || true
fi

# ── 4. Core tools ──────────────────────────────────────
echo "==> Installing just + stow..."
brew install just stow

# ── 5. Hand off to just ────────────────────────────────
echo "==> Running full setup..."
cd "$DOTFILES"
just all

echo ""
echo "==> Bootstrap complete! Open a new shell to apply changes."

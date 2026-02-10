#!/usr/bin/env bash
# Dotfiles installer — thin wrapper around justfile
#
# Preferred usage:
#   just all          (if just is installed)
#   make all          (universal fallback)
#   ./install.sh      (backwards compatibility)
#
# First-time setup from scratch:
#   curl -fsSL https://raw.githubusercontent.com/snics/dotfiles/master/bootstrap.sh | bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Prefer just, fall back to make
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

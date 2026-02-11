# Dotfiles — https://github.com/snics/dotfiles
# Usage: just <target>
# List all targets: just --list

set shell := ["bash", "-cu"]

DOTFILES := env_var("HOME") / ".dotfiles"

# Stow package lists

HOME_PACKAGES := "zsh git"
CONFIG_PACKAGES := "nvim ghostty tmux lazygit k9s zed opencode claude cursor"
ALL_PACKAGES := HOME_PACKAGES + " " + CONFIG_PACKAGES

# ── Full Setup ──────────────────────────────────────────

# Full setup: brew + link + macos
all: install link macos
    @echo "Done! Open a new shell to apply changes."

# ── Install ─────────────────────────────────────────────

# Install Homebrew and all packages from Brewfile
install:
    @echo "==> Installing Homebrew packages..."
    @if ! command -v brew &>/dev/null; then \
        /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
        eval "$$(/opt/homebrew/bin/brew shellenv)"; \
    fi
    cat {{ DOTFILES }}/brew/Brewfile.* | brew bundle --file=-

# ── Link / Unlink ──────────────────────────────────────

# Symlink all stow packages (idempotent)
link:
    @echo "==> Linking dotfiles..."
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" {{ ALL_PACKAGES }}

# Remove all symlinks
unlink:
    @echo "==> Unlinking dotfiles..."
    @cd {{ DOTFILES }} && stow --delete -t "$HOME" {{ ALL_PACKAGES }}

# Re-link all packages (alias for link)
relink: link

# ── Per-Package ─────────────────────────────────────────

# Link zsh config
zsh:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" zsh

# Link git config
git:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" git

# Link nvim config
nvim:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" nvim

# Link ghostty config
ghostty:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" ghostty

# Link tmux config
tmux:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" tmux

# Link lazygit config
lazygit:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" lazygit

# Link k9s config
k9s:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" k9s

# Link zed config
zed:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" zed

# Link opencode config
opencode:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" opencode

# Link claude config
claude:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" claude

# Link cursor config
cursor:
    @cd {{ DOTFILES }} && stow --restow -t "$HOME" cursor

# ── Updates ─────────────────────────────────────────────

# Update Homebrew packages
update:
    brew update
    brew upgrade
    brew cleanup

# ── Brew Lifecycle ──────────────────────────────────────

# Regenerate ~/.Brewfile from split sources
brew-gen:
    cat {{ DOTFILES }}/brew/Brewfile.* > ~/.Brewfile
    @echo "Generated ~/.Brewfile from $(ls -1 {{ DOTFILES }}/brew/Brewfile.* | wc -l | tr -d ' ') sources"

# Install all packages from split Brewfiles
brew-install: brew-gen
    brew bundle --file=~/.Brewfile

# List all packages from split Brewfiles
brew-list:
    cat {{ DOTFILES }}/brew/Brewfile.* | brew bundle list --file=-

# Check which packages are not installed
brew-check: brew-gen
    brew bundle check --file=~/.Brewfile

# Remove packages not in Brewfile (dry-run first)
brew-cleanup: brew-gen
    brew bundle cleanup --file=~/.Brewfile

# Force-remove packages not in Brewfile
brew-cleanup-force: brew-gen
    brew bundle cleanup --force --file=~/.Brewfile

# Dump currently installed packages to a temp file for comparison
brew-dump:
    brew bundle dump --describe --file={{ DOTFILES }}/brew/Brewfile.dump --force
    @echo "Dumped to brew/Brewfile.dump — compare with Brewfile.* sources"

# Edit split Brewfiles (opens directory)
brew-edit:
    @echo "Split Brewfiles in {{ DOTFILES }}/brew/"
    @ls -1 {{ DOTFILES }}/brew/Brewfile.*
    @echo ""
    @echo "Edit with: \$$EDITOR {{ DOTFILES }}/brew/Brewfile.<category>"

# ── macOS ───────────────────────────────────────────────

# Apply macOS system settings and dock
[macos]
macos:
    @if [[ "$${CI:-}" != "true" ]]; then \
        echo "==> Applying macOS settings..."; \
        source {{ DOTFILES }}/macOS/settings.sh; \
        source {{ DOTFILES }}/macOS/dock.sh; \
    else \
        echo "==> Skipping macOS settings (CI mode)"; \
    fi

# Configure dock apps
[macos]
dock:
    source {{ DOTFILES }}/macOS/dock.sh

# Create development project folder structure
[macos]
project-folders:
    source {{ DOTFILES }}/macOS/project-folder-structure.sh

# ── Optional Dev Tools ──────────────────────────────────

# Install Go via g version manager
golang:
    source {{ DOTFILES }}/_install/golang.sh

# Install Rust via rustup
rust:
    source {{ DOTFILES }}/_install/rust.sh

# Install asdf plugins
asdf:
    source {{ DOTFILES }}/asdf/plugins.sh

# ── Validation ──────────────────────────────────────────

# Check installed tools and symlinks
check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Checking stow symlinks..."
    errors=0
    for pkg in {{ ALL_PACKAGES }}; do
        if cd {{ DOTFILES }} && stow --simulate --restow -t "$HOME" "$pkg" 2>&1 | grep -q "ERROR"; then
            echo "  FAIL: $pkg"
            errors=$((errors + 1))
        else
            echo "  OK: $pkg"
        fi
    done
    echo ""
    echo "==> Checking key tools..."
    for tool in brew stow nvim git tmux zsh starship fzf bat eza rg fd lazygit k9s kubectl helm op just; do
        if command -v "$tool" &>/dev/null; then
            echo "  OK: $tool"
        else
            echo "  MISSING: $tool"
            errors=$((errors + 1))
        fi
    done
    if [[ $errors -gt 0 ]]; then
        echo ""
        echo "$errors issue(s) found."
        exit 1
    else
        echo ""
        echo "All checks passed."
    fi

# ── Docker ──────────────────────────────────────────────

# Build all Docker images (local arch)
docker-build: docker-build-nvim docker-build-devenv docker-build-web

# Build snics/nvim image
docker-build-nvim:
    docker build -f _images/nvim/Dockerfile -t snics/nvim:latest .

# Build snics/devenv image
docker-build-devenv:
    docker build -f _images/devenv/Dockerfile -t snics/devenv:latest .

# Build snics/devenv-web image
docker-build-web:
    docker build -f _images/devenv-web/Dockerfile -t snics/devenv-web:latest .

# Smoke test all Docker images
docker-test:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Testing snics/nvim..."
    docker run --rm snics/nvim:latest --version | head -1
    docker run --rm snics/nvim:latest --headless -c 'lua print("Plugins: " .. #require("lazy").plugins())' +qa 2>&1
    echo ""
    echo "==> Testing snics/devenv..."
    docker run --rm snics/devenv:latest -c 'starship --version | head -1 && lazygit --version | head -1 && delta --version && tmux -V && nvim --version | head -1'
    echo ""
    echo "==> Testing snics/devenv-web..."
    docker run --rm --entrypoint ttyd snics/devenv-web:latest --version
    echo ""
    echo "All Docker tests passed."

# Run interactive devenv with current directory mounted
docker-run:
    docker run -it --rm -v "$(pwd):/workspace" snics/devenv:latest

# Start devenv-web on port 7681
docker-run-web:
    docker run -it --rm -p 7681:7681 snics/devenv-web:latest

# Multi-arch build + push to Docker Hub
docker-push:
    docker buildx build --platform linux/amd64,linux/arm64 -f _images/nvim/Dockerfile -t snics/nvim:latest --push .
    docker buildx build --platform linux/amd64,linux/arm64 -f _images/devenv/Dockerfile -t snics/devenv:latest --push .
    docker buildx build --platform linux/amd64,linux/arm64 -f _images/devenv-web/Dockerfile -t snics/devenv-web:latest --push .

# Lint Dockerfiles with hadolint
docker-lint:
    hadolint _images/nvim/Dockerfile _images/devenv/Dockerfile _images/devenv-web/Dockerfile

# Analyze Docker image layers with dive
docker-dive image="snics/nvim:latest":
    dive {{ image }}

# CI-mode dive analysis (fails on inefficiency thresholds)
docker-dive-ci:
    CI=true dive snics/nvim:latest
    CI=true dive snics/devenv:latest
    CI=true dive snics/devenv-web:latest

# ── Validation ──────────────────────────────────────────

# Lint shell scripts
lint:
    shellcheck _install/*.sh macOS/*.sh bootstrap.sh install.sh

# Dry-run stow for all packages (no changes)
test: lint
    @echo "==> Dry-run stow simulation..."
    @cd {{ DOTFILES }} && stow --simulate --restow -t "$HOME" {{ ALL_PACKAGES }} 2>&1
    @echo "All tests passed."

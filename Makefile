# Dotfiles — https://github.com/snics/dotfiles
# Usage: make <target>
# List all targets: make help
#
# This Makefile mirrors the justfile. Both must stay in sync.
# The justfile is the primary interface; this is the universal fallback.

SHELL := /bin/bash
DOTFILES := $(HOME)/.dotfiles

HOME_PACKAGES := zsh git
CONFIG_PACKAGES := nvim ghostty tmux lazygit k9s zed opencode claude cursor
ALL_PACKAGES := $(HOME_PACKAGES) $(CONFIG_PACKAGES)

.PHONY: all install link unlink relink update macos dock project-folders \
        golang rust asdf check lint test help \
        zsh git nvim ghostty tmux lazygit k9s zed opencode claude cursor

# ── Full Setup ──────────────────────────────────────────

all: install link macos ## Full setup: brew + link + macos
	@echo "Done! Open a new shell to apply changes."

# ── Install ─────────────────────────────────────────────

install: ## Install Homebrew and all packages from Brewfile
	@echo "==> Installing Homebrew packages..."
	@if ! command -v brew &>/dev/null; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		eval "$$(/opt/homebrew/bin/brew shellenv)"; \
	fi
	brew bundle --file=$(DOTFILES)/brew/Brewfile

# ── Link / Unlink ──────────────────────────────────────

link: ## Symlink all stow packages (idempotent)
	@echo "==> Linking dotfiles..."
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" $(ALL_PACKAGES)

unlink: ## Remove all symlinks
	@echo "==> Unlinking dotfiles..."
	@cd $(DOTFILES) && stow --delete -t "$(HOME)" $(ALL_PACKAGES)

relink: link ## Re-link all packages

# ── Per-Package ─────────────────────────────────────────

zsh: ## Link zsh config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" zsh

git: ## Link git config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" git

nvim: ## Link nvim config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" nvim

ghostty: ## Link ghostty config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" ghostty

tmux: ## Link tmux config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" tmux

lazygit: ## Link lazygit config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" lazygit

k9s: ## Link k9s config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" k9s

zed: ## Link zed config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" zed

opencode: ## Link opencode config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" opencode

claude: ## Link claude config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" claude

cursor: ## Link cursor config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" cursor

# ── Updates ─────────────────────────────────────────────

update: ## Update Homebrew packages
	brew update
	brew upgrade
	brew cleanup

# ── macOS ───────────────────────────────────────────────

macos: ## Apply macOS system settings and dock
	@if [[ "$${CI:-}" != "true" ]]; then \
		echo "==> Applying macOS settings..."; \
		source $(DOTFILES)/macOS/settings.sh; \
		source $(DOTFILES)/macOS/dock.sh; \
	else \
		echo "==> Skipping macOS settings (CI mode)"; \
	fi

dock: ## Configure dock apps
	source $(DOTFILES)/macOS/dock.sh

project-folders: ## Create development project folder structure
	source $(DOTFILES)/macOS/project-folder-structure.sh

# ── Optional Dev Tools ──────────────────────────────────

golang: ## Install Go via g version manager
	source $(DOTFILES)/_install/golang.sh

rust: ## Install Rust via rustup
	source $(DOTFILES)/_install/rust.sh

asdf: ## Install asdf plugins
	source $(DOTFILES)/asdf/plugins.sh

# ── Validation ──────────────────────────────────────────

check: ## Check installed tools and symlinks
	@echo "==> Checking stow symlinks..."
	@errors=0; \
	for pkg in $(ALL_PACKAGES); do \
		if cd $(DOTFILES) && stow --simulate --restow -t "$(HOME)" "$$pkg" 2>&1 | grep -q "ERROR"; then \
			echo "  FAIL: $$pkg"; \
			errors=$$((errors + 1)); \
		else \
			echo "  OK: $$pkg"; \
		fi; \
	done; \
	echo ""; \
	echo "==> Checking key tools..."; \
	for tool in brew stow nvim git tmux zsh starship fzf bat eza rg fd lazygit k9s kubectl helm op just; do \
		if command -v "$$tool" &>/dev/null; then \
			echo "  OK: $$tool"; \
		else \
			echo "  MISSING: $$tool"; \
			errors=$$((errors + 1)); \
		fi; \
	done; \
	if [[ $$errors -gt 0 ]]; then \
		echo ""; \
		echo "$$errors issue(s) found."; \
		exit 1; \
	else \
		echo ""; \
		echo "All checks passed."; \
	fi

lint: ## Lint shell scripts
	shellcheck _install/*.sh macOS/*.sh bootstrap.sh install.sh

test: lint ## Run lint + stow dry-run
	@echo "==> Dry-run stow simulation..."
	@cd $(DOTFILES) && stow --simulate --restow -t "$(HOME)" $(ALL_PACKAGES) 2>&1
	@echo "All tests passed."

# ── Help ────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

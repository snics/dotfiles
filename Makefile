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
        golang rust asdf check lint test test-symlinks test-configs help \
        zsh git nvim ghostty tmux lazygit k9s zed opencode claude cursor \
        brew-gen brew-install brew-list brew-check brew-cleanup \
        brew-cleanup-force brew-dump brew-edit \
        docker-build docker-build-nvim docker-build-devenv docker-build-web-terminal docker-build-web-desktop \
        docker-test docker-run docker-run-web-terminal docker-run-web-terminal-tmux docker-run-web-terminal-nvim \
        docker-run-web-desktop docker-push docker-lint \
        docker-dive-ci

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
	cat $(DOTFILES)/brew/Brewfile.* | brew bundle --file=-

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

# ── Brew Lifecycle ──────────────────────────────────────

brew-gen: ## Regenerate ~/.Brewfile from split sources
	cat $(DOTFILES)/brew/Brewfile.* > ~/.Brewfile
	@echo "Generated ~/.Brewfile from $$(ls -1 $(DOTFILES)/brew/Brewfile.* | wc -l | tr -d ' ') sources"

brew-install: brew-gen ## Install all packages from split Brewfiles
	brew bundle --file=~/.Brewfile

brew-list: ## List all packages from split Brewfiles
	cat $(DOTFILES)/brew/Brewfile.* | brew bundle list --file=-

brew-check: brew-gen ## Check which packages are not installed
	brew bundle check --file=~/.Brewfile

brew-cleanup: brew-gen ## Remove packages not in Brewfile (dry-run)
	brew bundle cleanup --file=~/.Brewfile

brew-cleanup-force: brew-gen ## Force-remove packages not in Brewfile
	brew bundle cleanup --force --file=~/.Brewfile

brew-dump: ## Dump installed packages for comparison
	brew bundle dump --describe --file=$(DOTFILES)/brew/Brewfile.dump --force
	@echo "Dumped to brew/Brewfile.dump — compare with Brewfile.* sources"

brew-edit: ## Edit split Brewfiles (shows directory)
	@echo "Split Brewfiles in $(DOTFILES)/brew/"
	@ls -1 $(DOTFILES)/brew/Brewfile.*
	@echo ""
	@echo "Edit with: $$EDITOR $(DOTFILES)/brew/Brewfile.<category>"

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

# ── Docker ──────────────────────────────────────────────

docker-build: docker-build-nvim docker-build-devenv docker-build-web-terminal docker-build-web-desktop ## Build all Docker images

docker-build-nvim: ## Build snic/nvim image
	docker build -f _images/nvim/Dockerfile -t snic/nvim:latest .

docker-build-devenv: ## Build snic/devenv image
	docker build -f _images/devenv/Dockerfile -t snic/devenv:latest .

docker-build-web-terminal: ## Build snic/devenv-web-terminal image
	docker build -t snic/devenv-web-terminal:latest _images/devenv-web-terminal

docker-build-web-desktop: ## Build snic/devenv-web-desktop image
	docker build -t snic/devenv-web-desktop:latest _images/devenv-web-desktop

docker-test: ## Smoke test all Docker images
	@echo "==> Testing snic/nvim..."
	@docker run --rm snic/nvim:latest --version | head -1
	@docker run --rm snic/nvim:latest --headless -c 'lua print("Plugins: " .. #require("lazy").plugins())' +qa 2>&1
	@echo ""
	@echo "==> Testing snic/devenv..."
	@docker run --rm snic/devenv:latest -c 'starship --version | head -1 && lazygit --version | head -1 && delta --version && tmux -V && nvim --version | head -1'
	@echo ""
	@echo "==> Testing snic/devenv-web-terminal..."
	@docker run --rm --entrypoint ttyd snic/devenv-web-terminal:latest --version
	@echo ""
	@echo "==> Testing snic/devenv-web-desktop..."
	@docker run --rm --entrypoint /opt/selkies/bin/selkies snic/devenv-web-desktop:latest --help 2>&1 | head -1
	@docker run --rm --entrypoint supervisord snic/devenv-web-desktop:latest --version
	@echo ""
	@echo "All Docker tests passed."

docker-run: ## Run interactive devenv with current directory mounted
	docker run -it --rm -v "$$(pwd):/home/developer/workspace" snic/devenv:latest

docker-run-web-terminal: ## Start devenv-web-terminal on port 7681 (default: terminal)
	docker run -it --rm -p 7681:7681 -v "$$(pwd):/home/developer/workspace" snic/devenv-web-terminal:latest

docker-run-web-terminal-tmux: ## Start devenv-web-terminal with tmux
	docker run -it --rm -p 7681:7681 -v "$$(pwd):/home/developer/workspace" -e TTYD_MODE=tmux snic/devenv-web-terminal:latest

docker-run-web-terminal-nvim: ## Start devenv-web-terminal with NeoVim
	docker run -it --rm -p 7681:7681 -v "$$(pwd):/home/developer/workspace" -e TTYD_MODE=nvim snic/devenv-web-terminal:latest

docker-run-web-desktop: ## Start devenv-web-desktop on port 3000
	docker run --rm -p 3000:3000 --shm-size=256m snic/devenv-web-desktop:latest

docker-push: ## Multi-arch build + push to Docker Hub
	docker buildx build --platform linux/amd64,linux/arm64 -f _images/nvim/Dockerfile -t snic/nvim:latest --push .
	docker buildx build --platform linux/amd64,linux/arm64 -f _images/devenv/Dockerfile -t snic/devenv:latest --push .
	docker buildx build --platform linux/amd64,linux/arm64 -t snic/devenv-web-terminal:latest --push _images/devenv-web-terminal
	docker buildx build --platform linux/amd64,linux/arm64 -t snic/devenv-web-desktop:latest --push _images/devenv-web-desktop

docker-lint: ## Lint Dockerfiles with hadolint
	hadolint _images/nvim/Dockerfile _images/devenv/Dockerfile _images/devenv-web-terminal/Dockerfile _images/devenv-web-desktop/Dockerfile

docker-dive-ci: ## CI-mode dive analysis (fails on inefficiency)
	CI=true dive snic/nvim:latest
	CI=true dive snic/devenv:latest
	CI=true dive snic/devenv-web-terminal:latest
	CI=true dive snic/devenv-web-desktop:latest

# ── Validation ──────────────────────────────────────────

lint: ## Lint shell scripts
	shellcheck _install/*.sh _macOS/*.sh bootstrap.sh install.sh

test-symlinks: ## Validate stow symlinks (dry-run)
	@bash _test/validate-symlinks.sh

test-configs: ## Validate JSON and TOML config syntax
	@bash _test/validate-configs.sh

test: lint test-symlinks test-configs ## Run all validation checks
	@echo "All tests passed."

# ── Help ────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

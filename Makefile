# Dotfiles — https://github.com/snics/dotfiles
# Usage: make <target>
# List all targets: make help
#
# This Makefile mirrors the justfile. Both must stay in sync.
# The justfile is the primary interface; this is the universal fallback.

SHELL := /bin/bash
DOTFILES := $(HOME)/.dotfiles

# Stow package lists (CLI = universal, GUI = macOS only)
CLI_PACKAGES := zsh git nvim tmux lazygit k9s tuicr hunk worktrunk herdr opencode claude
GUI_PACKAGES := ghostty zed cursor obsidian
ALL_PACKAGES := $(CLI_PACKAGES) $(GUI_PACKAGES)

.PHONY: all install link link-cli link-gui unlink relink update macos dock project-folders \
        golang rust cargo-tools cargo-tools-update cargo-dump clauth clauth-sync asdf \
        herdr-plugins herdr-plugins-update herdr-plugins-restore check lint test test-symlinks test-configs help \
        zsh git nvim ghostty tmux lazygit k9s tuicr hunk hunk-skill worktrunk worktrunk-plugins wt-issue-skill herdr zed opencode claude cursor obsidian \
        brew-gen brew-install brew-tap brew-trust brew-list brew-check brew-cleanup \
        brew-cleanup-force brew-dump brew-edit \
        docker-build docker-build-nvim docker-build-devenv docker-build-web-terminal docker-build-web-desktop \
        docker-test docker-run docker-run-web-terminal docker-run-web-terminal-tmux docker-run-web-terminal-nvim \
        docker-run-web-desktop docker-push docker-lint \
        docker-dive docker-dive-ci \
        test-macos test-macos-gui test-linux test-linux-gui vm-clean

# ── Full Setup ──────────────────────────────────────────

all: install link macos ## Full setup: brew + link + macos (macOS settings skipped on Linux)
	@echo "Done! Open a new shell to apply changes."

# ── Install ─────────────────────────────────────────────

install: ## Install Homebrew and all packages from Brewfile
	@echo "==> Installing Homebrew packages..."
	@if ! command -v brew &>/dev/null; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		if [ -f "/opt/homebrew/bin/brew" ]; then \
			eval "$$(/opt/homebrew/bin/brew shellenv)"; \
		elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then \
			eval "$$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		fi; \
	fi
	cat $(DOTFILES)/brew/Brewfile.* | brew bundle --file=-

# ── Link / Unlink ──────────────────────────────────────

link: link-cli link-gui ## Symlink all stow packages (CLI on all platforms, GUI on macOS only)

link-cli: ## Symlink CLI packages (universal)
	@echo "==> Linking CLI dotfiles..."
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" $(CLI_PACKAGES)

link-gui: ## Symlink GUI packages (macOS only)
	@if [[ "$$(uname -s)" == "Darwin" ]]; then \
		echo "==> Linking GUI dotfiles..."; \
		cd $(DOTFILES) && stow --restow -t "$(HOME)" $(GUI_PACKAGES); \
	else \
		echo "==> Skipping GUI dotfiles (not macOS)"; \
	fi

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

tuicr: ## Link tuicr config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" tuicr

hunk: ## Link hunk config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" hunk

hunk-skill: ## Register Hunk's hunk-review skill for Claude Code and Codex
	bash $(DOTFILES)/_install/hunk-skill.sh

worktrunk: ## Link worktrunk (wt) config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" worktrunk

worktrunk-plugins: ## Install Worktrunk's Claude Code plugin + Codex marketplace
	yes | wt config plugins claude install
	yes | wt config plugins codex install

wt-issue-skill: ## Register the wt-issue skill (GitLab issue → worktree) for Claude Code and Codex
	bash $(DOTFILES)/_install/wt-issue-skill.sh

herdr: ## Link herdr config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" herdr

zed: ## Link zed config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" zed

opencode: ## Link opencode config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" opencode

claude: ## Link claude config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" claude

claude-sync: ## Sync live ~/.claude/settings.json back into the repo (strips autoMode.environment)
	@jq 'del(.autoMode.environment)' "$(HOME)/.claude/settings.json" > $(DOTFILES)/claude/.claude/settings.json
	@echo "Synced ~/.claude/settings.json -> repo (autoMode.environment stripped)."
	@echo "Review the diff and commit."

clauth-sync: ## Sync live ~/.clauth/profiles.toml back into the repo
	@cp "$(HOME)/.clauth/profiles.toml" $(DOTFILES)/clauth/.clauth/profiles.toml
	@echo "Synced ~/.clauth/profiles.toml -> repo. Review the diff and commit."

cursor: ## Link cursor config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" cursor

obsidian: ## Link obsidian config
	@cd $(DOTFILES) && stow --restow -t "$(HOME)" obsidian

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
	$(MAKE) brew-tap
	$(MAKE) brew-trust
	brew bundle --file=~/.Brewfile

brew-tap: ## Tap all repositories declared in Brewfile.00-taps (prerequisite for trusting)
	grep -hoE '^tap "[^"]+"' $(DOTFILES)/brew/Brewfile.00-taps | sed -E 's/tap "([^"]+)"/\1/' | xargs -L1 brew tap
	@echo "Tapped all repositories from Brewfile.00-taps"

brew-trust: ## Trust all non-official taps (Homebrew 6.0+ tap-trust requirement)
	brew tap | grep -vE '^homebrew/' | xargs brew trust --tap
	@echo "Trusted all non-homebrew taps"

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
	@if [[ "$$(uname -s)" != "Darwin" ]]; then \
		echo "==> Skipping macOS settings (not macOS)"; \
	elif [[ "$${CI:-}" != "true" ]]; then \
		echo "==> Applying macOS settings..."; \
		source $(DOTFILES)/_macOS/settings.sh; \
		source $(DOTFILES)/_macOS/dock.sh; \
	else \
		echo "==> Skipping macOS settings (CI mode)"; \
	fi

dock: ## Configure dock apps
	source $(DOTFILES)/_macOS/dock.sh

project-folders: ## Create development project folder structure
	source $(DOTFILES)/_macOS/project-folder-structure.sh

# ── Optional Dev Tools ──────────────────────────────────

golang: ## Install Go via g version manager
	source $(DOTFILES)/_install/golang.sh

rust: ## Install Rust via rustup
	source $(DOTFILES)/_install/rust.sh

cargo-tools: ## Install cargo crates from cargo-tools.list (no Homebrew formula)
	bash $(DOTFILES)/_install/cargo-tools.sh

cargo-tools-update: ## Update all unpinned crates in cargo-tools.list
	bash $(DOTFILES)/_install/cargo-tools.sh --update

cargo-dump: ## List cargo-installed crates for drift comparison
	@cargo install --list
	@echo ""
	@echo "Compare with $(DOTFILES)/_install/cargo-tools.list — anything extra"
	@echo "either belongs in the list, or in brew/Brewfile.* if a formula exists."

clauth: ## Register the clauth herdr plugin (never writes herdr's config)
	bash $(DOTFILES)/_install/clauth.sh

asdf: ## Install asdf plugins
	source $(DOTFILES)/asdf/plugins.sh

herdr-plugins: ## Sync herdr plugins to plugins.list (herdr-lazy) & agent integrations
	bash $(DOTFILES)/_install/herdr-plugins.sh

herdr-plugins-update: ## Update all unpinned herdr plugins (herdr-lazy update)
	bash $(DOTFILES)/_install/herdr-plugins.sh --update

herdr-plugins-restore: ## Restore herdr plugins to the exact commits in plugins.lock
	bash $(DOTFILES)/_install/herdr-plugins.sh --restore

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

docker-dive: ## Analyze Docker image layers with dive
	dive $(or $(IMAGE),snic/nvim:latest)

docker-dive-ci: ## CI-mode dive analysis (fails on inefficiency)
	CI=true dive snic/nvim:latest
	CI=true dive snic/devenv:latest
	CI=true dive snic/devenv-web-terminal:latest
	CI=true dive snic/devenv-web-desktop:latest

# ── Validation ──────────────────────────────────────────

lint: ## Lint shell scripts
	shellcheck _install/*.sh _macOS/*.sh _lib/*.sh _test/*.sh bootstrap.sh install.sh

test-symlinks: ## Validate stow symlinks (dry-run)
	@bash _test/validate-symlinks.sh

test-configs: ## Validate JSON and TOML config syntax
	@bash _test/validate-configs.sh

test: lint test-symlinks test-configs ## Run all validation checks
	@echo "All tests passed."

# ── VM Testing ──────────────────────────────────────────

test-macos: ## Test dotfiles in a macOS VM (Tart, Apple Silicon only)
	@if [[ "$$(uname -s)" != "Darwin" ]]; then \
		echo "==> Skipping macOS VM test (not macOS)"; \
	else \
		bash _test/vm-test-macos.sh $(ARGS); \
	fi

test-macos-gui: ## Test dotfiles in a macOS VM (interactive, keeps VM open)
	@if [[ "$$(uname -s)" != "Darwin" ]]; then \
		echo "==> Skipping macOS VM test (not macOS)"; \
	else \
		bash _test/vm-test-macos.sh --interactive; \
	fi

test-linux: ## Test dotfiles in a Linux VM (Lima)
	bash _test/vm-test-linux.sh $(ARGS)

test-linux-gui: ## Test dotfiles in a Linux VM (interactive)
	bash _test/vm-test-linux.sh --interactive

vm-clean: ## Clean up all test VMs and cached images
	@echo "==> Cleaning Tart VMs..."
	@for vm in $$(tart list 2>/dev/null | awk '/test-dotfiles/{print $$2}'); do \
		tart stop "$$vm" 2>/dev/null || true; \
		tart delete "$$vm" 2>/dev/null || true; \
	done
	@echo "==> Pruning Tart OCI cache..."
	@tart prune --older-than 0 2>/dev/null || true
	@echo "==> Cleaning Lima VMs..."
	@for vm in $$(limactl list 2>/dev/null | awk '/test-dotfiles/{print $$1}'); do \
		limactl stop "$$vm" 2>/dev/null || true; \
		limactl delete -f "$$vm" 2>/dev/null || true; \
	done
	@echo "==> Done."

# ── Help ────────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

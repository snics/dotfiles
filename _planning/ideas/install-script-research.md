# Dotfiles Install Script Research (2025-2026)

Concrete comparison of modern approaches, drawn from real repos with actual code.

---

## 1. Makefile vs justfile vs Shell Script

### Who Uses What

| Approach | Repos | Notes |
|----------|-------|-------|
| **Makefile** | webpro/dotfiles, sagebind/dotfiles, driesvints/dotfiles | Most common "task runner" approach. Universal: `make` is pre-installed everywhere. |
| **justfile** | iheanyi/dotfiles | Rising in 2025-2026. Better UX, but requires installing `just` first. |
| **Shell script** | holman/dotfiles, nickjj/dotfiles, elithrar/dotfiles, jessfraz/dotfiles | Most flexible. No dependencies. Can be curl-piped. |
| **rcm (dedicated tool)** | thoughtbot/dotfiles | Uses `rcup`/`rcrc` instead of stow. Simpler config but less flexible. |
| **Nix + Stow hybrid** | fredrikaverpil/dotfiles | Nix for packages, Stow as fallback for symlinks. |

### Makefile -- Pros/Cons for Dotfiles

**Pros:**
- Pre-installed on macOS (Xcode CLI tools) and Linux
- Declarative dependency graph between targets
- Idempotent by design (targets only rebuild if needed)
- `make zsh`, `make nvim` gives modular install for free
- CI-friendly (`make` in GitHub Actions just works)

**Cons:**
- Ugly syntax (tabs required, `$$` escaping for shell variables)
- No built-in cross-platform conditionals (relies on `$(shell ...)`)
- Error messages are cryptic
- Multi-line shell commands need `\` continuation or `.ONESHELL`

**webpro/dotfiles Makefile** (the gold standard for Makefile-based dotfiles):

```makefile
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)

.PHONY: test

all: $(OS)

macos: sudo core-macos packages-macos link duti bun
ubuntu: core-ubuntu link
arch: core-arch packages-arch link

core-macos: brew bash git npm

# Stow integration -- two directories, two targets
link: stow-$(OS)
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
		mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p "$(XDG_CONFIG_HOME)"
	stow -t "$(HOME)" runcom
	stow -t "$(XDG_CONFIG_HOME)" config
	mkdir -p $(HOME)/.local/runtime
	chmod 700 $(HOME)/.local/runtime

unlink: stow-$(OS)
	stow --delete -t "$(HOME)" runcom
	stow --delete -t "$(XDG_CONFIG_HOME)" config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

# Keep sudo alive during install
sudo:
ifndef GITHUB_ACTION
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif
```

Key patterns:
- `OS` detection via helper scripts (`bin/is-supported`, `bin/is-macos`)
- `GITHUB_ACTION` check skips sudo in CI
- `stow -t TARGET DIR` pattern for different target dirs
- Backup existing files before stowing

### justfile -- Pros/Cons for Dotfiles

**Pros:**
- Clean syntax (no tab requirements, no `$$` escaping)
- Built-in `os()` and `arch()` functions
- `justfile_directory()` always resolves correctly
- Shebang recipes (`#!/usr/bin/env bash`) for multi-line scripts
- `just --list` gives free documentation
- `set shell` for portability

**Cons:**
- Must install `just` first (chicken-and-egg for bootstrap)
- Less ubiquitous than `make`
- No file-based dependency tracking (all targets are "phony")

**iheanyi/dotfiles justfile** (best real-world justfile dotfiles):

```just
# Dotfiles installation and management
set shell := ["bash", "-c"]

# Detect OS
os := if os() == "macos" { "macos" } else if os() == "linux" { "linux" } else { "unknown" }

default:
    @just --list

# Full install chains dependencies
install: install-homebrew install-packages install-fish install-tmux-plugins link setup-git
    @echo "Installation complete! Restart your terminal."

# Per-component link targets
link: link-fish link-neovim link-terminal link-git link-tmux link-starship link-mise link-claude link-scripts

link-fish:
    @mkdir -p ~/.config/fish/conf.d
    @mkdir -p ~/.config/fish/functions
    @ln -sf {{justfile_directory()}}/config.fish ~/.config/fish/config.fish
    @ln -sf {{justfile_directory()}}/fish_plugins ~/.config/fish/fish_plugins
    @for f in {{justfile_directory()}}/fish/conf.d/*.fish; do ln -sf "$$f" ~/.config/fish/conf.d/; done
    @for f in {{justfile_directory()}}/fish/functions/*.fish; do ln -sf "$$f" ~/.config/fish/functions/; done
    @echo "Fish config linked"

link-neovim:
    @mkdir -p ~/.config/nvim/lua/config
    @ln -sf {{justfile_directory()}}/init.lua ~/.config/nvim/init.lua
    @for f in {{justfile_directory()}}/lua/config/*.lua; do ln -sf "$$f" ~/.config/nvim/lua/config/; done
    @echo "Neovim config linked"

# Maintenance
update: update-brew update-fish update-neovim update-tmux
    @echo "All updates complete"

update-brew:
    brew update && brew upgrade

# Diagnostics
check:
    #!/usr/bin/env bash
    echo "Checking installed tools..."
    tools=("fish" "nvim" "starship" "fzf" "git" "tmux" "ghostty" "bat" "fd" "rg" "zoxide" "direnv" "difft" "mergiraf")
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            echo "  $tool"
        else
            echo "  $tool (not installed)"
        fi
    done

doctor:
    #!/usr/bin/env bash
    echo "Running diagnostics..."
    errors=0
    # Check symlinks
    echo "=== Symlinks ==="
    # ... validates all expected symlinks exist
```

### Shell Script -- Pros/Cons for Dotfiles

**Pros:**
- Zero dependencies
- Can be curl-piped for remote bootstrap
- Full power of bash (loops, functions, error handling)
- Easy colored output, progress bars, interactive prompts

**Cons:**
- No built-in dependency graph (must manage ordering manually)
- Harder to run individual components (`./install --only zsh`)
- Must implement idempotency manually
- Longer, harder to scan at a glance

### Recommendation for Your Repo

**Makefile as primary entry point** is the best fit because:
1. Your repo already uses GNU Stow -- Makefile + Stow is the proven combo
2. `make` is pre-installed on macOS after Xcode CLI tools
3. Per-package targets (`make zsh`, `make nvim`) are trivial to add
4. CI testing is straightforward
5. Your `_install/*.sh` scripts can be called from Makefile targets

If you prefer modern syntax, **justfile is the best alternative** but requires
a bootstrap step to install `just` itself first.

---

## 2. Non-Interactive Design Patterns

### Platform Detection

**Pattern A: Simple uname (most common)**
```bash
OS="$(uname -s)"    # "Darwin" or "Linux"
ARCH="$(uname -m)"  # "arm64" or "x86_64"
```

**Pattern B: Normalized lowercase (nickjj, elithrar)**
```bash
OS_TYPE="$(uname | tr '[:upper:]' '[:lower:]')"  # "darwin" or "linux"
CPU_ARCH="$(uname -m)"
```

**Pattern C: Helper functions (webpro)**
```bash
# bin/is-macos
[[ "$(uname -s)" == "Darwin" ]]

# bin/is-ubuntu
[[ "$(cat /etc/issue 2>/dev/null)" =~ Ubuntu ]]

# bin/is-arm64
[[ "$(uname -m)" == "arm64" ]]

# bin/is-supported (usage: bin/is-supported bin/is-macos VALUE_IF_TRUE VALUE_IF_FALSE)
if eval "$1" > /dev/null 2>&1; then echo "$2"; else echo "${3:-}"; fi
```

**Pattern D: Linux distro detection (nickjj)**
```bash
if [ -r /etc/os-release ]; then
    OS_DISTRO="$(. /etc/os-release && echo "${ID_LIKE:-${ID}}")"
    [[ "${OS_DISTRO}" =~ (ubuntu|debian) ]] && OS_DISTRO="debian"
fi

# WSL detection
if grep -q "\-WSL2" /proc/version 2>/dev/null; then
    OS_IN_WSL=1
fi
```

**Pattern E: Makefile OS detection (sagebind)**
```makefile
OS := $(shell uname | tr '[:upper:]' '[:lower:]')
PACKAGES := home "home.$(OS)"
HAS_BREW := $(shell which brew 2>/dev/null)

apply: $(if $(HAS_BREW),brew-bundle) link
```

**Pattern F: justfile OS detection (iheanyi)**
```just
os := if os() == "macos" { "macos" } else if os() == "linux" { "linux" } else { "unknown" }
```

### Homebrew Prefix Detection (Apple Silicon vs Intel)

```bash
# Pattern used by webpro, elithrar, petertriho
case "$(uname -m)" in
    arm64) HOMEBREW_PREFIX="/opt/homebrew" ;;
    x86_64) HOMEBREW_PREFIX="/usr/local" ;;
esac

# Makefile version (webpro)
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
```

### First-Run vs Update (Idempotency)

**Pattern A: Check-before-install (most common)**
```bash
# Check if tool exists before installing
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if directory exists before cloning
if [ -d "${DOTFILES_PATH}" ]; then
    echo "Skipping clone, dotfiles already exist"
    return 0
fi
```

**Pattern B: Stow --restow for idempotent re-linking (sagebind)**
```makefile
# First install
link:
	stow --stow --dir="$(CURDIR)" $(PACKAGES)

# Safe re-run (removes then re-creates symlinks)
relink:
	stow --restow --dir="$(CURDIR)" $(PACKAGES)
```

**Pattern C: Backup-then-link (webpro)**
```bash
# Back up real files, then stow will create symlinks
for FILE in $(\ls -A runcom); do
    if [ -f "$HOME/$FILE" -a ! -h "$HOME/$FILE" ]; then
        mv -v "$HOME/$FILE"{,.bak}
    fi
done
stow -t "$HOME" runcom
```

**Pattern D: brew bundle for idempotent package management**
```bash
# brew bundle is inherently idempotent -- only installs missing packages
brew bundle install --file=~/Brewfile --no-lock
```

### CI=true / Non-Interactive Patterns

```bash
# Skip sudo prompts in CI (webpro)
ifndef GITHUB_ACTION
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

# Non-interactive Homebrew install (universal pattern)
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Detect interactive terminal (elithrar)
INTERACTIVE=false
if [[ -t 0 ]] && [[ -t 1 ]]; then
    INTERACTIVE=true
fi

# Skip prompts based on environment
if [ "${CI:-}" = "true" ] || [ "${NONINTERACTIVE:-}" = "1" ]; then
    AUTO_CONFIRM=1
fi
```

### Colored Logging Helpers

**Pattern A: Simple printf (elithrar) -- recommended**
```bash
red=$(tput setaf 1 2>/dev/null || printf '\033[0;31m')
green=$(tput setaf 2 2>/dev/null || printf '\033[0;32m')
blue=$(tput setaf 4 2>/dev/null || printf '\033[0;34m')
reset=$(tput sgr0 2>/dev/null || printf '\033[0m')

print_success() { printf "%s %b\n" "${green}success:${reset}" "$1"; }
print_error()   { printf "%s %b\n" "${red}error:${reset}" "$1"; }
print_info()    { printf "%s %b\n" "${blue}info:${reset}" "$1"; }
```

**Pattern B: ANSI escape codes (nickjj)**
```bash
C_RED="\e[0;31;1m"
C_GREEN="\e[0;32;1m"
C_CYAN="\e[0;36;1m"
C_RESET="\e[0m"

_error() { printf "%bERROR: %s%b\n\n" "${C_RED}" "$1" "${C_RESET}" >&2; exit 1; }
_info()  { printf "\n\n%b%s:%b\n\n" "${C_CYAN}" "$1" "${C_RESET}"; }
```

**Pattern C: Section headers (holman)**
```bash
info()    { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; }
user()    { printf "\r  [ \033[0;33m??\033[0m ] $1\n"; }
success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }
fail()    { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; echo ''; exit; }
```

### Error Handling

```bash
# Exit trap for cleanup message (elithrar)
ret=0
trap 'ret=$?; [[ $ret -ne 0 ]] && printf "%s\n" "${red}Setup failed${reset}" >&2; exit $ret' EXIT
set -euo pipefail
```

---

## 3. Modular Component Installation with GNU Stow

### Pattern A: Makefile Per-Package Targets (recommended for your repo)

```makefile
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export STOW_DIR = $(DOTFILES_DIR)
export XDG_CONFIG_HOME = $(HOME)/.config

# Packages that stow into $HOME (those with dotfiles in root like .zshrc)
HOME_PACKAGES := git zsh

# Packages that stow into ~/.config (most XDG-compliant tools)
CONFIG_PACKAGES := nvim ghostty tmux lazygit k9s zed

# Non-stow packages (have custom install logic)
SPECIAL_PACKAGES := brew macOS

# ---- Main targets ----

.PHONY: all link unlink

all: brew link

link:
	mkdir -p "$(XDG_CONFIG_HOME)"
	stow -t "$(HOME)" $(HOME_PACKAGES)
	stow -t "$(XDG_CONFIG_HOME)" $(CONFIG_PACKAGES)

unlink:
	stow --delete -t "$(HOME)" $(HOME_PACKAGES)
	stow --delete -t "$(XDG_CONFIG_HOME)" $(CONFIG_PACKAGES)

# ---- Per-package targets ----

zsh: brew-stow
	stow -t "$(HOME)" zsh

nvim: brew-stow
	stow -t "$(XDG_CONFIG_HOME)" nvim

git: brew-stow
	stow -t "$(HOME)" git

tmux: brew-stow
	stow -t "$(XDG_CONFIG_HOME)" tmux

ghostty: brew-stow
	stow -t "$(XDG_CONFIG_HOME)" ghostty

# ---- Dependencies ----

brew-stow:
	command -v stow >/dev/null || brew install stow

brew:
	command -v brew >/dev/null || NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	stow -t "$(HOME)" brew
	brew bundle install --file=$(HOME)/Brewfile --no-lock
```

### Pattern B: sagebind's Auto-Detect Packages Approach

```makefile
OS := $(shell uname | tr '[:upper:]' '[:lower:]')
PACKAGES := home "home.$(OS)"
HAS_BREW := $(shell which brew 2>/dev/null)

# Stow anti-folding: create dirs that stow would otherwise replace with symlinks
UNFOLDED_DIR_MARKERS := $(shell find $(PACKAGES) -type f -name .no-stow-folding)
UNFOLDED_DIRS := $(patsubst home/%, $(HOME)/%, $(dir $(UNFOLDED_DIR_MARKERS)))

apply: $(if $(HAS_BREW),brew-bundle) link

link: $(UNFOLDED_DIRS)
	stow --stow --dir="$(CURDIR)" $(PACKAGES)

relink: $(UNFOLDED_DIRS)
	stow --restow --dir="$(CURDIR)" $(PACKAGES)

dry-run:
	stow --simulate --stow --dir="$(CURDIR)" $(PACKAGES)

unlink:
	stow --delete --dir="$(CURDIR)" $(PACKAGES)

$(UNFOLDED_DIRS):
	mkdir -p $@
```

The `.no-stow-folding` marker file trick: place an empty file in any directory
where you want Stow to create the directory (not a symlink to the directory).
This prevents stow from "folding" the directory into a single symlink.

### Pattern C: justfile With Manual Symlinks (iheanyi, no stow)

```just
# Each component has explicit link/unlink recipes
link-tmux:
    @mkdir -p ~/.config/tmux
    @ln -sf {{justfile_directory()}}/tmux.conf ~/.config/tmux/tmux.conf
    @echo "Tmux config linked"

link-git:
    @ln -sf {{justfile_directory()}}/.gitconfig ~/.gitconfig
    @ln -sf {{justfile_directory()}}/.gitignore_global ~/.gitignore_global
    @echo "Git config linked"
```

### Dependency Ordering

For your repo, the install order matters:

```
1. brew        (package manager -- everything depends on this)
2. git         (stow itself needs git for nothing, but config is foundational)
3. zsh         (shell -- most other tools are configured to use it)
4. tmux        (terminal multiplexer)
5. nvim        (editor)
6. ghostty     (terminal emulator)
7. lazygit     (git TUI)
8. k9s         (kubernetes TUI)
9. zed/cursor  (GUI editors)
```

In a Makefile, express this with target dependencies:

```makefile
all: brew link

# brew must come before link (which runs stow)
link: brew-stow
	stow -t "$(HOME)" $(HOME_PACKAGES)
	stow -t "$(XDG_CONFIG_HOME)" $(CONFIG_PACKAGES)

# Some packages need brew packages installed first
nvim: brew link-nvim
tmux: brew link-tmux
```

---

## 4. Remote One-Liner Install (Bootstrap)

### Pattern A: webpro -- Clone or Tarball Fallback

```bash
#!/usr/bin/env bash
# remote-install.sh

SOURCE="https://github.com/webpro/dotfiles"
TARBALL="$SOURCE/tarball/main"
TARGET="$HOME/.dotfiles"
TAR_CMD="tar -xzv -C \"$TARGET\" --strip-components=1 --exclude='{.gitignore}'"

is_executable() {
  type "$1" > /dev/null 2>&1
}

if is_executable "git"; then
  CMD="git clone $SOURCE $TARGET"
elif is_executable "curl"; then
  CMD="curl -#L $TARBALL | $TAR_CMD"
elif is_executable "wget"; then
  CMD="wget --no-check-certificate -O - $TARBALL | $TAR_CMD"
fi

if [ -z "$CMD" ]; then
  echo "No git, curl or wget available. Aborting."
else
  echo "Installing dotfiles..."
  mkdir -p "$TARGET"
  eval "$CMD"
fi
```

**Invoked via:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/webpro/dotfiles/master/remote-install.sh)"
```

### Pattern B: Clone + Make (recommended for your repo)

```bash
#!/usr/bin/env bash
# bootstrap.sh -- curl-pipeable bootstrap script
set -euo pipefail

DOTFILES_REPO="https://github.com/YOUR_USER/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-master}"

# --- Colors ---
red='\033[0;31m'; green='\033[0;32m'; blue='\033[0;34m'; reset='\033[0m'
info()    { printf "${blue}==> %s${reset}\n" "$1"; }
success() { printf "${green}==> %s${reset}\n" "$1"; }
error()   { printf "${red}==> ERROR: %s${reset}\n" "$1" >&2; exit 1; }

# --- Ensure git is available ---
if ! command -v git &>/dev/null; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install 2>/dev/null || true
        # Wait for installation
        until xcode-select -p &>/dev/null; do sleep 5; done
    else
        error "git is required but not installed"
    fi
fi

# --- Clone or update ---
if [ -d "$DOTFILES_DIR" ]; then
    info "Dotfiles already cloned. Pulling latest..."
    git -C "$DOTFILES_DIR" pull --rebase --autostash
else
    info "Cloning dotfiles..."
    git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# --- Run install ---
cd "$DOTFILES_DIR"
make all

success "Dotfiles installed successfully!"
```

**Usage:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOU/dotfiles/master/bootstrap.sh)"
```

### Pattern C: yadm -- Dedicated Bootstrap Tool

```bash
# yadm can be bootstrapped via curl pipe
curl -L bootstrap.yadm.io | bash
# Which clones your dotfiles AND installs yadm as a submodule
```

### Security Considerations

1. **Always use `https://`** for clone URLs in bootstrap scripts
2. **Pin to a branch or tag** (`--branch master`) rather than defaulting to HEAD
3. **Use `set -euo pipefail`** so failures are not silently ignored
4. **Provide a manual alternative** in the README:
   ```
   # If you prefer not to curl|bash:
   git clone https://github.com/YOU/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles && make
   ```
5. **GitHub raw URLs can be verified** by checking the commit SHA
6. The `curl -fsSL` flags mean: fail silently on HTTP errors (`-f`), silent
   progress (`-sS`), follow redirects (`-L`)

---

## 5. Concrete Makefile Template for Your Repo

Based on all the research above, here is a Makefile tailored for your existing
`~/.dotfiles` structure with GNU Stow packages:

```makefile
# ~/.dotfiles/Makefile
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m)
HOMEBREW_PREFIX := $(shell if [ "$(ARCH)" = "arm64" ]; then echo /opt/homebrew; else echo /usr/local; fi)
PATH := $(HOMEBREW_PREFIX)/bin:$(PATH)
SHELL := /bin/bash

export XDG_CONFIG_HOME ?= $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)

# ── Package Lists ──────────────────────────────────────────────────
# Packages that stow directly into $HOME
HOME_PACKAGES := zsh git

# Packages that stow into ~/.config
CONFIG_PACKAGES := nvim ghostty tmux lazygit k9s zed opencode

# Everything that is not a stow package
NON_STOW := _install brew docs macOS planning

# ── Main Targets ───────────────────────────────────────────────────
.PHONY: all install link unlink relink update check clean help

all: install link ## Full setup: install packages + link configs

install: brew ## Install system packages via Homebrew
	stow -t "$(HOME)" brew
	brew bundle install --file=$(HOME)/Brewfile --no-lock

link: ensure-stow ## Create all symlinks via GNU Stow
	mkdir -p "$(XDG_CONFIG_HOME)"
	@echo "==> Linking home packages: $(HOME_PACKAGES)"
	stow -t "$(HOME)" $(HOME_PACKAGES)
	@echo "==> Linking config packages: $(CONFIG_PACKAGES)"
	stow -t "$(XDG_CONFIG_HOME)" $(CONFIG_PACKAGES)

unlink: ensure-stow ## Remove all symlinks
	-stow --delete -t "$(HOME)" $(HOME_PACKAGES)
	-stow --delete -t "$(XDG_CONFIG_HOME)" $(CONFIG_PACKAGES)

relink: ensure-stow ## Re-create all symlinks (safe to re-run)
	stow --restow -t "$(HOME)" $(HOME_PACKAGES)
	stow --restow -t "$(XDG_CONFIG_HOME)" $(CONFIG_PACKAGES)

update: ## Update Homebrew packages
	brew update && brew upgrade && brew cleanup

check: ## Verify all expected tools are installed
	@echo "==> Checking installed tools..."
	@for tool in zsh nvim tmux stow git bat fd rg fzf lazygit k9s ghostty; do \
		if command -v $$tool >/dev/null 2>&1; then \
			printf "  OK  %s\n" "$$tool"; \
		else \
			printf "  MISSING  %s\n" "$$tool"; \
		fi; \
	done

clean: unlink ## Remove symlinks and Homebrew cache
	brew cleanup --prune=all 2>/dev/null || true

# ── Per-Package Targets ────────────────────────────────────────────

zsh: ensure-stow ## Link zsh configs
	stow -t "$(HOME)" zsh

nvim: ensure-stow ## Link neovim configs
	stow -t "$(XDG_CONFIG_HOME)" nvim

git: ensure-stow ## Link git configs
	stow -t "$(HOME)" git

tmux: ensure-stow ## Link tmux configs
	stow -t "$(XDG_CONFIG_HOME)" tmux

ghostty: ensure-stow ## Link ghostty configs
	stow -t "$(XDG_CONFIG_HOME)" ghostty

lazygit: ensure-stow ## Link lazygit configs
	stow -t "$(XDG_CONFIG_HOME)" lazygit

k9s: ensure-stow ## Link k9s configs
	stow -t "$(XDG_CONFIG_HOME)" k9s

zed: ensure-stow ## Link zed configs
	stow -t "$(XDG_CONFIG_HOME)" zed

opencode: ensure-stow ## Link opencode configs
	stow -t "$(XDG_CONFIG_HOME)" opencode

# ── macOS-Specific ─────────────────────────────────────────────────

macos: ## Apply macOS system preferences
ifeq ($(OS),darwin)
	@echo "==> Applying macOS settings..."
	@for f in macOS/*.sh; do bash "$$f"; done
else
	@echo "Skipping macOS settings (not on macOS)"
endif

# ── Dependencies ───────────────────────────────────────────────────

brew: ## Install Homebrew if missing
	@command -v brew >/dev/null 2>&1 || { \
		echo "==> Installing Homebrew..."; \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		eval "$$($(HOMEBREW_PREFIX)/bin/brew shellenv)"; \
	}

ensure-stow:
	@command -v stow >/dev/null 2>&1 || { echo "==> Installing stow..."; brew install stow; }

# ── Help ───────────────────────────────────────────────────────────

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
```

### Equivalent justfile (if you prefer just)

```just
#!/usr/bin/env just --justfile

set shell := ["bash", "-euo", "pipefail", "-c"]

dotfiles := justfile_directory()
os := if os() == "macos" { "darwin" } else { os() }
arch := arch()
homebrew_prefix := if arch == "aarch64" { "/opt/homebrew" } else { "/usr/local" }
xdg_config := env_var_or_default("XDG_CONFIG_HOME", home_directory() / ".config")
home := home_directory()

home_packages := "zsh git"
config_packages := "nvim ghostty tmux lazygit k9s zed opencode"

# Show available recipes
default:
    @just --list

# Full setup: install packages + link configs
all: install link

# Install Homebrew and packages
install: brew
    cd {{dotfiles}} && stow -t "{{home}}" brew
    brew bundle install --file={{home}}/Brewfile --no-lock

# Create all symlinks
link: ensure-stow
    #!/usr/bin/env bash
    mkdir -p "{{xdg_config}}"
    cd "{{dotfiles}}"
    echo "==> Linking home packages: {{home_packages}}"
    stow -t "{{home}}" {{home_packages}}
    echo "==> Linking config packages: {{config_packages}}"
    stow -t "{{xdg_config}}" {{config_packages}}

# Remove all symlinks
unlink: ensure-stow
    cd {{dotfiles}} && stow --delete -t "{{home}}" {{home_packages}} || true
    cd {{dotfiles}} && stow --delete -t "{{xdg_config}}" {{config_packages}} || true

# Re-create all symlinks (idempotent)
relink: ensure-stow
    cd {{dotfiles}} && stow --restow -t "{{home}}" {{home_packages}}
    cd {{dotfiles}} && stow --restow -t "{{xdg_config}}" {{config_packages}}

# Update Homebrew packages
update:
    brew update && brew upgrade && brew cleanup

# Verify tools are installed
check:
    #!/usr/bin/env bash
    echo "==> Checking installed tools..."
    for tool in zsh nvim tmux stow git bat fd rg fzf lazygit k9s ghostty; do
        if command -v "$tool" &>/dev/null; then
            printf "  OK  %s\n" "$tool"
        else
            printf "  MISSING  %s\n" "$tool"
        fi
    done

# ── Per-Package Targets ──

# Link only zsh configs
zsh: ensure-stow
    cd {{dotfiles}} && stow -t "{{home}}" zsh

# Link only nvim configs
nvim: ensure-stow
    cd {{dotfiles}} && stow -t "{{xdg_config}}" nvim

# Link only git configs
git: ensure-stow
    cd {{dotfiles}} && stow -t "{{home}}" git

# Link only tmux configs
tmux: ensure-stow
    cd {{dotfiles}} && stow -t "{{xdg_config}}" tmux

# ── Dependencies ──

[private]
brew:
    #!/usr/bin/env bash
    if ! command -v brew &>/dev/null; then
        echo "==> Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

[private]
ensure-stow:
    @command -v stow &>/dev/null || brew install stow

# ── macOS Only ──

# Apply macOS system preferences
macos:
    #!/usr/bin/env bash
    if [[ "$(uname -s)" != "Darwin" ]]; then
        echo "Skipping macOS settings (not on macOS)"
        exit 0
    fi
    for f in {{dotfiles}}/macOS/*.sh; do bash "$f"; done

# ── Help ──

# Show diagnostics for debugging
doctor:
    #!/usr/bin/env bash
    echo "OS:     {{os}}"
    echo "Arch:   {{arch}}"
    echo "Home:   {{home}}"
    echo "XDG:    {{xdg_config}}"
    echo "Stow:   {{dotfiles}}"
    echo ""
    echo "=== Symlink Status ==="
    for pkg in {{home_packages}}; do
        for f in $(ls -A "{{dotfiles}}/$pkg/" 2>/dev/null); do
            target="{{home}}/$f"
            if [ -L "$target" ]; then
                echo "  OK     $target"
            elif [ -e "$target" ]; then
                echo "  CONFLICT $target (exists but not a symlink)"
            else
                echo "  MISSING  $target"
            fi
        done
    done
```

---

## 6. Key Takeaways & Decision Matrix

| Criteria | Makefile | justfile | Shell Script |
|----------|----------|----------|-------------|
| Pre-installed | Yes (macOS/Linux) | No (needs install) | Yes |
| Curl-pipeable | No | No | Yes |
| Modular targets | Native | Native | Manual (getopts) |
| Dependency graph | Native | Manual (recipe deps) | Manual |
| Syntax clarity | Poor ($$, tabs) | Good | Good |
| Cross-platform | Via $(shell) | Built-in os()/arch() | Via uname |
| CI integration | Excellent | Good | Good |
| Self-documenting | With help target | Built-in (--list) | Manual |
| GNU Stow fit | Excellent | Good | Good |

**Recommended architecture for your repo:**

```
~/.dotfiles/
  Makefile           # Primary entry point (make, make zsh, make nvim, etc.)
  bootstrap.sh       # Curl-pipeable remote installer (clones + runs make)
  _install/          # Keep existing per-tool scripts for complex installs
  brew/              # stow package -> $HOME
  zsh/               # stow package -> $HOME
  git/               # stow package -> $HOME
  nvim/              # stow package -> ~/.config
  ...
```

The Makefile calls `stow` directly for simple packages and delegates to
`_install/*.sh` for tools that need more complex setup (language runtimes,
editor plugins, etc.).

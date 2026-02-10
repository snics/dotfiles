# Pre-Zimfw initialization: environment variables and zstyles that
# plugins read during their init. Sourced explicitly before Zimfw.

# Editor
export EDITOR="nvim"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# Catppuccin Mocha theme for zsh-syntax-highlighting
source ~/.dotfiles/zsh/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Homebrew performance
# Skip auto-update before every install/upgrade (we run `brew update` explicitly in `update brew`)
export HOMEBREW_NO_AUTO_UPDATE=1
# Skip auto-cleanup after install (we run `brew cleanup` explicitly in `update brew`)
export HOMEBREW_NO_INSTALL_CLEANUP=1

# fzf config file (Catppuccin Mocha theming)
export FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fzf/config"

# OMZ cache dir (required for docker/podman completion caching)
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

# ── Zim module zstyles (read during plugin init) ───────

# bat
zstyle ':zim:plugins:bat' theme 'Catppuccin-Mocha'

# eza
zstyle ':zim:plugins:eza' dirs-first 'yes'
zstyle ':zim:plugins:eza' header 'yes'
zstyle ':zim:plugins:eza' show-group 'yes'
zstyle ':zim:plugins:eza' icons 'yes'
zstyle ':zim:plugins:eza' size-prefix 'binary'
zstyle ':zim:plugins:eza' hyperlink 'yes'

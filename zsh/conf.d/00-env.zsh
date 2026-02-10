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

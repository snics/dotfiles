# Set catppuccin theme
# --------------------
# Set catppuccin theme for zsh-syntax-highlighting
source ~/.dotfiles/zsh/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Set up global variables
# -----------------------

# Set the global editor to nvim
export EDITOR='nvim'

# Set config directories
# ----------------------

# Set global config directory
export XDG_CONFIG_HOME="$HOME/.config"

# Set config directory for k9s
export K9S_CONFIG_DIR=~/.config/k9s

# Homebrew performance
# --------------------
# Skip auto-update before every install/upgrade (we run `brew update` explicitly in `update brew`)
export HOMEBREW_NO_AUTO_UPDATE=1
# Skip auto-cleanup after install (we run `brew cleanup` explicitly in `update brew`)
export HOMEBREW_NO_INSTALL_CLEANUP=1

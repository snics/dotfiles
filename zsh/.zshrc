# Source: Global settings and Environment variables
source ~/.dotfiles/zsh/settings/global_settings.zsh

# Set up homebrew.
if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -e ~/.secrets ]; then
  source ~/.secrets
fi

# All of my custom settings
source ~/.dotfiles/zsh/settings/aliases.zsh
source ~/.dotfiles/zsh/settings/functions.zsh
source ~/.dotfiles/zsh/settings/completion.zsh
source ~/.dotfiles/zsh/settings/bat.zsh
source ~/.dotfiles/zsh/settings/eza.zsh
source ~/.dotfiles/zsh/settings/fzf.zsh

# Set up zimfw plugin manager.
ZIM_HOME=~/.config/zim
ZDOTDIR=~/.config/zim

# Set up git as a zmodule.
zstyle ':zim:zmodule' use 'degit'

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

# Set up tmux.
# Download TPM (Tmux Plugin Manager) if missing.
if command -v git &> /dev/null; then
  if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
  fi
fi

# Set keybindings to vi mode.
bindkey -e
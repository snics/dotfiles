source $ZPLUG_HOME/init.zsh

# load all plugins form my zplug settings
source "${0:h}/plugins.zsh"

# load all theme form my zplug settings
source "${0:h}/theme.zsh"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
# This its the same but for debugging
#zplug load --verbose

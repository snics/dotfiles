

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# herdr-lazy: declarative plugin list lives in the dotfiles repo (stowed copy at
# ~/.config/herdr/plugins.list); the lockfile is written next to it, so both are
# versioned. Set in .zprofile so the herdr server (launched from Ghostty's login
# shell) inherits it for the manage pane and startup auto-sync.
export HERDR_LAZY_LIST="$HOME/.dotfiles/herdr/.config/herdr/plugins.list"

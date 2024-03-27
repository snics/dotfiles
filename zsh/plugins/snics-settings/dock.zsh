mkdock () {
    echo "Make dock..."

    dockutil --no-restart --remove all
    dockutil --no-restart --add '/System/Applications/System Settings.app'
    dockutil --no-restart --add '/Applications/Spotify.app'

    # Add space to System configuration
    defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type='spacer-tile';}'

    dockutil --no-restart --add '/Applications/Google Chrome.app'
    dockutil --no-restart --add '/Applications/Arc.app'

    # Add space to System configuration
    defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type='spacer-tile';}'

    dockutil --no-restart --add "/Applications/Superhuman.app"
    dockutil --no-restart --add "/Applications/Fantastical.app"
    dockutil --no-restart --add "/Applications/Todoist.app"
    dockutil --no-restart --add "/Applications/Franz.app"

    # Add space to System configuration
    defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type='spacer-tile';}'

    dockutil --no-restart --add "/Applications/Zed.app"
    dockutil --no-restart --add "/Applications/iTerm.app"
    dockutil --no-restart --add "/Applications/GitKraken.app"

    # Add space to System configuration
    defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type='spacer-tile';}'

    dockutil --no-restart --add '~/Projects' --view list --display folder --sort name  --allhomes
    dockutil --no-restart --add '~/Downloads' --view list --display folder --sort dateadded --allhomes
    dockutil --add '/Applications' --view grid --display folder --sort name --allhomes

    echo "Dock done!"
}

alias dock='mkdock'

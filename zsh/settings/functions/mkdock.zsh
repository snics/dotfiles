_mkdock () {
    echo "Make dock..."

    dockutil --no-restart --remove all

    apps=(
        "/System/Applications/System Settings.app"
        "/Applications/Spotify.app"
        " "  # Add space
        "/Applications/Google Chrome.app"
        "/Applications/Arc.app"
        " "  # Add space
        "/Applications/Superhuman.app"
        "/Applications/Fantastical.app"
        "/Applications/Todoist.app"
        "/Applications/Franz.app"
        " "  # Add space
        "/Applications/Zed.app"
        "/Applications/WezTerm.app"
        "/Applications/GitKraken.app"
        " "  # Add space
    )

    for app in "${apps[@]}"; do
        if [[ "$app" == " " ]]; then
            # Add space to System configuration
            defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
        else
            # Add app to the dock
            dockutil --no-restart --add "$app"
        fi
    done

    # Add folders to the dock
    dockutil --no-restart --add '~/Projects' --view list --display folder --sort name --allhomes
    dockutil --no-restart --add '~/Downloads' --view list --display folder --sort dateadded --allhomes
    dockutil --no-restart --add '/Applications' --view grid --display folder --sort name --allhomes

    # Restart the dock
    killall Dock

    echo "Dock done!"
}

alias dock='_mkdock'
alias mkdock='_mkdock'

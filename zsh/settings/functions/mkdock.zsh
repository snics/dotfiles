_mkdock () {
    # Start spinner
    revolver start "🐳Configuring dock..."

    # Entfernt alle Einträge aus dem Dock
    dockutil --no-restart --remove all &> /dev/null

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
            defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}' &> /dev/null
        else
            # Add app to the dock
            dockutil --add "$app" &> /dev/null
        fi
    done

    # Add folders to the dock
    dockutil --add '~/Projects' --view list --display folder --sort name --replacing 'Projects' --allhomes &> /dev/null
    dockutil --add '~/Downloads' --view list --display folder --sort dateadded --replacing 'Downloads' --allhomes &> /dev/null
    dockutil --add '/Applications' --view grid --display folder --sort name --replacing 'Applications' --allhomes &> /dev/null

    # Restart the dock
    killall Dock

    # Stop spinner
    revolver stop
}

alias dock='_mkdock'
alias mkdock='_mkdock'

_mkdock() {
    # Start spinner
    revolver --style 'dots3' start "💻 Configuring dock..."

    # Load central app list
    source ~/.dotfiles/macOS/dock-apps.sh

    # Clear dock
    dockutil --no-restart --remove all &> /dev/null

    # Add apps
    for app in "${DOCK_APPS[@]}"; do
        if [[ "$app" == "SPACER" ]]; then
            defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}' &> /dev/null
        else
            dockutil --no-restart --add "$app" &> /dev/null
        fi
    done

    # Add folders
    for folder in "${DOCK_FOLDERS[@]}"; do
        # Split by | using zsh parameter expansion
        local parts=("${(@s:|:)folder}")
        local folder_path="${parts[1]}"
        local folder_view="${parts[2]}"
        local folder_display="${parts[3]}"
        local folder_sort="${parts[4]}"
        dockutil --no-restart --add "$folder_path" --view "$folder_view" --display "$folder_display" --sort "$folder_sort" --replacing "${folder_path:t}" --allhomes &> /dev/null
    done

    # Restart dock
    killall Dock

    # Stop spinner
    revolver update 'Dock creation done! 🎉'
    sleep 1
    revolver stop
}

alias dock='_mkdock'
alias mkdock='_mkdock'

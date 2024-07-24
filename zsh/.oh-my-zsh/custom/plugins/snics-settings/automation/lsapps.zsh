lsapps () {
    local brew_apps=($(brew list))
    local other_apps=($(find /Applications -type d -maxdepth 1 -mindepth 1 | awk -F '/' '{print $NF}' | sed 's/\.app$//'))

    echo "Brew installed applications:"
    for app in "${brew_apps[@]}"; do
        echo "  - $app"
    done

    echo "Other installed applications:"
    for app in "${other_apps[@]}"; do
        output=$(brew list | grep -w "$app")
        if [ $? -eq 0 ]; then
            echo "$output"
        fi
    done
}

make-mackup-apps () {
    brew_list=($(brew list))
    mackup_list=($(mackup list))
    mackup_list=($(mackup list | awk '/^ - /{print $NF}'))

    common_packages=($(echo "${brew_list[@]}" "${mackup_list[@]}" | tr ' ' '\n' | sort | uniq -d))


    echo "[applications_to_sync]:"
    for package in "${common_packages[@]}"; do
        echo "$package"
    done
}

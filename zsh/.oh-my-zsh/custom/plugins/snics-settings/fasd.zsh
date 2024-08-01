_selectd() {
    local dir
    dir=$(find * -type d | fzf --preview 'tree -C {}')

    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

_selectf() {
    local file
    file=$(find * -type f | fzf --preview 'bat --plain --number --color "always" {}')

    if [ -n "$file" ]; then
        local options=(
            "Open with default application"
            "Open with less"
            "Open with vim"
            "Open with cat"
            "Open with Web Browser"
            "Open with WebStorm"
            "Open with IntelliJ IDEA"
            "Open with CLion"
        )
        local choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select how to open $file: ")

        case $choice in
            "Open with default application")
                open "$file"
                ;;
            "Open with less")
                less "$file"
                ;;
            "Open with vim")
                vi "$file"
                ;;
            "Open with cat")
                cat "$file"
                ;;
            "Open with Web Browser")
                open -a "Google Chrome" "$file"
                ;;
            "Open with WebStorm")
                open -a "WebStorm" "$file"
                ;;
            "Open with IntelliJ IDEA")
                open -a "IntelliJ IDEA" "$file"
                ;;
            "Open with CLion")
                open -a "CLion" "$file"
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
    fi
}

_icd() {
    local dir
    dir=$(find * -type d | fzf --preview 'tree -C {}')

    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}


# jump to recently used items
alias a='cd'               # Change to directory
alias s='ls'               # Show / list
alias d='cd'               # Change to directory
alias f='open'             # Open file (may vary depending on your OS)
alias sd='_selectd'        # Interactive directory selection
alias sf='_selectf'        # Interactive file selection
alias z='cd'               # Change to directory
alias zz='_icd'            # Interactive change to directory


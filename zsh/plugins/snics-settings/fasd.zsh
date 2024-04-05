_selectd() {
    local dir
    dir=$(find * -type d | fzf --preview 'tree -C {}')

    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

_selectf() {
    local file
    file=$(find * -type f | fzf --preview 'bat --color "always" {}')

    if [ -n "$file" ]; then
        open "$file"
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


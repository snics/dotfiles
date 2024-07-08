#compdef exa

_exa() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '*:directory:_directories'
}

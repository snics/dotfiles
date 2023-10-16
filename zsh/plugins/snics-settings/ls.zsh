typeset -g exa_params
exa_params=('--oneline' '--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
tree_exa_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')

# ls
alias ls="exa ${exa_params}"

# one column, just names
alias lS="exa -1 ${exa_params}"

# tree
alias lt="exa --tree --level=90 ${tree_exa_params}"
alias tree="exa --tree --level=90 ${tree_exa_params}"

# list, size, type, git
alias l="exa --git-ignore ${exa_params}"

# all list
alias la="exa -a ${exa_params}"

# all + extended list
alias lx="exa -lbhHigUmuSa@ ${exa_params}"

# long list
alias ll="exa --header --long ${exa_params}"

# long list, modified date sort
alias llm="exa --header --long --sort=modified ${exa_params}"

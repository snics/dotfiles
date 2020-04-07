typeset -g exa_params
exa_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')

# ls
_ls() {
	exa ${exa_params} $@
}
alias ls="_ls"

# one column, just names
_lS() {
  exa -1 ${exa_params} $@
}
alias lS="_lS"

# tree
_lt() {
  exa --tree --level=2 ${exa_params} $@
}
alias lt="_lt"

 # list, size, type, git
_l() {
  exa --git-ignore ${exa_params} $@
}
alias l="_l"

# all list
_la() {
  exa -a ${exa_params} $@
}
alias la="_la"

# all + extended list
_lx() {
  exa -lbhHigUmuSa@ ${exa_params} $@
}
alias lx="_lx"

# long list
_ll() {
  exa --header --long ${exa_params} $@
}
alias ll="_ll"

# long list, modified date sort
_llm() {
  exa --header --long --sort=modified ${exa_params} $@
}
alias llm="_llm"

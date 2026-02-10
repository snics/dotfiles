# Override zimfw/fzf previews: eza tree for directories, bat for files
export FZF_CTRL_T_OPTS="--bind ctrl-/:toggle-preview --preview 'if [[ -d {} ]]; then eza --tree --level 3 --icons=auto --color=always -a {}; else bat --style=numbers --color=always --line-range :500 {}; fi'"
export FZF_ALT_C_OPTS="--bind ctrl-/:toggle-preview --preview 'eza --tree --level 3 --icons=auto --color=always -a {}'"

# Override zimfw/fzf preview: bat without header, eza tree for directories
export FZF_CTRL_T_OPTS="--bind ctrl-/:toggle-preview --preview 'if [[ -d {} ]]; then eza --tree --level 3 --icons=auto --color=always -a {}; else bat --style=numbers --color=always --line-range :500 {}; fi'"

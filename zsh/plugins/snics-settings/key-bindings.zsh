bindkey -v

# Map widgets to key
bindkey '^@'  fzf-select-widget
bindkey '^c' fzf-change-directory
bindkey '^f' fzf-edit-files
bindkey '^k' fzf-kill-processes
bindkey '^r'  fzf-insert-history

## Git
bindkey '^g'  fzf-select-git-widget

## Docker
bindkey '^@d'  fzf-select-docker-widget

typeset -gA FZF_WIDGET_OPTS
# Enable Exact-match by fzf-insert-history
FZF_WIDGET_OPTS[insert-history]='--exact'

FZF_WIDGET_TMUX=1

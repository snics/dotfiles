# fzf-tab directory preview (works for cd/z/zi via zoxide --cmd cd)
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --tree --level 3 --icons=automatic --color=always -a -l -h --no-permissions --no-time $realpath'

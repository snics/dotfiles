# Set completion preview for fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level 3 --icons=automatic --color=always -a -l -h --no-permissions --no-time $realpath'

zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --level 3 --icons=automatic --color=always -a -l -h --no-permissions --no-time $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza --tree --level 3 --icons=automatic --color=always -a -l -h --no-permissions --no-time $realpath'
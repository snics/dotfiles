# fzf-tab configuration (must load after zimfw completion module)
#
# The zimfw completion module sets:
#   zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
# fzf-tab does NOT percent-expand these zsh prompt sequences -- it passes
# the group description verbatim to fzf as a header string, so %F{yellow}
# shows up as literal text.  fzf-tab has its own coloring via group-colors.
# Fix: use a plain-text format that fzf-tab can display cleanly.
# See: https://github.com/Aloxaf/fzf-tab/issues/24
#      https://github.com/Aloxaf/fzf-tab/issues/379
zstyle ':completion:*:descriptions' format '[%d]'

# Directory preview for cd/z/zi (via zoxide --cmd cd)
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --tree --level 3 --icons=automatic --color=always -a -l -h --no-permissions --no-time $realpath'

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

# Popup height: fill the terminal below the prompt line.
# fzf-tab hardcodes --height to max 2/3 of LINES (lib/-ftb-fzf:98).
# fzf-flags is appended AFTER --height, and fzf takes the last value.
# A negative value means "terminal height minus N lines", so -1 leaves
# exactly the prompt line visible while the popup fills everything below.
zstyle ':fzf-tab:*' fzf-flags --height=-3

# Directory preview for cd/z/zi (via zoxide --cmd cd)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'fzf-preview $realpath'

# File preview for file-consuming commands: dirs as eza tree, images
# rendered with chafa (kitty graphics), text via bat.
# Script: zsh/.local/bin/fzf-preview
zstyle ':fzf-tab:complete:(cat|bat|less|head|tail|nvim|vim|vi|open|cp|mv|rm|ln|code|zed|chafa):*' \
  fzf-preview 'fzf-preview $realpath'

# fzf only manages kitty-graphics images when it detects kitty itself
# (KITTY_WINDOW_ID / TERM=xterm-kitty), so the last preview image would stay
# on screen after the completion popup closes. Wrap the widget to delete all
# placements once fzf exits; in-session cleanup between previews is handled
# by the leading delete-all in the fzf-preview script.
_fzf_kitty_img_clear() { print -n -- $'\e_Ga=d,d=A\e\\' > /dev/tty }

# Wrap the widget function itself, not the ^I binding: fzf-tab re-runs
# enable-fzf-tab from a precmd hook and 50-keybindings.zsh calls bindkey -e,
# both of which would clobber a key-level wrapper.
if ! (( $+functions[-ftb-complete-no-imgclear] )); then
  functions -c fzf-tab-complete -ftb-complete-no-imgclear
  fzf-tab-complete() {
    -ftb-complete-no-imgclear "$@"
    local ret=$?
    _fzf_kitty_img_clear
    return $ret
  }
fi

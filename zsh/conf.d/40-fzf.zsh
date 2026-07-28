# Override zimfw/fzf previews: fzf-preview handles dirs (eza tree),
# images (chafa) and text files (bat). Script: zsh/.local/bin/fzf-preview
export FZF_CTRL_T_OPTS="--bind ctrl-/:toggle-preview --preview 'fzf-preview {}'"
export FZF_ALT_C_OPTS="--bind ctrl-/:toggle-preview --preview 'eza --tree --level 3 --icons=auto --color=always -a {}'"

# Same kitty-graphics cleanup as fzf-tab (see 30-fzf-tab.zsh): delete image
# placements when the ctrl-t picker closes, or the last image would persist.
# Function wrap instead of key wrap for the same clobbering reasons.
if ! (( $+functions[fzf-file-widget-no-imgclear] )); then
  functions -c fzf-file-widget fzf-file-widget-no-imgclear
  fzf-file-widget() {
    fzf-file-widget-no-imgclear "$@"
    local ret=$?
    _fzf_kitty_img_clear
    return $ret
  }
fi

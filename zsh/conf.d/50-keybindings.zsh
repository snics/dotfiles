# Emacs keybindings
bindkey -e

# macOS Alt+C fix: Option+C produces 'ç' instead of \ec escape sequence.
# Bind the literal character to fzf's cd widget so Alt+C works as expected.
bindkey 'ç' fzf-cd-widget

# ============================================================================
# TUI Tool Launchers (Alt+key)
# ============================================================================
# Same functional mnemonics as tmux popup bindings (prefix+f/g/s/k).
# macOS Option key produces literal characters instead of escape sequences,
# so we bind both the escape sequence (\e) and the literal character.

# Alt+F → yazi (Files)
function _tui-yazi { yazi; zle reset-prompt }
zle -N _tui-yazi
bindkey '\ef' _tui-yazi
bindkey 'ƒ' _tui-yazi

# Alt+G → lazygit (Git)
function _tui-lazygit { lazygit; zle reset-prompt }
zle -N _tui-lazygit
bindkey '\eg' _tui-lazygit
bindkey '©' _tui-lazygit

# Alt+S → btop (System monitor)
function _tui-btop { btop; zle reset-prompt }
zle -N _tui-btop
bindkey '\es' _tui-btop
bindkey 'ß' _tui-btop

# Alt+K → k9s (Kubernetes)
function _tui-k9s { k9s; zle reset-prompt }
zle -N _tui-k9s
bindkey '\ek' _tui-k9s
bindkey '˚' _tui-k9s

# Emacs keybindings
bindkey -e

# Reduce escape-sequence timeout from 400ms (default) to 10ms.
# Arrow keys send escape sequences (\e[A etc.) — with the default KEYTIMEOUT=40
# zsh waits 400ms after each keypress to disambiguate, causing visible stutter
# during fast key repeat. 10ms is enough for terminal escape sequences.
KEYTIMEOUT=1

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

# ============================================================================
# herdr scratch popup (prefix+t sets HERDR_POPUP=1)
# ============================================================================
# herdr popups swallow all input until the command exits, so give the scratch
# shell the same close keys as the TUI popups: Ctrl+c on an empty line closes
# the popup (matching yazi/btop/k9s, which all quit on Ctrl+c), and Esc works
# as well — on a filled line both clear the line first. Safe with KEYTIMEOUT=1
# — real escape sequences (arrows, Alt chords) arrive within 10ms and still
# resolve to their bindings. A running foreground command still receives
# Ctrl+c as a normal interrupt; the trap only fires at the prompt.
if [[ $HERDR_POPUP == 1 ]]; then
  TRAPINT() {
    if [[ -o zle && -z $BUFFER ]]; then
      exit
    fi
    return $(( 128 + $1 ))
  }
  function _popup-esc {
    if [[ -n $BUFFER ]]; then
      zle kill-buffer
    else
      # Run exit as a command instead of calling it inside the widget —
      # this lets zsh tear down the line editor and tty cleanly.
      BUFFER="exit"
      zle accept-line
    fi
  }
  zle -N _popup-esc
  bindkey '\e' _popup-esc
fi

# Atuin: SQLite-backed shell history
# Takes over Ctrl+R (history search), Up/Down (prefix search), and
# provides autosuggestion strategy for zsh-autosuggestions
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh)"
fi

# Reduce zsh history to small fallback (Atuin is primary)
# Override zimfw/environment defaults (HISTSIZE=20000, SAVEHIST=10000)
HISTSIZE=5000
SAVEHIST=5000

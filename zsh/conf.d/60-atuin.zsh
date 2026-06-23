# Atuin: SQLite-backed shell history
# Takes over Ctrl+R (history search), Up/Down (prefix search), and
# provides autosuggestion strategy for zsh-autosuggestions
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh)"

  # Prefer Atuin's history for autosuggestions, fall back to zsh history + completion
  ZSH_AUTOSUGGEST_STRATEGY=(atuin history completion)

  # Fetch suggestions asynchronously so Atuin's SQLite queries
  # don't block the prompt during fast key repeat
  ZSH_AUTOSUGGEST_USE_ASYNC=1
fi

# Pin the autosuggestion ghost color to Catppuccin Surface2 so it stays dim
# even after ANSI 8 ("bright black") is brightened in the Ghostty palette for
# general dim-text readability. Decouples ghost suggestions from secondary text.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'

# Reduce zsh history to small fallback (Atuin is primary)
# Override zimfw/environment defaults (HISTSIZE=20000, SAVEHIST=10000)
HISTSIZE=5000
SAVEHIST=5000

# Atuin: SQLite-backed shell history
# Ctrl+R stays with fzf, Ctrl+E opens atuin's TUI
if (( $+commands[atuin] )); then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^E' _atuin_search_widget
fi

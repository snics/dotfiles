# Worktrunk (wt) shell integration — wraps wt in a shell function so
# `wt switch` can cd and `--execute` can run in this shell, and registers
# completions. Managed here instead of `wt config shell install` (which
# appends to ~/.zshrc). compinit has already run via zimfw by the time
# conf.d files are sourced, which the completions require.
if (( $+commands[wt] )); then
  eval "$(command wt config shell init zsh)"

  # Agent launchers: worktree + agent in one go. Shell aliases rather than
  # wt aliases because --execute replaces the wt process and needs the real
  # terminal (upstream disables it inside wt alias bodies).
  #   wsc feature-x -- 'Fix the pagination bug'
  alias wsc='wt switch --create --execute=claude'
  alias wsx='wt switch --create --execute=codex'
fi

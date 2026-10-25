# Worktrunk (wt) shell integration — wraps wt in a shell function so
# `wt switch` can cd and `--execute` can run in this shell, and registers
# completions. Managed here instead of `wt config shell install` (which
# appends to ~/.zshrc). compinit has already run via zimfw by the time
# conf.d files are sourced, which the completions require.
if (( $+commands[wt] )); then
  eval "$(command wt config shell init zsh)"

  # `wt issue` must NOT go through the wt binary. The binary dispatches custom
  # subcommands as child processes and stays alive as the pane's foreground
  # process, sitting in the directory it was invoked from. herdr reads the
  # pane's cwd from that outermost process, so every cwd-based reviewer
  # (reviewr cmd+r, tuicr cmd+shift+r, hunk prefix+shift+h) opened on the
  # main checkout instead of the worktree and showed no changes. Calling the
  # wt-issue script directly leaves zsh -> wt-issue, and wt-issue execs the
  # agent inside the worktree, so the agent is the foreground process.
  # The cd directive file is still honoured for `--no-agent`, whose
  # `exec wt switch` writes the worktree path into it.
  functions[_wt_upstream]=$functions[wt]
  wt() {
    if [[ "${1:-}" == issue ]]; then
      shift
      local cd_file exit_code=0
      cd_file="$(mktemp)"
      WORKTRUNK_DIRECTIVE_CD_FILE="$cd_file" command wt-issue "$@" || exit_code=$?
      if [[ -s "$cd_file" ]]; then
        builtin cd -- "$(<"$cd_file")" || exit_code=$?
      fi
      command rm -f "$cd_file"
      return "$exit_code"
    fi
    _wt_upstream "$@"
  }

  # Agent launchers: worktree + agent in one go. Shell aliases rather than
  # wt aliases because --execute replaces the wt process and needs the real
  # terminal (upstream disables it inside wt alias bodies).
  #   wsc feature-x -- 'Fix the pagination bug'
  alias wsc='wt switch --create --execute=claude'
  alias wsx='wt switch --create --execute=codex'
fi

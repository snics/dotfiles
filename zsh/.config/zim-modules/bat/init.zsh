local bat_theme
zstyle -s ':zim:plugins:bat' theme bat_theme

export BAT_THEME="${bat_theme}"

# On Ubuntu/Debian the `bat` program is named `batcat`.
if command -v batcat >/dev/null 2>&1; then
  typeset -g _bat_bin="$(which batcat)"
elif command -v bat >/dev/null 2>&1; then
  typeset -g _bat_bin="$(which bat)"
else
  return 1
fi

# Save the original system `cat` under `rcat`
alias rcat="$(which cat)"

export MANPAGER="sh -c 'col -bx | ${_bat_bin:t} -l man -p --theme='${bat_theme}'"

# Smart cat: bat for text, chafa for images, but EXACT POSIX cat semantics
# whenever anything other than a human at this terminal is consuming the
# output. Guards (in order):
#   1. _pretty_tty (00-init.zsh): pipes, redirects, scripts, and AI-agent
#      shells (Claude Code, Codex, opencode, Gemini, Cursor, ... — see
#      _agent_shell) get `command cat` untouched. Agent harnesses snapshot
#      interactive functions into their shells, so this is checked at
#      runtime, not load time.
#   2. Any dash argument: real cat flags like -b/-e/-t/-v/-E/-T are errors
#      in bat and -n/-A silently change format — a flag means the user
#      wants real cat. bat stays reachable as `bat`, plain cat as `rcat`.
#   3. No file arguments or `-`: stdin streaming belongs to real cat.
cat() {
  emulate -L zsh
  if ! _pretty_tty; then
    command cat "$@"
    return $?
  fi
  local a
  for a in "$@"; do
    [[ $a == -- ]] && break
    if [[ $a == -?* || $a == - ]]; then
      command cat "$@"
      return $?
    fi
  done
  if (( $# == 0 )); then
    command cat
    return $?
  fi

  # Pretty path (guaranteed tty): per-file dispatch by mime type.
  local f mime ret=0
  for f in "$@"; do
    [[ $f == -- ]] && continue
    if (( $+commands[chafa] )) && [[ -f $f || -L $f ]]; then
      mime=$(command file -bL --mime-type -- "$f" 2>/dev/null)
      if [[ $mime == image/* ]]; then
        command chafa --format kitty --animate off -- "$f" || ret=$?
        continue
      fi
    fi
    "$_bat_bin" --paging=never -- "$f" || ret=$?
  done
  return $ret
}

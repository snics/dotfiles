# Extra completions (bashcompinit-based, must load after compinit)
autoload -U +X bashcompinit && bashcompinit

# Jujutsu (jj) dynamic completions — context-aware (branches, revsets, etc.)
if (( $+commands[jj] )); then
  source <(COMPLETE=zsh jj)
fi

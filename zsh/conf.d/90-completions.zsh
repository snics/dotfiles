# Extra completions (bashcompinit-based, must load after compinit)
autoload -U +X bashcompinit && bashcompinit
[[ -x /opt/homebrew/bin/tofu ]] && complete -o nospace -C /opt/homebrew/bin/tofu tofu
[[ -x /opt/homebrew/bin/mc ]] && complete -o nospace -C /opt/homebrew/bin/mc mc

# Google Cloud SDK
[[ -f /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ]] && \
  source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

# Jujutsu (jj) dynamic completions — context-aware (branches, revsets, etc.)
# Overrides the static _jj from Homebrew site-functions.
if (( $+commands[jj] )); then
  source <(COMPLETE=zsh jj)
fi

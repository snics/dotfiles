# Extra completions (bashcompinit-based, must load after compinit)
autoload -U +X bashcompinit && bashcompinit
[[ -n "${HOMEBREW_PREFIX:-}" && -x "$HOMEBREW_PREFIX/bin/tofu" ]] && complete -o nospace -C "$HOMEBREW_PREFIX/bin/tofu" tofu
[[ -n "${HOMEBREW_PREFIX:-}" && -x "$HOMEBREW_PREFIX/bin/mc" ]] && complete -o nospace -C "$HOMEBREW_PREFIX/bin/mc" mc

# Google Cloud SDK
[[ -n "${HOMEBREW_PREFIX:-}" && -f "$HOMEBREW_PREFIX/Caskroom/gcloud-cli/latest/google-cloud-sdk/completion.zsh.inc" ]] && \
  source "$HOMEBREW_PREFIX/Caskroom/gcloud-cli/latest/google-cloud-sdk/completion.zsh.inc"

# Jujutsu (jj) dynamic completions — context-aware (branches, revsets, etc.)
# Overrides the static _jj from Homebrew site-functions.
if (( $+commands[jj] )); then
  source <(COMPLETE=zsh jj)
fi

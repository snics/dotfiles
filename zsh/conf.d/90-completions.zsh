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

# Zed CLI completions (static clap script — cached to avoid spawning zed on
# every shell; regenerated only when the zed binary is newer than the cache).
if (( $+commands[zed] )); then
  _zed_comp="$ZSH_CACHE_DIR/completions/_zed"
  if [[ ! -s "$_zed_comp" || "$commands[zed]" -nt "$_zed_comp" ]]; then
    zed --completions zsh >| "$_zed_comp" 2>/dev/null
  fi
  [[ -s "$_zed_comp" ]] && source "$_zed_comp"
  unset _zed_comp
fi

# herdr completions (static clap script, herdr >= 0.7.2 — same caching
# strategy as zed above).
if (( $+commands[herdr] )); then
  _herdr_comp="$ZSH_CACHE_DIR/completions/_herdr"
  if [[ ! -s "$_herdr_comp" || "$commands[herdr]" -nt "$_herdr_comp" ]]; then
    herdr completion zsh >| "$_herdr_comp" 2>/dev/null
  fi
  [[ -s "$_herdr_comp" ]] && source "$_herdr_comp"
  unset _herdr_comp
fi

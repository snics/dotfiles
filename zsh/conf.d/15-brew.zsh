# Auto-regenerate ~/.Brewfile from split brew/Brewfile.* sources.
# Runs on every new shell, but only cats files when a source is newer.

_brew_srcdir="$HOME/.dotfiles/brew"

if [[ -d "$_brew_srcdir" ]] && ls "$_brew_srcdir"/Brewfile.* &>/dev/null; then
  _brew_regen=0
  if [[ ! -f "$HOMEBREW_BUNDLE_FILE" ]]; then
    _brew_regen=1
  else
    for f in "$_brew_srcdir"/Brewfile.*; do
      if [[ "$f" -nt "$HOMEBREW_BUNDLE_FILE" ]]; then
        _brew_regen=1
        break
      fi
    done
  fi

  if (( _brew_regen )); then
    cat "$_brew_srcdir"/Brewfile.* >| "$HOMEBREW_BUNDLE_FILE"
  fi

  unset _brew_regen
fi

unset _brew_srcdir

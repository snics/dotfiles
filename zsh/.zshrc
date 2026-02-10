# ── Pre-Zimfw init ──────────────────────
source ~/.dotfiles/zsh/conf.d/00-init.zsh

# ── Homebrew ────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Secrets (1Password CLI → disk cache → legacy fallback) ──
if command -v op &>/dev/null && [[ -f ~/.secrets.tpl ]]; then
  _secrets_cache="/tmp/.secrets-cache-$EUID"
  if [[ -f "$_secrets_cache" ]] && [[ $(find "$_secrets_cache" -mmin -60 2>/dev/null) ]]; then
    source "$_secrets_cache"
  else
    op inject -i ~/.secrets.tpl -o "$_secrets_cache" 2>/dev/null && chmod 600 "$_secrets_cache" && source "$_secrets_cache"
  fi
  unset _secrets_cache
elif [[ -e ~/.secrets ]]; then
  source ~/.secrets
fi

# ── Zimfw ───────────────────────────────
ZIM_HOME=~/.config/zim
ZDOTDIR=~/.config/zim
zstyle ':zim:zmodule' use 'degit'

if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ── Configuration ───────────────────────
for conf in ~/.dotfiles/zsh/conf.d/[1-9]*.zsh(N); do
  source "$conf"
done
unset conf

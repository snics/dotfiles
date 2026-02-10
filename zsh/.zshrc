# ── Pre-Zimfw init ──────────────────────
source ~/.dotfiles/zsh/conf.d/00-init.zsh

# ── Homebrew ────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Secrets (1Password CLI → legacy fallback) ──
# Secrets stay in RAM only — no disk cache. op's internal session (~30 min)
# reduces Touch ID prompts. For disk-cache variant (~5ms startup), see:
# https://github.com/Integralist/dotfiles — /tmp/.secrets-cache pattern
if command -v op &>/dev/null && [[ -f ~/.secrets.tpl ]]; then
  eval "$(op inject -i ~/.secrets.tpl 2>/dev/null)"
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

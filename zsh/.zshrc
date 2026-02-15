# ── Pre-Zimfw init ──────────────────────
source ~/.dotfiles/zsh/conf.d/00-init.zsh

# ── Homebrew ────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── Secrets (1Password CLI → legacy fallback) ──
# Secrets stay in RAM only — no disk cache.
# To avoid Touch ID on every new shell, enable in 1Password app:
#   Settings → Developer → "Integrate with 1Password CLI"
#   Settings → Security → Auto-Lock → 1-2 hours
# This lets the app act as auth agent — one Touch ID per session.
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

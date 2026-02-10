# ── Environment ─────────────────────────
source ~/.dotfiles/zsh/conf.d/00-env.zsh

# ── Homebrew ────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Secrets ─────────────────────────────
[[ -e ~/.secrets ]] && source ~/.secrets

# ── Configuration ───────────────────────
for conf in ~/.dotfiles/zsh/conf.d/[1-9]*.zsh(N); do
  source "$conf"
done
unset conf

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

# ── Post-Zimfw configuration ───────────
for conf in ~/.dotfiles/zsh/conf.d/post/*.zsh(N); do
  source "$conf"
done
unset conf

# ── TPM (Tmux Plugin Manager) ──────────
if command -v git &>/dev/null && [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

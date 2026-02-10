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

# ── fzf preview overrides ──────────────
export FZF_CTRL_T_OPTS="--bind ctrl-/:toggle-preview --preview 'if [[ -d {} ]]; then eza --tree --level 3 --icons=auto --color=always -a {}; else bat --style=numbers --color=always --line-range :500 {}; fi'"

# ── TPM (Tmux Plugin Manager) ──────────
if command -v git &>/dev/null && [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# ── Atuin (SQLite shell history) ────────
if (( $+commands[atuin] )); then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^E' _atuin_search_widget
fi

# ── Keybindings ─────────────────────────
bindkey -e  # Emacs keybindings

# ── Extra completions ───────────────────
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/tofu tofu
complete -o nospace -C /opt/homebrew/bin/mc mc

# Google Cloud SDK (must load after compinit)
[[ -f /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ]] && \
  source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

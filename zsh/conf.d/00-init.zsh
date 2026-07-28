# Pre-Zimfw initialization: environment variables and zstyles that
# plugins read during their init. Sourced explicitly before Zimfw.

# Editor
export EDITOR="nvim"

# True when this shell executes on behalf of an AI coding agent. One marker
# per tool (verified against installed binaries/source 2026-07):
#   CLAUDECODE / AI_AGENT        Claude Code (snapshots interactive zsh state!)
#   CODEX_THREAD_ID / CODEX_SANDBOX*  OpenAI Codex CLI
#   OPENCODE                     opencode
#   GEMINI_CLI                   Google Gemini CLI
#   CURSOR_AGENT                 Cursor CLI (CURSOR_TRACE_ID deliberately NOT
#                                checked: set in human Cursor terminals too)
#   AGENT                        emerging generic convention (opencode, Amp,
#                                Goose). NOTE: HERDR_ENV is the user's own
#                                multiplexer, never an agent marker.
_agent_shell() {
  [[ -n ${CLAUDECODE-}${AI_AGENT-}${AGENT-}${OPENCODE-}${CODEX_THREAD_ID-}${CODEX_SANDBOX-}${CODEX_SANDBOX_NETWORK_DISABLED-}${GEMINI_CLI-}${CURSOR_AGENT-} ]]
}

# True when a human is looking at this terminal — only then may replacement
# tools (bat, eza, chafa, zoxide) take over classic command names. False for
# pipes, redirects, scripts, and AI-agent shells. Checked at RUNTIME by the
# smart wrappers (cat, ls, tree, cd): agent harnesses may carry interactive
# functions into their shells, so load-time interactivity is not enough.
_pretty_tty() { [[ -t 1 && -o interactive ]] && ! _agent_shell }

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# Catppuccin Mocha theme for zsh-syntax-highlighting
source ~/.dotfiles/zsh/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Homebrew performance
# Skip auto-update before every install/upgrade (we run `brew update` explicitly in `update brew`)
export HOMEBREW_NO_AUTO_UPDATE=1
# Skip auto-cleanup after install (we run `brew cleanup` explicitly in `update brew`)
export HOMEBREW_NO_INSTALL_CLEANUP=1
# Use generated ~/.Brewfile so `brew bundle` works without --file
export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"

# fzf config file (Catppuccin Mocha theming)
export FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fzf/config"

# OMZ cache dir (required for docker/podman completion caching)
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

# ── Zim module zstyles (read during plugin init) ───────

# bat
zstyle ':zim:plugins:bat' theme 'Catppuccin-Mocha'

# eza
zstyle ':zim:plugins:eza' dirs-first 'yes'
zstyle ':zim:plugins:eza' header 'yes'
zstyle ':zim:plugins:eza' show-group 'yes'
zstyle ':zim:plugins:eza' icons 'yes'
zstyle ':zim:plugins:eza' size-prefix 'binary'
zstyle ':zim:plugins:eza' hyperlink 'yes'

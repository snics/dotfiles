# ── Pre-Zimfw init ──────────────────────
source ~/.dotfiles/zsh/conf.d/00-init.zsh

# ── Homebrew ────────────────────────────
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── Secrets (1Password CLI, one Touch ID per day via a daily cache) ──
# The first INTERACTIVE shell of the day resolves ~/.secrets.tpl via `op inject`
# (one Touch ID). The resolved script is cached mode-0600 in $TMPDIR with a 24h
# TTL; every later shell — Zed env probes, direnv hooks, agent shells — sources
# the cache silently (no `op` call, no prompt). $TMPDIR is per-user (0700) and
# cleared on reboot, so nothing lingers on disk long-term. A flock single-flight
# collapses Zed's concurrent startup shells into a single prompt.
# Force a fresh resolve (e.g. after rotating a secret) with: secrets-refresh
() {
  emulate -L zsh
  zmodload zsh/datetime zsh/stat zsh/system 2>/dev/null

  local tmp="${TMPDIR:-/tmp}"; tmp="${tmp%/}"
  local cache="$tmp/.secrets-cache.${UID}.zsh"
  local lock="$cache.lock"
  local -i ttl=86400
  local -a st

  # Fast path: fresh cache (< ttl) → source in ANY shell, silent, no op call.
  if [[ -f $cache ]] && zstat -A st +mtime -- $cache 2>/dev/null \
     && (( EPOCHSECONDS - st[1] < ttl )); then
    source $cache
    return
  fi

  # No fresh cache below. Only interactive shells may raise a Touch ID prompt;
  # non-interactive shells fall back to a stale cache if one exists.
  if [[ ! -o interactive ]]; then
    [[ -f $cache ]] && source $cache
    return
  fi

  if ! command -v op &>/dev/null; then
    [[ -e ~/.secrets ]] && source ~/.secrets   # legacy plaintext fallback
    return
  fi
  [[ -f ~/.secrets.tpl ]] || return

  # Single-flight: the first interactive shell resolves (one Touch ID); concurrent
  # Zed/terminal shells block on the lock, then reuse the freshly written cache.
  : > $lock 2>/dev/null
  local lockfd
  if zsystem flock -t 15 -f lockfd $lock 2>/dev/null; then
    if ! { [[ -f $cache ]] && zstat -A st +mtime -- $cache 2>/dev/null \
           && (( EPOCHSECONDS - st[1] < ttl )); }; then
      local out="$cache.$$"
      if op inject -i ~/.secrets.tpl -o $out 2>/dev/null; then
        chmod 600 $out && mv -f $out $cache
      else
        rm -f $out
      fi
    fi
    zsystem flock -u $lockfd 2>/dev/null
  fi
  [[ -f $cache ]] && source $cache
}

# Clear the daily secret cache so the next new shell re-resolves (one Touch ID).
secrets-refresh() {
  local tmp="${TMPDIR:-/tmp}"; tmp="${tmp%/}"
  rm -f "$tmp"/.secrets-cache.${UID}.zsh(N)
  print -r -- "secrets cache cleared — next new shell will re-resolve (one Touch ID)"
}

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

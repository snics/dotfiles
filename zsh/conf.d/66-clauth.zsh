# ── clauth ──────────────────────────────────────────────────
# Completions. `clauth completions --install` writes a `source` line with an
# absolute path into ~/.zshrc — which is a stow symlink, so that write lands in
# this repository and hardcodes one machine's home directory. Sourced here with
# $HOME instead. Never accept that installer's offer; re-point this line if the
# generated file moves.
[[ -r "$HOME/.clauth/completions/clauth.zsh" ]] && source "$HOME/.clauth/completions/clauth.zsh"

# ── clauth daemon ───────────────────────────────────────────
# clauth's daemon keeps the 5h/7d usage windows fresh and performs rolling
# OAuth token maintenance, which otherwise only happens while the TUI is open.
# It is started with the first herdr pane and left to the OS on exit.
#
# It CANNOT switch accounts: next_auto_switch_target locates the active profile
# in the fallback chain and returns None when it is not a member, and the chain
# is empty (clauth/.clauth/profiles.toml). Do not add one — that empty list is
# the only thing keeping the daemon inert. See clauth/AGENTS.md.

() {
    # HERDR_ENV is herdr's own marker for "this shell runs inside a pane".
    # (There is no HERDR_SESSION_ID — herdr exports PANE/TAB/WORKSPACE ids.)
    [[ -n "${HERDR_ENV:-}" ]] || return
    command -v clauth &>/dev/null || return

    # No enrolled account means nothing to poll and no token to refresh, so
    # don't spawn a scheduler that would idle until the first `clauth login`.
    [[ -n "$(ls -A "$HOME/.clauth/profiles" 2>/dev/null)" ]] || return

    local lock="${TMPDIR:-/tmp}/clauth-daemon.pid"

    # Claim the lockfile atomically: two panes starting together both see it
    # missing, so the create itself has to be the gate rather than a preceding
    # existence check. A lockfile left behind by a killed daemon self-heals via
    # the liveness check below.
    if ( umask 077; set -o noclobber; echo $$ > "$lock" ) 2>/dev/null; then
        clauth daemon &>/dev/null &
        echo $! >| "$lock"
    elif ! kill -0 "$(<"$lock" 2>/dev/null)" 2>/dev/null; then
        rm -f "$lock"
        clauth daemon &>/dev/null &
        echo $! >| "$lock"
    fi
}

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
#
# "Inert" covers switching only. This daemon is also the machine's ONLY token
# rotator: Daemon::boot relinks the active profile's credentials into the login
# Keychain on every start, and its scheduler holds the usage-fetch lease for
# life and rotates the active token ahead of expiry. `clauth mcp` runs no
# scheduler at all and refreshes nothing.
#
# Its diagnostics all go to stderr — "refresh for <n> failed", "flagged
# auth_broken", "the Keychain mirror failed", "the live login diverged". They
# used to be sent to /dev/null, which meant the one process that can sign
# Claude Code out was also the one process we could not observe. clauth
# size-caps this file itself (log_rotate::rotate_log_if_large), so it cannot
# grow unbounded.
#
# `>>|` and not `>>`: noclobber is set in this shell, and under it a plain `>>`
# fails outright when the target does not yet exist — which is exactly the
# first-run case, so the daemon would never have started at all.

() {
    # HERDR_ENV is herdr's own marker for "this shell runs inside a pane".
    # (There is no HERDR_SESSION_ID — herdr exports PANE/TAB/WORKSPACE ids.)
    [[ -n "${HERDR_ENV:-}" ]] || return
    command -v clauth &>/dev/null || return

    # No enrolled account means nothing to poll and no token to refresh, so
    # don't spawn a scheduler that would idle until the first `clauth login`.
    [[ -n "$(ls -A "$HOME/.clauth/profiles" 2>/dev/null)" ]] || return

    # clauth enforces a single instance itself ("already running (pid N);
    # exiting"), so it is the only lock needed. A PID lockfile used to sit in
    # front of it and broke itself: a pane that lost the race wrote the PID of
    # its own short-lived, immediately-exiting daemon, so every later pane saw
    # a dead PID and spawned again. Ask the process table instead, so a normal
    # new pane spawns nothing.
    pgrep -qf '^clauth daemon' && return

    # `&!` disowns the daemon: no "[n] pid" on start, no "done" on exit.
    clauth daemon >>| "$HOME/.clauth/daemon.log" 2>&1 &!
}

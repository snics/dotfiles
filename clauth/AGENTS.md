# clauth — Agent Instructions

Tracked config for [clauth](https://github.com/uwuclxdy/clauth), a multi-account
manager for Claude Code. Design and rationale:
`docs/superpowers/specs/2026-08-30-clauth-integration-design.md`.

## This is not a stow package

`clauth/.clauth/profiles.toml` mirrors the path it targets, but nothing here is
symlinked. clauth rewrites `profiles.toml` in place, which would destroy a stow
symlink on first write — the same reason `claude/.claude/settings.json` is
copied. `.stow-local-ignore` exists purely so an accidental `stow clauth`
cannot cause that breakage.

- **Bootstrap:** `_install/clauth.sh` (`just clauth`) copies the template only
  when `~/.clauth/profiles.toml` does not exist.
- **Sync back:** `just clauth-sync` after clauth has changed the live file
  (profile ordering, the active marker), then review the diff and commit.

## Scope: profiles.toml only

Never track, copy, or link anything else under `~/.clauth/`. OAuth tokens live
in `~/.clauth/profiles/<name>/credentials.json`, and per-profile `config.toml`
may hold API keys. `profiles.toml` itself is secret-free.

### Profile names become public

This repository is public, and `just clauth-sync` copies `profiles.toml` into
it. Everything else in that file is a boolean, a number or an enum — the only
free-form values are the profile names, which appear in `profiles`,
`active_profile`, `fallback_chain` and `auth_broken` (`ProfileName` is a plain
`String`).

So name profiles neutrally — `personal`, `work`, `alt`. Never an email address,
a client name, or an employer's name: `clauth login <name>` is the one moment
where a careless choice ends up on GitHub.

## Guardrails

These are not style preferences — each one prevents a specific, verified
failure:

- **Never run `clauth herdr install` without `--no-config`.** It appends its
  keybinding and sidebar row to herdr's `config.toml`, which is a stow symlink,
  so the write lands in this repository unreviewed. `_install/clauth.sh` always
  passes the flag.
- **Keep `uwuclxdy/clauth/herdr-plugin` in Herdr Lazy's `plugins.list`.** The
  installer still registers the plugin with `--no-config`, while the
  declarative entry prevents `herdr-lazy sync --prune` from removing it again.
- **Keep `fallback_chain` empty.** It was tried with `private` in it on
  2026-09-01 and deliberately removed again, because the trade turned out to be
  bad on this platform:

  - It does **not** rescue a running session. `clauth start --with-fallback` is
    refused on macOS (`swap_support()` → `KeychainFirst`, because Claude Code
    resolves credentials keychain-first). All a switch achieves is that the
    *next* session starts on an account with headroom — a manual
    `clauth start <other>` does the same thing, when you want it.
  - Every switch does a read-modify-write on the login Keychain item, which
    also holds every MCP server's OAuth login (`src/keychain.rs`). That is a
    standing risk in exchange for saving one command.
  - Every switch also rewrites `~/.claude/settings.json`. The early-exit in
    `apply_profile_to_claude_settings` only fires when the file does not exist,
    so it rewrites unconditionally. Harmless while no profile sets `model`,
    `env` or `apiKeyHelper` — set any of them and a switch starts moving them.
  - Auto-hopping accounts at their limits is also the only part of this tool
    that sits near Anthropic's usage policy. Holding two accounts is fine;
    switching to evade a limit is the part that is not clearly fine.

  The empty chain is what keeps the daemon inert: `next_auto_switch_target`
  returns `None` when the active profile is not a chain member.

  **"Inert" covers account switching only.** Verified against the pinned
  commit on 2026-09-05 while investigating repeated logouts:

  - `Daemon::boot` calls `link_profile_credentials(active)` on every start
    (`src/daemon/mod.rs:433-435`) — the same read-modify-write of the login
    Keychain item this file warns about for switches, performed once per
    herdr session start without any switch.
  - Its scheduler wins `usage-fetch.lock` and holds it for the process
    lifetime, making the daemon the machine's only routine token rotator.
    With `preemptive_rotation` defaulting to true, it rotates the active
    token ~15 minutes ahead of expiry, deliberately ahead of Claude Code's
    own 5-minute threshold.
  - `clauth mcp` runs **no** scheduler (`src/mcp/mod.rs:5111-5122`) and
    refreshes nothing, however many sessions are open. The recurring
    "another instance holds the usage-fetch lease" lines in `clauth.log`
    are TUI launches losing the lease to the daemon — expected, not a fault.

  Two operational notes if this is ever revisited: `fallback_chain.push` has
  exactly one call site (`add_chain_candidate`, one TUI action), so it never
  fills itself — but it is one keystroke away, and it filled twice during
  setup. And stop the daemon before editing the chain by hand, or a running one
  can write its own state back over the edit.
- **Never run a global switch** — `clauth <profile>`, or the MCP
  `switch_profile` tool. It rewrites `model`, `env` and `apiKeyHelper` into
  `~/.claude/settings.json` and does a read-modify-write on the login Keychain
  item, which also holds every MCP server's OAuth login.
- **The keybinding is `prefix+d`, not clauth's default `prefix+a`.** That key
  is bound to `next_agent` in `herdr/.config/herdr/config.toml`. When checking
  a herdr key for conflicts, grep the bare key string: built-in actions bind as
  `<action> = "prefix+…"` while plugin actions use `key = "prefix+…"`, and
  checking only the latter is how `prefix+a` was once wrongly believed free.

## Two things clauth did on its own during setup

Both were caught after the fact and are worth knowing before the next install:

- **`clauth completions --install` writes into `~/.zshrc`** with an absolute
  path. That file is a stow symlink, so the write lands in this repository and
  hardcodes one machine's home directory. Decline that offer; the completions
  are sourced from `zsh/conf.d/66-clauth.zsh` with `$HOME` instead.
- **`fallback_chain` came back populated during setup.** That single line is
  what arms the daemon's auto-switch, so it had to be emptied again.

  It does NOT repopulate on its own: `fallback_chain.push` has exactly one call
  site in the whole codebase (`add_chain_candidate`, reached from one TUI
  action), and neither `clauth login` nor the daemon nor any CLI path touches
  it. So the empty chain is a real defense rather than a snapshot — but it is
  one TUI keystroke from being undone, and nothing enforces it. Check it after
  spending time in the TUI, not after every login.

Note also that comments do **not** survive: clauth rewrites `profiles.toml`
without them, so every `just clauth-sync` strips whatever was written there.
That is why these rules live in this file and not in the config.

## The rolling token — why Claude Code stopped logging out

Armed on 2026-09-05 for both profiles after a run of twelve `Login expired`
events in five days (zero in the whole period before clauth was installed).

**The mechanism it fixes.** Anthropic's refresh token is single-use: each
refresh mints a new pair and kills the old one, so exactly one party can carry
a chain. clauth deliberately rotates ~15 minutes ahead of expiry to stay ahead
of Claude Code's own 5-minute threshold, which makes clauth the carrier — and
it then has to hand the new pair to Claude Code through the login Keychain.
That handoff is skipped whenever `live_login_is_foreign` fires
(`src/oauth.rs:1623`): it tolerates a live `.credentials.json` exactly one
rotation behind, and treats anything older as a real re-login it must not
overwrite. Ours drifted several rotations behind, because Claude Code rewrites
that file as a plain regular file on every run and only on every run. So clauth
spent the refresh token, kept the new pair to itself, and left the Keychain
holding a dead one. Next refresh: `invalid_grant`, session signed out.

**What the rolling token changes.** `clauth rolling-token <profile>` serves
sessions a bearer from the usage chain with **no refresh token**, re-stamped by
the daemon before it expires (`restamp_rolling_token`, `src/oauth.rs:2359`).
For the *active* profile it is also mirrored into the login Keychain, guarded
by `creds.refresh_token().is_none()` — so bare `claude` sessions get it too,
not just `clauth start` ones. Claude Code then has nothing to refresh and
cannot hit `invalid_grant`. The rotating chain stays clauth-private in
`profiles/<name>/credentials.json`. It removes the handoff instead of trying to
make it reliable.

**This is not reproducible from this repo.** `rolling_token = true` lives in
`~/.clauth/profiles/<name>/config.toml`, which is deliberately untracked (it
can hold API keys). After `clauth login <name>` on a new machine, run
`clauth rolling-token <name>` by hand, per profile. Nothing in `_install/` does
it for you.

**Three consequences to keep in mind:**

- **The daemon is now load-bearing.** The bearer dies in hours and only the
  daemon re-stamps it. Before this it merely kept usage numbers fresh; now
  stopping it eventually stops the sessions. `zsh/conf.d/66-clauth.zsh` starts
  it with the first herdr pane and logs to `~/.clauth/daemon.log`.
- **It widens scopes.** The rolling bearer carries five scopes
  (`user:file_upload`, `user:inference`, `user:mcp_servers`, `user:profile`,
  `user:sessions:claude_code`) where the `claude setup-token` mint it
  supersedes carried two. Anything that can read the session credential can use
  all five.
- **`clauth static-token <profile>` reverts it**, restoring the mint.

Requires v0.15.0+ for the rolling token and v0.15.1 for `fa5f4ed`, which stops
a rotation re-stamping a cleared rolling token. Do not move the pin below that.

## Editing profiles.toml by hand

Two traps, both hit during the initial setup:

- `pane_tag` and `border_label` are **booleans** (`true`/`false`). The CLI
  prints them as `on`/`off` via `clauth herdr config get`, but a string value
  fails to parse.
- Top-level keys (`profiles`, `fallback_chain`) must stay **above** the
  `[herdr]` table. TOML assigns every key after a table header to that table,
  so moving them down silently turns them into herdr knobs.

There is no CLI setter for the `[herdr]` knobs — only `clauth herdr config get`.
Edit the file, or use the TUI's Setup tab.

## Logouts and the "live login no longer matches" banner

Diagnosed 2026-10-23 — evidence and timeline in
`_planning/clauth-relogin-diagnosis.md`.

- **The banner was expected up to 0.15.1 and is fixed at the current pin**
  (`df5410c`, #104/#105). Quitting the TUI used to freeze
  `~/.claude/.credentials.json` as a plain copy that drifted from the
  Keychain; now each daemon re-stamp refreshes that copy. The fix only works on
  a file whose token clauth recognises, so after the bump the stale banner has
  to be resolved **once** more.
- **Resolve it with `d` → "discard this login and restore '<active>'".**
  Never choose the first row, "overwrite '<active>' with this login": it
  stores the expired, refresh-less bearer as the profile's credentials and
  breaks that profile's chain, so `clauth login` becomes necessary. Never set
  `default_divergence = Overwrite`.
- **Real logouts come from the daemon not running.** The rolling bearer lives
  ~8 h and only the daemon re-stamps it. Its watchdog exits after sleep/wake
  "for a clean launchd restart", and it has died silently too; the herdr-pane
  spawn only brings it back with the next new pane.
  `_install/clauth-daemon.sh` (`just clauth-daemon`) installs a launchd agent
  (`com.dotfiles.clauth-daemon`, `KeepAlive`, `clauth daemon --standby`) —
  loading it starts a daemon, so it is a deliberate step, not part of
  bootstrap. The herdr-pane spawn stays as fallback; the singleton lock and
  `--standby` handle duplicates.
- `clauth login` is only needed when `daemon.log` shows `auth_broken` or an
  HTTP 400 on refresh; a merely expired bearer recovers on the daemon's next
  tick.
- **The clauth Claude Code plugin is installed** (since 2026-10-07) and kept
  on purpose (decided 2026-10-25). Its hooks run on every prompt and tool use
  and `self-heal` on SessionStart (upstream #134). Since 0.17 it also loads
  `register.ts` into every session (T3 included, the homes share `plugins`): a
  bridge to `~/.clauth/bridge.sock` that stays inert without `daemon --listen`
  and a paired device. `clauth which` and the plugin's hook cache the whole
  Keychain item for a session's config dir in `~/.clauth/keychain-which-cache/`
  (0600, swept after a day) — for T3 sessions that is T3's own login. Manage
  it in the TUI's **Services tab** (formerly "Plugin tab").
- **Auto-update gate — keep both halves.** From 0.17 the daemon and
  `clauth mcp` reinstall the herdr plugin at clauth's latest release tag
  whenever the installed commit differs, every 30 min — that fights Herdr
  Lazy's lock forever. `[update] auto_update = false` in `profiles.toml`
  (tracked) plus `CLAUTH_NO_UPDATE=1` (`66-clauth.zsh`, launchd plist) stop it.
  A 0.15.x binary drops the `[update]` table on its next save, so after a
  rollback re-add it.
- **Never pin v0.15.2** — its `clauth mcp` deletes Keychain items it did not
  create (#81), which would include T3 Code's per-instance logins
  (`t3/AGENTS.md`). v0.16.0+ deletes only items in its own ledger and carries
  the `security -i` truncation fix (`be5c39e2`, superseded PR #66), so the old
  "no global OAuth MCP servers" rule could be relaxed — a separate decision.

## Version pinning

clauth is installed from a **git commit**, not crates.io: the published 0.14.1
does not contain the herdr subcommand at all. See the entry and its reasoning
in `_install/cargo-tools.list`. To move the pin, review the new commit and edit
that file — `just cargo-tools-update` deliberately skips pinned git entries.

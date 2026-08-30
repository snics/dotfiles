# clauth Integration — Design

**Date:** 2026-08-30
**Status:** Approved, ready for implementation planning
**Tool:** [uwuclxdy/clauth](https://github.com/uwuclxdy/clauth) — multi-account manager for Claude Code

## Goal

Run two Claude accounts side by side from herdr, see each account's usage
windows without leaving the terminal, and delegate work to the second account
from inside a chat — without clauth writing into any config this repository
manages.

## Decisions

### Side-car, not owner

clauth manages only `~/.clauth/`. Secondary accounts run exclusively through
`clauth start <profile>`, which spawns `claude` against that session's own
runtime directory. The primary account is never touched: plain `claude` does
not go through clauth, and the global profile pointer is never relinked.

This is a deliberate trade. Auto-fallback is **dropped**, and three findings
from the source justify that:

1. `switch_profile` (`src/actions.rs`) is the only auto-switch mechanism —
   it relinks the live credentials globally. There is no per-account path.
2. Per-session fallback (`clauth start --with-fallback`) is refused on macOS
   unconditionally. `swap_support()` in `src/runtime.rs` returns
   `SwapUnsupported::KeychainFirst` because Claude Code resolves credentials
   keychain-first there, so swapping the file under a live session does
   nothing.
3. Therefore auto-fallback can never rescue a running session on this machine.
   Its best case is "the next session starts on a fresh account" — a benefit
   paid for by clauth rewriting `model`, `env` and `apiKeyHelper` into
   `~/.claude/settings.json` on every switch (documented in
   `src/settings_sync.rs`), and by read-modify-write surgery on the login
   Keychain item that also holds every MCP server's OAuth login
   (`src/keychain.rs`).

The inverse is what makes the side-car clean: those rewrites happen *only* on
switch, and the cross-profile settings sync short-circuits with no live
isolated session. With no global switches, the drift is not small — it is zero.

### clauth writes nothing this repo manages

Every integration point is hand-authored into the repository and applied by
stow or an install script. This mirrors the guardrail already in place for
Hunk, whose `setup-keys` action writes through the stow symlink.

| Surface | Mechanism |
|---------|-----------|
| herdr keybinding + sidebar row | hand-written into the stowed `config.toml` |
| clauth's own knobs | `clauth/` stow package, copy-not-symlink |
| MCP server registration | entry in `claude/mcp-servers.json` |

## Components

### 1. Install

`clauth` is declared in `_install/cargo-tools.list` and installed by
`_install/cargo-tools.sh` via `cargo binstall`. No separate mechanism —
this is what the cargo inventory was built for.

### 2. Plugin registration — `_install/clauth.sh`

Runs `clauth herdr install --no-config -y`. The `--no-config` flag installs
the plugin and leaves herdr's `config.toml` untouched, which is precisely the
separation this design needs. Idempotent; exposed as `just clauth` /
`make clauth`.

The plugin ships inside the clauth binary rather than as a GitHub repository,
so it does **not** appear in `herdr/.config/herdr/plugins.list`. That list
would otherwise read as a complete inventory of installed plugins, so its
header must name clauth as a known exception.

### 3. herdr configuration — hand-written

In `herdr/.config/herdr/config.toml`:

- `[[keys.command]]` binding `prefix+a` to the `clauth.open` plugin action.
  The key is free: it is neither a herdr built-in (verified against the
  binary's default list) nor bound by any existing plugin.
- `[ui.sidebar.agents.rows_by_agent]` with `$clauth` in the claude row. No
  such table exists in the config today, so it is added whole.

`_docs/keybindings.md` gains a clauth section per the repository's sync rule.

### 4. `clauth/` stow package

`~/.clauth/profiles.toml` holds profile ordering, the active marker, and the
`[herdr]` knobs — no secrets (tokens live in the macOS Keychain). clauth
rewrites the file in place, which would break a stow symlink on first write,
exactly as Claude Code's `settings.json` does.

The package therefore follows the `claude/` precedent: the file is listed in
`.stow-local-ignore`, copied into place by `_install/clauth.sh` only when
absent, and copied back by `just clauth-sync` for review before committing.

Template values for `[herdr]`:

| Knob | Value | Reason |
|------|-------|--------|
| `pane_tag` | `on` | publishes the per-pane `clauth=$profile` tag |
| `border_label` | `off` | the sidebar tag is enough |
| `tag_watch_secs` | `3600` | see below |

The plugin spawns a detached watcher per Claude pane that re-publishes the tag
on a timer, defaulting to every 5 seconds. Its only purpose is to catch
account changes that fire no herdr event — a `--with-fallback` session moving
along the chain, or a bare `claude` after a global switch. Neither can occur
in this design, so the interval is raised to the maximum the plugin accepts.
The watcher cannot be disabled separately: it is gated on `pane_tag`, the same
knob that enables the tag itself.

A `clauth/AGENTS.md` records the guardrails so they survive the next person
(or agent) who touches this.

### 5. MCP — declarative

`claude/mcp-servers.json` gains:

```json
"clauth": { "type": "stdio", "command": "clauth", "args": ["mcp"] }
```

This is the canonical stdio entry clauth would otherwise write itself
(`src/plugin_probe.rs`), and `_install/claude.sh` merges it with jq like every
other server. It replaces the TUI's plugin install, which registers a
`SessionStart` hook that re-writes its own registration on every session start.

Exposed tools: `profiles`, `switch_profile`, `delegate`, `monitor`. Only
`delegate` and `profiles` are useful here — `switch_profile` relinks globally
and must not be called.

## Explicitly out of scope

- **`clauth daemon`.** Its jobs are executing queued auto-switches (dropped),
  publishing `status.json` as an external read feed (nothing consumes it — the
  sidebar tag is a profile name and the popup is the live TUI), and picking up
  external config changes. Nothing here needs a background process.
- **Global profile switching** (`clauth <profile>`), for the Keychain and
  `settings.json` reasons above.
- **`clauth start --with-fallback`**, refused on macOS.

## Verification

| Check | Passes when |
|-------|-------------|
| `herdr plugin list` | lists clauth |
| `git diff herdr/.config/herdr/config.toml` after install | empty — proves `--no-config` holds |
| `prefix+a` | opens the clauth popup |
| sidebar after `clauth start <profile>` | shows the `clauth=<profile>` tag |
| `clauth mcp` | answers a `server/discover` handshake |
| `git status` after a clauth session | clean — proves zero drift |
| `just check` | the new stow package links without conflict |

## Requires the user

`clauth login <profile>` per account — an interactive browser OAuth flow that
cannot be automated.

## Open follow-ups

- Revisit auto-fallback if clauth ever gains a macOS path (the blocker is
  Claude Code's keychain-first resolution, not clauth's design).
- `tag_watch_secs = 3600` is a workaround for a watcher that has no job in a
  side-car setup. A `pane_tag`-without-watcher knob would be a reasonable
  upstream feature request.

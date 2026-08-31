# clauth Integration — Design

**Date:** 2026-08-30 (revised 2026-08-31 after review)
**Status:** Revised, awaiting review
**Tool:** [uwuclxdy/clauth](https://github.com/uwuclxdy/clauth) — multi-account manager for Claude Code

## Goal

Run two Claude accounts side by side from herdr, see each account's usage
windows without leaving the terminal, and delegate work to the second account
from inside a chat — while keeping clauth out of the config this repository
manages, as far as the tool actually allows.

That last clause is deliberate. The first revision of this document claimed
the isolation was total. It is not, and the exceptions are named below rather
than designed around.

## Decisions

### Side-car, not owner

clauth manages `~/.clauth/`. Secondary accounts run through
`clauth start <profile>`, which spawns `claude` against that session's own
runtime directory. Plain `claude` never goes through clauth, and no global
profile switch is ever performed after setup.

Auto-fallback is **dropped**, because on this machine it cannot work:

`clauth start --with-fallback` is refused unconditionally on macOS —
`swap_support()` (`src/runtime.rs`) returns `SwapUnsupported::KeychainFirst`
because Claude Code resolves credentials keychain-first, so repointing a
session's credential file changes nothing. The per-session mechanism itself
exists (`SessionSwap`, `src/runtime.rs`, driven by the daemon's
`intended_member`); macOS is what blocks it, not its absence.

That leaves the global relink (`switch_profile`, `src/actions.rs`) as the only
usable switch, and it rewrites the active profile's managed env keys,
`apiKeyHelper` and `model` into `~/.claude/settings.json` on every switch
(`src/settings_sync.rs`) while performing read-modify-write surgery on the
login Keychain item that also holds every MCP server's OAuth login
(`src/keychain.rs`). For a benefit that, on macOS, amounts to "the next
session starts on a fresh account", that is not worth it.

### What clauth still writes — the honest list

Avoiding switches removes the per-switch rewrite. It does **not** make the
integration write-free:

1. **The first `clauth login` links credentials globally.** `src/actions.rs`
   activates the new profile when `active_profile` is empty. Mitigated by
   enrollment order (below), not eliminated.
2. **Live `clauth start` sessions sync settings back.** `settings_sync::sync_once()`
   runs from every live session's watchdog `config()` leg (`src/runtime.rs`),
   not only on switch. The operator's `~/.claude/settings.json` is a sync
   member and the write-back target, so a shared setting changed inside a
   clauth session propagates into the global file. With no live session the
   engine short-circuits and nothing happens.
3. **Active-profile edits reapply managed fields** (endpoint, model, preset,
   env) without a switch (`src/actions.rs`). Avoided by not editing profiles
   through clauth once they are set up.

**Addendum, 2026-09-01 — the list above was incomplete.** Two further write
paths only surfaced during implementation, and both had already fired before
they were noticed:

4. **`clauth completions --install` appends to `~/.zshrc`** (`src/completions.rs`),
   which is a stow symlink, so the line landed in the repository complete with
   an absolute `/Users/<name>/…` path. It is offered automatically on the first
   interactive launch and gated by a sentinel at `~/.clauth/.completions_installed`,
   so it asks once. Decline it; completions are sourced from
   `zsh/conf.d/66-clauth.zsh` using `$HOME`.
5. **The TUI populates `fallback_chain`**, which is the one thing arming the
   daemon's auto-switch. It does not fill itself — `fallback_chain.push` has a
   single call site (`add_chain_candidate`) reached from one TUI action — but
   it filled twice during setup.

An enumeration afterwards showed there is no sixth path: of every file clauth
can write outside `~/.clauth`, exactly two are stow symlinks into this
repository (`~/.zshrc` and herdr's `config.toml`), and both are now defended.
`~/.claude/settings.json` and `~/.claude.json` are regular files, so writes
there reach the repository only through an explicit sync.

The lesson generalizing beyond clauth: a tool that promises not to touch your
config can still reach it through paths you did not enumerate. Diffing the
tool's write targets against the symlink set is what settles the question —
reading its documentation is not.

Point 2 matters because `claude/AGENTS.md` defines `~/.claude/settings.json`
as copied into the repo by `just claude-sync`: a later sync can import
clauth-influenced changes. This is drift the repository can see and review —
unlike the per-switch rewrite, which would recur silently — but it is drift,
and the previous "zero drift" claim was wrong.

### Enrollment order

The first login seeds the active profile. Therefore:

1. Enroll the **primary** account first. The global pointer ends up on the
   account it already effectively points at, so the steady state is unchanged.
2. Enroll the secondary account second. `active_profile` is now set, so it is
   not activated.

One-time cost, stated plainly: step 1 is a real browser OAuth flow that mints
fresh tokens and replaces the live credentials for that same account,
including a read-modify-write of the Keychain item shared with MCP logins.
There is no adoption path — a bare `clauth login` always runs OAuth. Verify
MCP servers still authenticate after this step.

## Components

### 1. Install

`clauth` is declared in `_install/cargo-tools.list` and installed by
`_install/cargo-tools.sh`. No separate mechanism.

### 2. Plugin registration — `_install/clauth.sh`

`clauth herdr install --no-config -y` installs the plugin and leaves herdr's
`config.toml` untouched (`src/herdr.rs` returns before resolving or writing
the config). Idempotent; exposed as `just clauth` / `make clauth`.

Because `--no-config` also skips clauth's own `herdr config check`, a
keybinding conflict in the hand-authored block is **not** caught by the tool.
The key below was therefore checked by hand against both binding syntaxes.

The plugin ships inside the clauth binary rather than as a GitHub repository,
so it does not appear in `herdr/.config/herdr/plugins.list`. That list would
otherwise read as a complete inventory, so its header must name the exception.

### 3. herdr configuration — hand-written

In `herdr/.config/herdr/config.toml`:

- `[[keys.command]]` binding **`prefix+d`** to the `clauth.open` plugin action.
  Not clauth's default (`prefix+a`), which is already bound to `next_agent`
  in this config. `prefix+d` and `prefix+i` are the only free single-letter
  prefix keys once herdr's built-in defaults and every existing binding are
  accounted for; `d` is taken for "dashboard".
- `[ui.sidebar.agents.rows_by_agent]` with `$clauth` in the claude row. No
  such table exists today, so it is added whole.

`_docs/keybindings.md` gains a clauth entry per the repository's sync rule.

### 4. `clauth/` stow package

Scope: **`profiles.toml` only.** The package must never reach
`~/.clauth/profiles/<name>/credentials.json`, which holds OAuth tokens, nor
per-profile `config.toml`, which may hold API keys.

`profiles.toml` itself is secret-free but holds more than configuration:
profile ordering, the active marker, fallback chains, thresholds, refresh
cadence, quarantine state, theme and display settings, plus the `[herdr]`
knobs. clauth rewrites it in place, so a stow symlink would break on first
write — the same failure mode as Claude Code's `settings.json`.

It therefore follows the `claude/` precedent: listed in `.stow-local-ignore`,
copied into place by `_install/clauth.sh` only when absent, copied back by
`just clauth-sync` for review before committing.

Template values for `[herdr]`:

| Knob | Value | Reason |
|------|-------|--------|
| `pane_tag` | `on` | publishes the per-pane `clauth=$profile` tag |
| `border_label` | `off` | the sidebar tag is enough |
| `tag_watch_secs` | `3600` | see below |

The plugin spawns a detached watcher per Claude pane that re-publishes the tag
every 5 seconds by default. Its only purpose is catching account changes that
fire no herdr event — a `--with-fallback` session, or a bare `claude` after a
global switch — neither of which can occur here. The interval is raised to the
watcher's clamp ceiling. It cannot be disabled separately: it is gated on
`pane_tag`, the knob that enables the tag itself.

**No fallback chain is configured.** This is load-bearing, not incidental —
see the daemon below.

`clauth/AGENTS.md` records the guardrails.

### 5. Daemon — kept, and inert by construction

`clauth daemon`, started with the first herdr session and ended with the last,
guarded by a PID lockfile in the manner of the existing `herdr-launch` wrapper.

The first revision dropped it. That was wrong: besides executing switches, the
daemon bootstraps usage caches, runs the same background refresher as the TUI,
and performs rolling-token maintenance that keeps session tokens from expiring
while idle (`src/daemon/mod.rs`, `src/usage/scheduler.rs`, `src/oauth.rs`).
Without it, usage figures are fresh only while the popup is open and no token
maintenance happens unattended — which directly undercuts "see usage without
leaving the terminal".

Its switching job stays inert without a feature flag:
`next_auto_switch_target` (`src/fallback.rs`) locates the active profile in
the chain with `position(...)?` and returns `None` when it is not a member.
With no chain configured, no switch can ever be produced. This is why §4 fixes
the empty chain as a requirement.

### 6. MCP — declarative

`claude/mcp-servers.json` gains:

```json
"clauth": { "type": "stdio", "command": "clauth", "args": ["mcp"] }
```

The canonical stdio entry (`src/plugin_probe.rs`), merged by
`_install/claude.sh` with jq like every other server. This avoids the Claude
plugin install and its `SessionStart` self-heal hook.

Two capabilities are given up with that hook, and they are a real cost:

- **Background delegates no longer re-wake the conversation** — the plugin's
  `mcp-await-job` / `asyncRewake` hook is what does that. Blocking delegates
  work; a backgrounded one must be polled with the `monitor` tool.
- **Account-change and headroom notifications disappear.**

Also note `clauth start` runs a plugin preflight on every launch
(`src/start.rs`), which can self-heal a *previously installed* plugin. On a
machine that never installed it there is nothing to heal; if one was ever
installed, it must be removed explicitly for this to hold.

Of the four exposed tools — `profiles`, `switch_profile`, `delegate`,
`monitor` — `switch_profile` performs the global relink this design forbids
and must not be called. Nothing enforces that.

## Explicitly out of scope

- **Global profile switching** after enrollment.
- **`clauth start --with-fallback`**, refused on macOS.
- **A configured fallback chain**, which would arm the daemon's switching.

## Verification

| Check | Passes when |
|-------|-------------|
| `herdr plugin list` | lists clauth |
| `git diff herdr/.config/herdr/config.toml` after install | empty — proves `--no-config` holds |
| `prefix+d` | opens the clauth popup |
| `prefix+a` | still steps the agent queue (proves no clobber) |
| sidebar after `clauth start <profile>` | shows the `clauth=<profile>` tag |
| `clauth mcp` | answers a `server/discover` handshake |
| MCP servers after enrollment step 1 | still authenticate |
| `git status` after a clauth session | reviewed, not assumed clean — see the honest list |
| `just check` | the new stow package links without conflict |

## Requires the user

`clauth login <profile>` per account, primary first — an interactive browser
OAuth flow that cannot be automated.

## Review provenance

The first revision of this document contained four errors found by an
independent review: `prefix+a` was claimed free while bound to `next_agent`;
the first login's global activation was missed; per-session fallback was
claimed not to exist; and "zero drift" was asserted from a partial reading of
`settings_sync.rs`. Every source claim here was re-verified against
github.com/uwuclxdy/clauth branch `mommy`.

## Open follow-ups

- Revisit auto-fallback if Claude Code's keychain-first resolution on macOS
  ever changes; clauth's side is already built.
- `tag_watch_secs = 3600` works around a watcher with no job in a side-car
  setup. A `pane_tag`-without-watcher knob is a reasonable upstream request.
- Background-delegate re-wake without the plugin hook has no workaround today
  beyond polling `monitor`.

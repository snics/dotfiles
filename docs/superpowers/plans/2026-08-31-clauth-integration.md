# clauth Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Run a second Claude account from herdr as a side-car, with usage
visible in a popup and a per-pane account tag, without clauth taking ownership
of the primary account's auth.

**Architecture:** clauth is installed from the cargo manifest and its herdr
plugin is registered with `--no-config`, so every integration point is
hand-authored into this repository instead of written by the tool. Its own
config follows the `claude/` copy-not-symlink precedent. The daemon runs for
usage refresh and token maintenance but cannot switch accounts, because no
fallback chain is configured.

**Tech Stack:** Rust binary via `cargo binstall`, GNU Stow, herdr 0.8.2 plugin
API, Claude Code MCP over stdio, zsh.

**Spec:** `docs/superpowers/specs/2026-08-30-clauth-integration-design.md`

**Testing note:** This repository has no unit-test harness for shell and TOML
config — `_test/` holds symlink and config validators, not a test runner. The
TDD cycle is therefore adapted, not skipped: every task states a concrete
verification command, runs it *first* to observe the failing state, implements,
and re-runs it. Where a command's failure mode is "no output", the expected
output is given verbatim so a pass is unambiguous.

## Global Constraints

- herdr must be ≥ 0.8.0 for the plugin (installed: 0.8.2). Verify, do not assume.
- Never run `clauth herdr install` without `--no-config` — it writes through
  the stow symlink into `herdr/.config/herdr/config.toml`.
- Never run a global switch (`clauth <profile>`, or the MCP `switch_profile`
  tool) after enrollment.
- Never configure a fallback chain. The daemon's switching is inert only while
  the active profile is not a chain member.
- The `clauth/` stow package covers `profiles.toml` only. Never
  `~/.clauth/profiles/<name>/credentials.json` (OAuth tokens) or per-profile
  `config.toml` (may hold API keys).
- Keybinding is `prefix+d`. `prefix+a` is clauth's default and is already bound
  to `next_agent` in this config.
- Commits: Conventional Commits with a gitmoji prefix, English, scope matching
  the package directory.
- `justfile` and `Makefile` must stay target-for-target identical.

---

### Task 1: Install clauth and register its plugin

**Files:**
- Create: `_install/clauth.sh`
- Modify: `justfile` (after the `cargo-dump` recipe)
- Modify: `Makefile` (after the `cargo-dump` target, and the `.PHONY` list at line 16-18)
- Modify: `herdr/.config/herdr/plugins.list` (header comment only)

**Interfaces:**
- Consumes: `_install/cargo-tools.sh` and `_install/cargo-tools.list` (already
  declare `clauth`).
- Produces: `just clauth` / `make clauth`, an idempotent entry point that later
  tasks extend with the config-copy step (Task 2).

- [ ] **Step 1: Verify the failing state**

Run:
```bash
command -v clauth || echo "ABSENT"
herdr plugin list 2>/dev/null | grep -c clauth
```
Expected: `ABSENT`, then `0`.

- [ ] **Step 2: Install the binary from the existing manifest**

Run:
```bash
just cargo-tools
```
Expected: `→ installing clauth`, then `Done. 1 installed/updated, 0 already current, 0 failed.`

If binstall reports no prebuilt artifact it falls back to a source build; that
is expected and not an error.

- [ ] **Step 3: Confirm the binary and the herdr version floor**

Run:
```bash
clauth --version
herdr --version
```
Expected: a clauth version, and herdr 0.8.2 or newer. Stop if herdr is older —
the plugin declares `min_herdr_version = "0.8.0"`.

- [ ] **Step 4: Write the install script**

Create `_install/clauth.sh`:

```bash
#!/usr/bin/env bash
#
# Register clauth's herdr plugin WITHOUT letting it touch herdr's config.
#
# `clauth herdr install` would append its keybinding and sidebar block to
# herdr's config.toml — which is a stow symlink here, so the write would land
# in the repository as an unreviewed change. `--no-config` installs the plugin
# and returns before resolving or writing that file; the equivalent blocks are
# hand-authored in herdr/.config/herdr/config.toml instead.
#
# Consequence: `--no-config` also skips clauth's own keybinding conflict check,
# so the hand-authored key must be verified by hand. See
# docs/superpowers/specs/2026-08-30-clauth-integration-design.md.
#
# Usage: clauth.sh

set -euo pipefail

if ! command -v clauth &>/dev/null; then
    echo "  ERROR: clauth not found on PATH — run 'just cargo-tools' first."
    exit 1
fi

if ! command -v herdr &>/dev/null; then
    echo "  ERROR: herdr not found on PATH — install it first (brew bundle)."
    exit 1
fi

echo "  → registering the clauth herdr plugin (config left untouched)"
clauth herdr install --no-config -y

echo "Done. Verify with: herdr plugin list | grep clauth"
echo "Reminder: never run 'clauth herdr install' without --no-config."
```

Then: `chmod +x _install/clauth.sh && shellcheck _install/clauth.sh`

- [ ] **Step 5: Add the targets**

In `justfile`, after the `cargo-dump` recipe:

```
# Register the clauth herdr plugin (never writes herdr's config)
clauth:
    bash {{ DOTFILES }}/_install/clauth.sh
```

In `Makefile`, after the `cargo-dump` target:

```
clauth: ## Register the clauth herdr plugin (never writes herdr's config)
	bash $(DOTFILES)/_install/clauth.sh
```

And add `clauth` to the `.PHONY` list.

- [ ] **Step 6: Run it and prove the config was not touched**

Run:
```bash
just clauth
herdr plugin list | grep clauth
git diff --stat herdr/.config/herdr/config.toml
```
Expected: the plugin is listed, and `git diff --stat` prints **nothing**. A
non-empty diff means `--no-config` did not hold — revert it with
`git checkout herdr/.config/herdr/config.toml` and stop.

- [ ] **Step 7: Note the plugins.list exception**

The clauth plugin ships inside the binary, not as a GitHub repo, so it is
absent from the herdr-lazy bundle. Append to the header comment block of
`herdr/.config/herdr/plugins.list`, after the `# Update:` line:

```
#
# NOT a complete inventory: the clauth plugin ships inside the clauth binary
# and is registered by _install/clauth.sh (`just clauth`), not by herdr-lazy.
```

- [ ] **Step 8: Commit**

```bash
git add _install/clauth.sh justfile Makefile herdr/.config/herdr/plugins.list
git commit -m "🟣 feat(clauth): register the herdr plugin without touching herdr's config"
```

---

### Task 2: `clauth/` stow package for the tool's own config

**Files:**
- Create: `clauth/.clauth/profiles.toml`
- Create: `clauth/.stow-local-ignore`
- Create: `clauth/AGENTS.md`
- Modify: `_install/clauth.sh` (add the bootstrap-copy step)
- Modify: `justfile`, `Makefile` (add `clauth-sync`; `.PHONY`)
- Modify: `CLAUDE.md` (repository structure list), `README.md` (structure tree)
- Modify: `_test/validate-symlinks.sh` (package list)

**Interfaces:**
- Consumes: `_install/clauth.sh` from Task 1.
- Produces: `just clauth-sync`, mirroring `just claude-sync`.

- [ ] **Step 1: Verify the failing state**

Run:
```bash
clauth herdr config get tag_watch_secs
```
Expected: the built-in default (`5`), not `3600` — the knob is unset.

- [ ] **Step 2: Write the template**

Create `clauth/.clauth/profiles.toml`:

```toml
# clauth configuration. Tracked in the dotfiles repo, but NOT symlinked:
# clauth rewrites this file in place (profile ordering, the active marker),
# which would break a stow symlink on first write — the same failure mode as
# Claude Code's settings.json. Bootstrap-copied by _install/clauth.sh when
# absent, synced back with `just clauth-sync`.
#
# Secrets are NOT here and must never be: OAuth tokens live in
# ~/.clauth/profiles/<name>/credentials.json and per-profile config.toml,
# neither of which this package touches.
#
# NO FALLBACK CHAIN IS CONFIGURED, and that is load-bearing rather than
# incidental: it is what keeps the running daemon unable to switch accounts.
# See docs/superpowers/specs/2026-08-30-clauth-integration-design.md.

[herdr]
# Publishes the per-pane `clauth=$profile` tag consumed by the sidebar row in
# herdr's config.toml.
pane_tag = "on"
# The sidebar tag is enough; no account name on the pane border.
border_label = "off"
# The plugin spawns a detached watcher per Claude pane to catch account changes
# that fire no herdr event — a --with-fallback session, or a bare `claude`
# after a global switch. Neither can happen in this setup, so the interval is
# raised to the watcher's clamp ceiling instead of waking every 5 seconds.
tag_watch_secs = 3600
```

- [ ] **Step 3: Prove clauth parses the template before relying on it**

This is the step that decides the approach — do not skip it.

```bash
cp clauth/.clauth/profiles.toml /tmp/clauth-probe.toml
mkdir -p ~/.clauth && [ -e ~/.clauth/profiles.toml ] && echo "EXISTS — back it up first"
cp clauth/.clauth/profiles.toml ~/.clauth/profiles.toml
clauth herdr config get tag_watch_secs
clauth herdr config get pane_tag
```
Expected: `3600` and `on`.

**If instead it errors** (a missing mandatory field, a rejected schema), the
template approach fails and the fallback is: remove the file, let clauth
generate `~/.clauth/profiles.toml` on first run, edit only its `[herdr]` block
in place, and run `just clauth-sync` to bring the generated file into the repo
as the tracked copy. Record which path was taken in the commit message.

- [ ] **Step 4: Add the stow ignore**

Create `clauth/.stow-local-ignore`:

```
# clauth rewrites profiles.toml in place (profile ordering, active marker),
# which destroys a stow symlink and leaves the repo copy stale. It is
# bootstrap-copied by _install/clauth.sh and synced back with
# `just clauth-sync`. See AGENTS.md.
profiles\.toml

# Docs (local ignore overrides the global one, so re-list essentials)
^/README.*
AGENTS\.md
```

- [ ] **Step 5: Extend the install script**

In `_install/clauth.sh`, insert before the closing `echo "Done. …"`:

```bash
# profiles.toml is intentionally NOT symlinked: clauth rewrites it in place,
# which destroys a stow symlink and leaves the repo copy stale. Bootstrap-copy
# the template if none exists; afterwards sync the live file back into the repo
# with `just clauth-sync`.
PROFILES_SRC="$(dirname "${BASH_SOURCE[0]}")/../clauth/.clauth/profiles.toml"
PROFILES_DST="$HOME/.clauth/profiles.toml"
mkdir -p "$HOME/.clauth"
if [ ! -e "$PROFILES_DST" ]; then
    cp "$PROFILES_SRC" "$PROFILES_DST"
    echo "  profiles.toml copied to ~/.clauth/"
else
    echo "  profiles.toml already exists — left untouched (use 'just clauth-sync' to update the repo)"
fi
```

- [ ] **Step 6: Add the sync targets**

In `justfile`, next to `claude-sync`:

```
# Sync live ~/.clauth/profiles.toml back into the repo
clauth-sync:
    @cp "$HOME/.clauth/profiles.toml" {{ DOTFILES }}/clauth/.clauth/profiles.toml
    @echo "Synced ~/.clauth/profiles.toml → repo. Review the diff and commit."
```

In `Makefile`, next to `claude-sync`:

```
clauth-sync: ## Sync live ~/.clauth/profiles.toml back into the repo
	@cp "$(HOME)/.clauth/profiles.toml" $(DOTFILES)/clauth/.clauth/profiles.toml
	@echo "Synced ~/.clauth/profiles.toml -> repo. Review the diff and commit."
```

Add `clauth-sync` to `.PHONY`.

- [ ] **Step 7: Write the guardrails doc**

Create `clauth/AGENTS.md` covering, each with its reason: profiles.toml is
copied not symlinked (in-place rewrite); the package covers profiles.toml only
and never the `profiles/` subtree (tokens); never run `clauth herdr install`
without `--no-config` (writes through the stow symlink); never run a global
switch or the MCP `switch_profile` tool (rewrites `model`/`env`/`apiKeyHelper`
into `~/.claude/settings.json` and does read-modify-write on the Keychain item
shared with MCP logins); never configure a fallback chain (arms the daemon);
the keybinding is `prefix+d` because `prefix+a` is taken by `next_agent`.

- [ ] **Step 8: Register the package everywhere packages are listed**

- `CLAUDE.md`: add `clauth/      → ~/.clauth/ (multi-account manager for Claude Code)`
  to the repository structure block, alphabetically between `claude/` and `cursor/`.
- `README.md`: same line in the structure tree.
- `_test/validate-symlinks.sh`: add `clauth` to the package list — check
  whether it belongs to `CLI_PACKAGES` or another list by reading the file
  first; the worktrunk work touched this list recently.

- [ ] **Step 9: Verify stow linking and the sync round-trip**

Run:
```bash
stow --simulate --restow -t "$HOME" clauth
just check
just clauth-sync && git diff --stat clauth/
```
Expected: no `ERROR` from stow, `just check` green, and the sync either a no-op
or a reviewable diff. Confirm `~/.clauth/profiles.toml` is a **regular file**,
not a symlink: `test -L ~/.clauth/profiles.toml && echo "WRONG: symlinked"`.

- [ ] **Step 10: Commit**

```bash
git add clauth _install/clauth.sh justfile Makefile CLAUDE.md README.md _test/validate-symlinks.sh
git commit -m "🟣 feat(clauth): track clauth config as a copy-not-symlink package"
```

---

### Task 3: herdr keybinding and sidebar tag

**Files:**
- Modify: `herdr/.config/herdr/config.toml` (two insertions)
- Modify: `_docs/keybindings.md`

**Interfaces:**
- Consumes: the registered plugin from Task 1 (action id `clauth.open`) and the
  `pane_tag` knob from Task 2 (publishes the `$clauth` token).
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Verify the failing state and re-confirm the key is free**

Run:
```bash
grep -n 'prefix+d' herdr/.config/herdr/config.toml || echo "FREE in config"
strings "$(command -v herdr)" | grep -x 'prefix+d' || echo "FREE in builtins"
grep -n 'rows_by_agent' herdr/.config/herdr/config.toml || echo "NO sidebar table yet"
```
Expected: all three print the `FREE`/`NO` fallbacks.

Note both binding syntaxes exist in this file: `[[keys.command]]` blocks use
`key = "…"`, while built-in actions use `<action> = "prefix+…"`. Grep for the
bare key string, as above, or a conflict will be missed — this is exactly how
`prefix+a` was wrongly believed free.

- [ ] **Step 2: Add the keybinding**

Insert after the **last** `[[keys.command]]` block (around line 391-396,
before `[ui]` at line 397). The block matches byte-for-byte what
`clauth herdr install` would have written, except for the key:

```toml
# clauth herdr plugin
[[keys.command]]
key = "prefix+d"
type = "plugin_action"
command = "clauth.open"
description = "clauth accounts"
```

- [ ] **Step 3: Add the sidebar row**

TOML placement is load-bearing: `[ui.sidebar.agents.rows_by_agent]` is a
sub-table of `[ui]`, so inserting it among `[ui]`'s bare keys would silently
reassign every following key to the sub-table. Insert it **after** the
`[ui.sound]` block and **before** `[experimental]` (line 435):

```toml
# clauth herdr plugin: `$clauth` renders the account each Claude Code pane burns
[ui.sidebar.agents.rows_by_agent]
claude = [["state_icon", "workspace", "tab"], ["terminal_title_stripped"], ["agent", "$clauth"]]
```

- [ ] **Step 4: Verify the config still parses and nothing was clobbered**

Run:
```bash
herdr server reload-config && echo "RELOAD OK"
grep -n 'next_agent' herdr/.config/herdr/config.toml
grep -c 'kitty_graphics\|pane_history' herdr/.config/herdr/config.toml
```
Expected: `RELOAD OK`; `next_agent = "prefix+a"` still present and unchanged;
the count is `2`, proving the `[experimental]` keys were not absorbed into the
new sub-table.

- [ ] **Step 5: Verify the binding by hand**

In herdr: press `prefix+d` — the clauth popup opens. Press `prefix+a` — the
agent queue still steps. Close the popup with `ctrl+c` (the uniform popup close
key in this setup).

- [ ] **Step 6: Update the keybindings cheatsheet**

`_docs/keybindings.md` has a herdr section and a per-tool layout. Add
`prefix+d` → "clauth accounts (usage windows, profile switcher popup)" beside
the other herdr plugin bindings, per the repository's cheatsheet sync rule.

- [ ] **Step 7: Commit**

```bash
git add herdr/.config/herdr/config.toml _docs/keybindings.md
git commit -m "🟣 feat(herdr): bind the clauth dashboard to prefix+d"
```

---

### Task 4: MCP server, declared not installed

**Files:**
- Modify: `claude/mcp-servers.json`

**Interfaces:**
- Consumes: the `clauth` binary from Task 1.
- Produces: the `profiles`, `delegate` and `monitor` MCP tools in new Claude
  Code sessions.

- [ ] **Step 1: Verify the failing state**

Run:
```bash
jq '.mcpServers.clauth // "ABSENT"' ~/.claude.json
```
Expected: `"ABSENT"`.

- [ ] **Step 2: Confirm the server actually answers before declaring it**

Run:
```bash
clauth mcp --help >/dev/null 2>&1 && echo "SUBCOMMAND OK"
```
Expected: `SUBCOMMAND OK`. A clauth too old to serve has no `mcp` subcommand.

- [ ] **Step 3: Add the entry**

In `claude/mcp-servers.json`, add alongside the existing servers. This is the
canonical stdio entry clauth would otherwise write into `~/.claude.json`
itself, so a later `clauth` probe reads it as correctly wired rather than
drifted:

```json
  "clauth": {
    "type": "stdio",
    "command": "clauth",
    "args": ["mcp"],
    "env": {}
  },
```

- [ ] **Step 4: Merge and verify**

Run:
```bash
jq empty claude/mcp-servers.json && echo "JSON OK"
bash _install/claude.sh
jq '.mcpServers.clauth' ~/.claude.json
```
Expected: `JSON OK`, then the entry echoed back with `command: "clauth"` and
`args: ["mcp"]`.

- [ ] **Step 5: Confirm no plugin lifecycle was triggered**

Run:
```bash
jq '.enabledPlugins // {} | keys | map(select(test("clauth")))' ~/.claude/settings.json
jq '.hooks.SessionStart' ~/.claude/settings.json
```
Expected: an empty array, and a `SessionStart` block containing only the
existing `herdr-agent-state.sh` hook — no clauth self-heal hook. If a clauth
plugin entry is present, it was installed previously and must be removed for
the design's isolation to hold.

- [ ] **Step 6: Commit**

```bash
git add claude/mcp-servers.json
git commit -m "🟣 feat(claude): declare the clauth MCP server instead of installing its plugin"
```

---

### Task 5: Daemon lifecycle coupled to herdr

**Files:**
- Create: `zsh/conf.d/66-clauth.zsh`
- Modify: `zsh/AGENTS.md` (conf.d file list)

**Interfaces:**
- Consumes: the `clauth` binary from Task 1 and the chain-free config from
  Task 2.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Prove the daemon cannot switch before starting it**

Run:
```bash
grep -c '^\[\[chain\]\]\|fallback' ~/.clauth/profiles.toml
```
Expected: `0`. The daemon's switching is inert only while the active profile is
not a fallback-chain member — `next_auto_switch_target` returns `None` when it
cannot locate the active profile in the chain. If this is non-zero, stop and
remove the chain before starting any daemon.

- [ ] **Step 2: Verify the failing state**

Run:
```bash
pgrep -f 'clauth daemon' || echo "NOT RUNNING"
```
Expected: `NOT RUNNING`.

- [ ] **Step 3: Write the lifecycle hook**

Create `zsh/conf.d/66-clauth.zsh`, following the PID-lockfile pattern the
`herdr-launch` wrapper already uses for one-session-per-window:

```zsh
# ── clauth daemon ───────────────────────────────────────────
# clauth's daemon keeps the usage windows fresh and performs rolling OAuth
# token maintenance, which otherwise only happens while the TUI is open. It is
# started with the first herdr session and left to the OS on the last exit.
#
# It CANNOT switch accounts: next_auto_switch_target locates the active profile
# in the fallback chain and returns None when it is not a member, and no chain
# is configured (clauth/.clauth/profiles.toml). Do not add one.

if [[ -n "${HERDR_SESSION_ID:-}${HERDR_PANE_ID:-}" ]] && command -v clauth &>/dev/null; then
    _clauth_lock="${TMPDIR:-/tmp}/clauth-daemon.pid"
    # Claim the lockfile atomically (noclobber): two panes starting together
    # both see it missing, so the create itself is the gate. A stale lockfile
    # from a killed daemon self-heals via the liveness check.
    if ( umask 077; set -o noclobber; echo $$ > "$_clauth_lock" ) 2>/dev/null; then
        clauth daemon &>/dev/null &
        echo $! >| "$_clauth_lock"
    elif ! kill -0 "$(<"$_clauth_lock" 2>/dev/null)" 2>/dev/null; then
        rm -f "$_clauth_lock"
        clauth daemon &>/dev/null &
        echo $! >| "$_clauth_lock"
    fi
    unset _clauth_lock
fi
```

- [ ] **Step 4: Verify syntax, then behaviour**

Run:
```bash
zsh -n zsh/conf.d/66-clauth.zsh && echo "SYNTAX OK"
```
Expected: `SYNTAX OK`.

Then open a new herdr pane and run:
```bash
pgrep -fc 'clauth daemon'
```
Expected: exactly `1`. Open a second pane and re-run — still exactly `1`,
proving the lockfile prevents a second daemon.

- [ ] **Step 5: Prove it did not switch anything**

Run:
```bash
clauth profiles 2>/dev/null || clauth list
git status --short claude/
```
Expected: the active profile is unchanged from before the daemon started, and
`git status` shows nothing under `claude/`.

- [ ] **Step 6: Document the new conf.d file**

Add `66-clauth.zsh` to the conf.d file list in `zsh/AGENTS.md`, alongside the
`65-worktrunk.zsh` entry, noting it starts the clauth daemon under a lockfile.

- [ ] **Step 7: Commit**

```bash
git add zsh/conf.d/66-clauth.zsh zsh/AGENTS.md
git commit -m "🟣 feat(zsh): start the clauth daemon with herdr under a lockfile"
```

---

## Manual step for the user — not a task

Enrollment cannot be automated and must be done in this order:

1. `clauth login <primary-name>` — the **primary** account first. Only the
   first login seeds the active profile, so doing the primary first leaves the
   global pointer where it already effectively points. This runs a real browser
   OAuth flow, mints fresh tokens for that account, and rewrites the live
   credentials including the Keychain item shared with MCP server logins.
2. Verify MCP servers still authenticate afterwards.
3. `clauth login <secondary-name>` — does not activate, because a profile is
   now active.
4. `just clauth-sync` and review the diff: profile ordering and the active
   marker will have appeared in `profiles.toml`.

Use the second account with `clauth start <secondary-name>` in its own herdr
pane. Never `clauth <profile>`.

---

## Self-Review

**Spec coverage:** §1 Install → Task 1. §2 Plugin registration → Task 1
(including the plugins.list exception). §3 herdr configuration → Task 3. §4
stow package → Task 2 (including the profiles-only scope and the empty chain).
§5 Daemon → Task 5. §6 MCP → Task 4. The enrollment order from "Decisions" is
the manual step above. The spec's verification table is distributed across the
tasks' verify steps, with one addition: Task 3 Step 4 checks that the
`[experimental]` keys survived the sub-table insertion, a failure mode the spec
did not anticipate.

**Not covered by any task, deliberately:** the spec's "Open follow-ups" are
future work, and its "What clauth still writes" list is a standing caveat
rather than an implementable requirement — Task 5 Step 5 and Task 2 Step 9
check it empirically instead.

**Known risk carried into execution:** Task 2 Step 3 may fail if clauth rejects
a hand-written `profiles.toml`. The fallback is written into that step rather
than discovered during execution.

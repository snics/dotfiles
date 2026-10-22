# T3 Code Integration — Research & Plan (2026-10-21)

Goal: drive Claude Code (2 subscriptions: `private`, `work`) and Codex (1 subscription)
from T3 Code, with everything configured for the CLIs (skills, plugins, MCP, hooks,
instructions) working there too, and T3 Code managed file-based in the dotfiles.

Sources: pingdotgg/t3code @ `5c3721e2` (2026-10-21), clauth @ `85d28a1`,
code.claude.com legal-and-compliance. **[V]** = verified in source/docs,
**[I]** = inference.

## 1. What T3 Code is

- github.com/pingdotgg/t3code, MIT, ~29k stars. Electron desktop app plus local web
  server (`t3`). Status: "very very early", v0.1.1 stable (2026-10-21), nightly
  builds daily. **[V]**
- **Already installed here:** cask `t3-code@nightly` (0.1.2-nightly), declared in
  `brew/Brewfile.85-casks`. **[V]**
- Providers: Codex, Claude, Cursor, Grok, OpenCode, Pi, … **[V]**
  - **Claude** runs through `@anthropic-ai/claude-agent-sdk`, which drives the
    installed `claude` binary.
  - **Codex** runs through `codex app-server`.
- State lives in `~/.t3/` (override with `T3CODE_HOME`). **[V]**
  - `userdata/settings.json` holds provider instances and defaults.
  - `userdata/keybindings.json` holds keybindings.
  - `userdata/statev2.sqlite` holds projects and threads.
  - `secrets/` holds the secret store.
- Config writers resolve symlinks before an atomic write, so stow links survive. **[V]**

## 2. Using all three subscriptions — provider instances

T3 has first-class **provider instances**. The maintainer closed the multi-account
issues #1444 and #2111 with this feature. **[V]**

| Instance | Driver | Key setting | Login |
|---|---|---|---|
| Claude (work) | claude | `homePath: ~/.claude-t3/work` → `CLAUDE_CONFIG_DIR` | `CLAUDE_CONFIG_DIR=~/.claude-t3/work claude auth login` |
| Claude (private) | claude | `homePath: ~/.claude-t3/private` | same, with the private account |
| Codex | codex | `binaryPath: codex`, mode **existing login** (not T3's managed ChatGPT runtime) | existing `~/.codex` |

- T3 sets only `CLAUDE_CONFIG_DIR` and keeps `HOME`. Claude Code keys its keychain
  entry per config dir, so the two instances are isolated. **[V]**
- Choose the account per thread in the provider picker. There is no automatic
  failover between instances; `autoResumeLimitedThreads` only waits for the same
  account to reset. **[V]** This is intentional: auto-hopping accounts to dodge
  limits is the grey zone documented in `clauth/AGENTS.md`.
- **Do not route T3 through clauth.** A `binaryPath` wrapper calling
  `clauth start <p>` would probably work, but it adds runtime trees, preflight work
  and daemon dependence on every T3 spawn, including probes. **[I]**
- **Do not keep the default instance** (no `homePath`). It follows whatever the
  global `~/.claude` link points to, which clauth's daemon rewrites. Note:
  `clauth which` reported `private` while clauth's MCP reported `work` as active.
  Check this before relying on the global state.

**ToS.**
- Anthropic forbids third-party *developers* from routing Pro/Max credentials for
  their users.
- It explicitly allows an end user to sign in to the unmodified Claude Code binary
  with their own subscription.
- Limits assume "ordinary, individual usage".
- T3 spawns the unmodified binary with your own login. **[I]** That is defensible
  but remains a grey zone that Anthropic can tighten without notice.

**Balancing headroom.**
- Check headroom before choosing an account:
  - T3's per-instance usage view (`get_usage` for Claude, `account/rateLimits/read`
    for Codex).
  - `clauth status --json` or the clauth MCP `profiles` tool, which spend no quota.
- Optional: a read-only `ai-headroom` script that prints the account with the most
  headroom across all three.

## 3. Making the CLI setup appear in T3 dynamically

A fresh `CLAUDE_CONFIG_DIR` starts empty. To keep both instances in sync with
`~/.claude`, build them as **symlink forests**, the same pattern clauth uses for its
runtime dirs:

```
~/.claude-t3/<profile>/
  CLAUDE.md      -> ~/.claude/CLAUDE.md
  skills/        -> ~/.claude/skills        (already contains ~/.agents/skills links)
  plugins/       -> ~/.claude/plugins       (installed_plugins.json, marketplaces, cache)
  agents/        -> ~/.claude/agents
  settings.json  -> ~/.claude/settings.json (see open question 1)
  .claude.json      per-profile (MCP servers: copy/merge mcpServers — see question 2)
  credentials       per-profile keychain entry — never shared
```

New skills, plugins or plugin updates in `~/.claude` then show up in both T3
instances automatically. After changes, run "Restart agent session" in T3. **[V]**

Parity via T3 Code:

| Feature | Claude | Codex | Notes |
|---|---|---|---|
| Skills | ✅ V | ✅ V | T3 reads `<config>/skills` and project `.claude/skills`, not `~/.agents/skills` directly (covered by our symlinks) |
| Plugins | ✅ V | ✅ I | Codex plugins need "existing login" mode |
| MCP servers | ✅ I | ✅ I | T3 adds its own `t3-code` MCP server; file and plugin servers stay |
| Hooks | ✅ I | ✅ I | herdr/Superset hooks no-op outside herdr (no `HERDR_ENV`) |
| CLAUDE.md / AGENTS.md | ✅ | ✅ | |
| Slash commands | ⚠️ V | ⚠️ V | only at the start of a message |
| Permission mode | ⚠️ V | ⚠️ V | T3 default is **Full access** (= bypassPermissions / dangerFullAccess) → set **Auto** |
| Shell env | ⚠️ V | ⚠️ V | Dock launch only copies PATH/JAVA_HOME; settings.json `env` and Codex `shell_environment_policy` still apply (SEO bridge OK) |
| Subagents | ⚠️ V | ✅ V | Codex subagents are disabled in T3's managed ChatGPT runtime → use existing login |
| `--settings` launch arg | ❌ V | — | silently replaced (issue #15073) |
| Status line | ❌ I | — | no TUI |

## 4. Implementation (done 2026-10-22)

The stow-package idea from the research was dropped: `keybindings.json` holds
only T3's defaults, and `settings.json` sits next to SQLite state, secrets and
logs, and is rewritten by the app. The setup is instead:

| Piece | File | What it does |
|---|---|---|
| Cask | `brew/Brewfile.85-casks` | `t3-code@nightly` (already added in 77c89bcb) |
| Settings overlay | `t3/settings.json` | 3 provider instances + `defaultRuntimeMode: "auto"`; deep-merged, overlay wins |
| Stow guard | `t3/.stow-local-ignore` | an accidental `stow t3` links nothing |
| Installer | `_install/t3.sh` | builds `~/.claude-t3/{private,work}` forests, seeds/syncs `.claude.json` `mcpServers`, merges the overlay, reports missing logins |
| Targets | `justfile` / `Makefile` | `just t3` / `make t3` |
| Updates | `zsh/functions/update.zsh` | `update skills` re-runs `t3.sh` once `~/.claude-t3` exists |
| Docs | `t3/AGENTS.md`, `CLAUDE.md`, `README.md`, `_docs/keybindings.md` | rules, package table, T3 default shortcuts |

Verified on this machine:
- `claude auth status` in each forest reports its own config dir and
  `loggedIn: false`, so the forests do not pick up the global login.
- `claude plugin list` and `claude mcp list` in a forest show the same plugins
  and MCP servers as the CLI.
- A second `t3.sh` run changes nothing (idempotent).
- T3 instance ids `claudeAgent` and `codex` are the driver defaults and are kept,
  so existing threads still resolve. The new id is `claudeWork`.

Not stowed or tracked on purpose: `keybindings.json`, `client-settings.json`
(UI preferences only), `desktop-settings.json` (window bounds), and everything
else under `~/.t3`. T3's "load balancing" setting balances across *machines*
(remote environments), not accounts, so it is not relevant here.

Remaining manual steps (interactive, cannot be scripted):
1. `CLAUDE_CONFIG_DIR=~/.claude-t3/private claude auth login` (private account).
2. `CLAUDE_CONFIG_DIR=~/.claude-t3/work claude auth login` (work account).
3. Restart T3 and check Settings → Providers for three ready instances.
4. Smoke test: one short thread per instance, then `/skills` in a Claude thread.

## 5. Open questions / risks

1. **`settings.json` symlink:** resolved by linking it. If Claude Code ever
   replaces the link with a regular file, `t3.sh` keeps that file as a
   timestamped backup and relinks it.
2. **MCP servers:** resolved. `.claude.json` is a per-account copy, and only
   `mcpServers` is synced from `~/.claude.json`.
3. **Token coexistence:** does a separate `claude auth login` per T3 dir coexist
   with clauth's rolling token on the same account (no `invalid_grant` loops)?
   Expected yes; verify with a short real-world test.
4. **Instance switch reverts:** bug #18762 can silently switch a thread back to the
   other instance. Watch for it.
5. **Transcripts:** resolved. `projects/` is linked, so T3 threads land in the
   same store as the CLI and can be resumed with `claude --resume`.
6. **Pre-1.0 software:**
   - Issue #3530: Max-plan 401s in T3 only. Also check #15073.
   - Pin the nightly cask or switch to stable `t3-code` if regressions appear.

## 6. Plan v2 — one T3 folder, full settings (2026-10-22)

Feedback on v1: the extra top-level `~/.claude-t3/` dirs are unwanted; everything
should live in one T3 folder, ideally one the vendor uses. Two research passes
(source at `2c8bdf61`) are in `_planning/t3code/research-layout.md` and
`_planning/t3code/research-settings.md`.

### 6.1 Folder layout — use T3's own provider namespace

T3 already keeps per-instance provider state at
`~/.t3/userdata/providers/<driver>/<instanceId>/<role>` (managed Codex shadow
homes: `providers/codex/<id>/shadow`; Antigravity: `providers/antigravity/…`).
Nothing in T3 deletes, scans, migrates or watches that subtree, and
`t3 uninstall` keeps `userdata`. **[V]**

```
~/.t3/userdata/providers/claudeAgent/claudeAgent/home   # private (instance claudeAgent)
~/.t3/userdata/providers/claudeAgent/claudeWork/home    # work    (instance claudeWork)
```

- Codex needs no folder: `setupMode: existing` uses `~/.codex` directly.
  Avoid `shadowHomePath` (loses bundled plugins, #23652).
- The forest content stays as in v1 (T3 has no skills/plugins sharing for
  Claude). Its justification becomes "same pattern T3 uses for Codex shadow
  homes".
- Migration cost is zero right now: neither `~/.claude-t3` dir is logged in
  yet. Move first, log in afterwards.
- Caveat to document: `rm -rf ~/.t3/userdata` now also removes both Claude
  logins.

### 6.2 Settings overlay additions (`t3/settings.json`)

| Key | Value | Why |
|---|---|---|
| `defaultRuntimeMode` | `auto` | already set; = CLI `defaultMode: auto` |
| `defaultModelSelection` | `codex` / `gpt-6.1-sol`, no options | CLI default; effort/tier then come from `config.toml` [I] |
| `autoResumeLimitedThreads` | `true` | resumes the **same** account at reset — no account hopping |
| `snoozeLimitedThreads` | `true` | pairs with auto-resume |
| `removeAgentCreditsOnMerge` | `true` | never Co-Authored-By (covers Codex + T3 writer) |
| `branchNamingMode` | `semantic` | readable `t3/<topic>` branches |
| `addProjectBaseDirectory` | `~/Projects` | |
| `enableProviderUpdateChecks` | `false` | CLIs are updated by brew/`update`, not in-app [I] |
| `worktreesDirectory` | `~/Projects/_worktrees` **(decision)** | one tree with Worktrunk; see 6.4 |

Left out on purpose: `customModels`, `environment` (arrays replace), project-
scoped keys, Claude `launchArgs` (`--permission-mode` overrides T3, `--settings`
is replaced #15073), `defaultThreadEnvMode` (worktree bugs #23639/#23151).

### 6.3 Client settings overlay (`t3/client-settings.json`) — new

`client-settings.json` is the desktop app's source of truth, read once per app
start and rewritten in full on every UI change. A second overlay is merged by
`t3.sh` **only while T3 is not running** (skip with a hint otherwise):
`notificationMode: notifications`, `inAppNotificationsEnabled: true`,
`planModeEnabled: true`, `contextWindowMeterEnabled: true`,
`timestampFormat: 24-hour`. herdr notifications no-op in T3, so T3's own are
the only signal.

### 6.4 Open decisions (user)

1. **Worktrees in `~/Projects/_worktrees`?** Pro: one visible tree, `wt list`
   sees T3 worktrees. Contra: wt hooks don't run for T3 worktrees (no env-file
   copies), `.dotfiles` vs `dotfiles` dir name differs, `wt remove` on a T3
   thread's worktree breaks the thread. Alternative: keep T3's hidden
   `~/.t3/worktrees`.
2. **`followUpBehavior`:** `queue` (current) or `steer` (CLI-like).

### 6.5 Steps

1. `t3.sh`: new root `~/.t3/userdata/providers/claudeAgent/<instanceId>/home`,
   remove `~/.claude-t3` (only links + seeded `.claude.json`, no logins).
2. `t3/settings.json`: new `homePath`s + 6.2 keys.
3. `t3/client-settings.json` + merge-when-closed logic in `t3.sh`.
4. `update.zsh`: guard on the new root instead of `~/.claude-t3`.
5. Docs: `t3/AGENTS.md` (layout, env correction below, worktrees, Auto-mode
   bugs), `CLAUDE.md` row, this file, memory.
6. User: two logins
   (`CLAUDE_CONFIG_DIR=~/.t3/userdata/providers/claudeAgent/<id>/home claude auth login`),
   restart T3.
7. Smoke test per instance: short thread; provider log shows
   `permissionMode=auto` (#22483 can start it in `default`); `/` lists skills;
   one MCP tool call; Codex thread runs with subagents.

**Correction to v1 docs:** on a Dock launch T3 imports PATH, SSH_AUTH_SOCK,
locale, HOMEBREW_*, XDG_* and CA vars from `zsh -ilc` (5 s timeout) — not
"only PATH and JAVA_HOME"; JAVA_HOME is *not* imported on the desktop path.

### 6.6 Watch list (open upstream issues)

#22483 / #15353 (Auto mode), #19025 (restart agent session after `just t3`),
#18762 / #23086 (instance switching), #23151 (SessionStart hook > 90 s in fresh
worktrees — check claude-mem), #23507 (plugin skills missing in `$` picker),
#12300 (glab in T3 worktrees), #3530 (Max 401 only in T3).

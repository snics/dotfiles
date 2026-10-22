# T3 Code: where to put per-account Claude config dirs (2026-10-22)

Source: pingdotgg/t3code @ `2c8bdf61` (pulled 2026-10-22, clone at
`scratchpad/t3code`). Paths below are relative to that clone unless they start
with `~`. **[V]** = verified in source/docs, **[I]** = inference.

## TL;DR

- T3 has a vendor convention for per-instance provider state:
  `<stateDir>/providers/<driver>/<instanceId>/…` with `stateDir = ~/.t3/userdata`.
  Managed Codex puts its per-account shadow home at
  `~/.t3/userdata/providers/codex/<instanceId>/shadow`; Antigravity puts its
  profile at `~/.t3/userdata/providers/antigravity/<sha256(instanceId)>`. **[V]**
- Nothing in T3 creates, recommends or manages a Claude equivalent. The Claude
  docs recommend a top-level `~/.claude_personal` and say outright that "Claude
  does not have Codex's shared-home and shadow-home arrangement". **[V]**
- Placing the Claude config dirs under `~/.t3/userdata/providers/claudeAgent/<instanceId>/home`
  is safe: no code path deletes, scans, migrates or watches that subtree; `t3
  uninstall` explicitly keeps `userdata`; the only watchers in `userdata` are
  filtered to `settings.json`, `keybindings.json` and `themes/`. **[V]**
- `homePath` expands `~`/`~/…` only, is trimmed, has no length/charset limits,
  and relative paths resolve against the server's cwd (= `$HOME` for the Dock
  app), so always use `~/…` or absolute. **[V]**
- The symlink forest stays necessary: T3 offers no skills/plugins sharing for
  Claude and `--settings` is silently overridden. **[V]**

## Q1 — Does T3 create or recommend per-account provider homes?

**Vendor convention (Codex managed mode).** `apps/server/src/provider/CodexManagedHome.ts:12-19`:

```ts
shadowHomePath:
  config.shadowHomePath.trim() ||
  (instanceId === "codex" ? "" : path.join(stateDir, "providers", "codex", instanceId, "shadow")),
```

So a second ChatGPT account added via **Add ChatGPT account** (which only
sends `{ enabled: true, setupMode: "managed" }`, `apps/web/src/components/settings/AddCodexAccountDialog.tsx:67`)
lands in `~/.t3/userdata/providers/codex/<instanceId>/shadow`. The default
instance `codex` gets no shadow and uses the shared home directly. **[V]**

**Same convention, second driver.** `apps/server/src/provider/antigravityAuthSupport.ts:183-192`:
`profile: path.join(stateDir, "providers", "antigravity", key)` with `key =
sha256(instanceId)` ("so case-only differences stay separate on
case-insensitive filesystems"). **[V]**

**What `stateDir` is.** `apps/server/src/config.ts:120-123`:
`stateDir = join(baseDir, devUrl !== undefined && !baseDirIsExplicit ? "dev" : "userdata")`;
`baseDir` = `T3CODE_HOME` or `~/.t3` (`apps/server/src/os-jank.ts:124-130`,
`apps/desktop/src/app/DesktopStatePaths.ts:13-32`). Packaged app and CLI use
`~/.t3/userdata`; only running from source uses `~/.t3/dev`. **[V]**

No other code enumerates or references `providers/` — the two `join` sites above
are the only hits for `"providers"` as a path segment in `apps/` and
`packages/`. **[V]**

**Claude: no convention, only docs.** `docs/user/providers-claude.md:7-35`
recommends `mkdir -p ~/.claude_personal; CLAUDE_CONFIG_DIR=~/.claude_personal
claude auth login`, then a second instance with `CLAUDE_CONFIG_DIR path =
~/.claude_personal`; line 35: "Claude does not have Codex's shared-home and
shadow-home arrangement." The OpenRouter/router sections (lines 97-130) use
`~/.claude_openrouter`. Settings-form placeholders: Claude `homePath` →
`~/.claude` (`packages/contracts/src/settings.ts:683-690`), Codex
`shadowHomePath` → `~/.codex-t3/personal` (`settings.ts:615-624`), Codex docs →
`~/.codex_personal` (`docs/user/providers-codex.md:40-57`). The placeholder and
the docs disagree with each other, i.e. there is no single vendor-blessed
user-side path. **[V]**

**Add-instance dialog / wizard.** `AddProviderInstanceDialog.tsx` never sets a
`homePath`; it only derives the instance id as `${driver}_${slug(label)}`
(lines 60-71, placeholder `claudeAgent_work` at line 604, 64-char slug cap at
line 57). `WelcomeWizard.tsx` has no `homePath`/`CLAUDE_CONFIG_DIR` handling at
all. **[V]**

**Issues.** #1444 and #2111 were closed by the maintainer with "Provider
instances now allow separate Codex and Claude account homes/configurations and
let users switch between them in the provider picker" — no layout prescribed.
Related and still relevant: #20334 (closed, 2026-10-16: changing a Claude
profile directory left threads stuck resuming the old session), #18260
(closed: fork failed on custom `homePath`), #12616/PR #12624 (merged: empty
`homePath` and `~/.claude` now share one continuation key), #8818 (closed: probe
ran with cwd=`$HOME`, so `~/.claude/settings.json` leaked in as *project*
settings and broke `CLAUDE_CONFIG_DIR` isolation), #18762 (open: instance switch
not synced across devices). **[V]**

## Q2 — Is it safe to put config dirs inside `~/.t3`?

Every deletion/scan/watch path found in `apps/server/src` and `apps/desktop/src`:

| Code path | What it touches | Verdict |
|---|---|---|
| `t3 uninstall` — `apps/server/src/cli/uninstall.ts:78-88,144,169,202` | launcher + `<baseDir>/runtime` version dirs; prints "Your projects, threads, and settings under `<baseDir>/userdata` are kept." | userdata untouched **[V]** |
| Storage cleanup — `apps/server/src/storageCleanup.ts` (+ `worktreesDirectory.ts:34-49`) | only managed worktree dirs (`<baseDir>/worktrees` by default, `config.ts:136`); `isT3ManagedWorktree` also matches any path containing `/.t3/worktrees/` (`AgentSessionScanner.ts:547-556`) | never looks at userdata **[V]** |
| Resource cleanup — `orchestration-v2/ResourceCleanupService.ts:74-90` | single files under `userdata/attachments/<id>` | scoped **[V]** |
| DB maintenance — `persistence/DatabaseMaintenance.ts:223-236` | legacy `state.sqlite{,-wal,-shm}` only | scoped **[V]** |
| Migrations — `persistence/Migrations/*` | SQL only; 016 is the only one importing fs and it does not remove directories | no fs sweeps **[V]** |
| Pinned runtime / self-update — `cloud/pinnedRuntime.ts:254-621`, `cloud/updateHandoff.ts:58` | `<baseDir>/runtime/versions/*`, staging dirs, a marker file | top-level `runtime/` only **[V]** |
| Codex shadow materialization — `provider/Drivers/CodexHomeLayout.ts:321-416` | creates/replaces symlinks **inside the configured shadow path**; removes a non-symlink only for `mcp-oauth-locks` / `.sqlite-maintenance.lock` (line 36, 246-270) | confined to Codex shadow dir **[V]** |
| Desktop | no "reset app data"; `DesktopConnectionCatalogStore.ts:506` removes its own catalog file; other removals are WSL/Linux snap-shot helpers | nothing generic **[V]** |
| Caches — `config.ts:128`, `PullRequestReadCache.ts:214`, `ProviderRegistry.ts:374` | `<baseDir>/caches/<driver>.json`, `caches/pull-requests/` | never wiped by code, but semantically disposable — do not put accounts there **[V]** |

**Watchers** (`fs.watch` is on a *directory*, events filtered by file name):
`serverSettings.ts:1059-1072` watches `dirname(settings.json)` and keeps only
events whose name is `settings.json` (plus the symlink target, 1092-1116);
`keybindings.ts:599-607` same for `keybindings.json`; `environmentTheme.ts:221`
watches `userdata/themes`; `DesktopAppActivation.ts:249-262` watches a single
activation directory. A Claude session writing transcripts three levels down
in `userdata/providers/claudeAgent/<id>/home/projects/…` never matches any of
these filters. **[V]** (Node's non-recursive `fs.watch` only reports direct
children anyway — **[I]** for Effect's wrapper.)

**Scanners that *read* instance homes on purpose** (not a hazard, but note):
`project/AgentSessionScanner.ts:1120-1167` walks `<home>/projects` of every
Claude instance for project/thread import, deduping homes by the real path of
the *home dir* (line 1148, `directoryIdentity`). With the symlink forest both
instances have distinct homes but the same real `projects/`, so the import
scanner reads the same transcripts twice **[I]**. Usage (`usage/UsageService.ts:351`,
`claudeUsage.ts:100-109`) dedupes by real path of `projects/` — docs:
"Accounts sharing a history directory count once" (`docs/user/usage.md:37-39`). **[V]**

**Git-repo check on baseDir.** `project/ManagedProjectFolders.ts:243-250`:
if `baseDir` is inside a git work tree ("a dev worktree's .t3, a dotfiles
home") T3 stops offering the Scratch folder. So never stow or `git init`
`~/.t3` itself; the dotfiles overlay approach (copy, not link) is right. **[V]**

**Things that would be lost if the user wipes `userdata`** (as `t3 uninstall`
invites): the per-account `.credentials.json`/Keychain pointer, the
per-account `.claude.json` copy, `policy-limits.json` etc. The real content
(`~/.claude`) is untouched because the forest is symlinks. Re-running
`t3.sh` + two `claude auth login`s restores it. **[V]** for what the forest
links; **[I]** for the recovery cost.

**Path identity risks when moving from `~/.claude-t3/<p>`:**
- Continuation group key is `claude:home:<resolved homePath>`
  (`provider/Drivers/ClaudeHome.ts:67-75`); existing T3 threads keyed to the
  old path will no longer be "compatible" with the moved instance and may fall
  back to a context handoff instead of a native resume (cf. #20334) **[I]**.
  Do the move with no important T3 threads in flight.
- Claude Code keys its Keychain item per config dir (per `t3/AGENTS.md`;
  T3 side: `ClaudeHome.ts:38-46` keeps `HOME`, sets only `CLAUDE_CONFIG_DIR`),
  so both accounts need a fresh `claude auth login` after the move. **[I]**
- `homePath` is stored literally (no `$T3CODE_HOME` substitution,
  `pathExpansion.ts:9-16`); if `T3CODE_HOME` is ever changed the setting must be
  edited too. **[V]**

## Q3 — `homePath`: `~` expansion, relative paths, constraints

- Schema: `TrimmedString` with default `""` (`packages/contracts/src/settings.ts:683`,
  `baseSchemas.ts:7-11`) — trims whitespace, no max length, no charset
  restriction. **[V]**
- Expansion: `packages/provider-core/src/server/pathExpansion.ts:9-16` handles
  exactly `~`, `~/…`, `~\…`. No `$VAR`, no `~user`. **[V]**
- Resolution: `resolveClaudeHomePath` → `path.resolve(expandHomePath(homePath, home))`
  (`ClaudeHome.ts:18-21`), i.e. a relative value resolves against the server
  process cwd, which for the Dock-launched desktop app is `$HOME` (#8818).
  Same in `ClaudeSkills.ts:423-426`, `claudeUsage.ts:104-107`,
  `AgentSessionScanner.ts:914-918`. Use `~/…` or absolute. **[V]**
- Do **not** set the dir via an instance `environment` entry
  `CLAUDE_CONFIG_DIR=~/…` instead of `homePath`: inherited env values are
  deliberately not tilde-expanded for the spawned CLI (`ClaudeHome.ts:22-26`,
  `ClaudeSkills.ts:427-434`); only the T3 terminal expands them
  (`terminal/Manager.ts:1366`). `docs/user/usage.md:37-39` says the same. **[V]**
- `homePath` is passed to the CLI as `CLAUDE_CONFIG_DIR=<resolved>` with
  `HOME` untouched (`ClaudeHome.ts:30-47`); `customHome` is true whenever
  `homePath` is non-empty (`ClaudeAdapterV2.ts:3919-3922`). **[V]**
- Instance ids are slugs, ≤ 64 chars (`AddProviderInstanceDialog.tsx:57,80`),
  relevant only if the folder name mirrors the id. **[V]**

## Q4 — Codex `shadowHomePath`: how it works, what is shared

`apps/server/src/provider/Drivers/CodexHomeLayout.ts`:

- Two modes (lines 11-16, 44-67): `direct` (no shadow; `CODEX_HOME` =
  `homePath` or `~/.codex`) and `authOverlay` (`shadowHomePath` set;
  `effectiveHomePath` = shadow, `sharedHomePath` = `homePath`/`~/.codex`).
  The continuation key is always `codex:home:<sharedHomePath>` (lines 56, 65),
  which is what lets two accounts continue one thread. **[V]**
- `materializeCodexShadowHome` (321-416) runs **before every session start**
  (`CodexManagedRuntime.ts:69`): mkdir shared + shadow + the known shared dirs
  in the shared home (`sessions, archived_sessions, sqlite, shell_snapshots,
  worktrees, skills, plugins, cache, logs, mcp-oauth-locks`, lines 18-29);
  then symlinks **every** entry of the shared home into the shadow, except
  **private** `auth.json`, `models_cache.json` (line 31) and **shadow-local**
  `log`, `memories`, `tmp`, `.DS_Store` (line 33). `auth.json` in the shadow
  must be a real file (296-319). Dangling/wrong links are re-pointed (277-293);
  a real file where a link is expected is an error unless it is one of the
  replaceable runtime locks (36, 246-270). `config.toml` is therefore shared. **[V]**
- `codex update` runs against the shared home because the standalone tree
  lives there (`CodexDriver.ts:67-80`). The spawned `codex` gets
  `CODEX_HOME=<shadow>` (`CodexAdapterV2.ts:1563`, `terminal/Manager.ts:1455`). **[V]**
- Default location in managed mode: `~/.t3/userdata/providers/codex/<instanceId>/shadow`
  (Q1). In `existing` mode the user picks it; docs suggest `~/.codex_personal`
  and insist both instances share the same `CODEX_HOME path`
  (`providers-codex.md:34-65`). **[V]**
- Open bugs on this mechanism: #8578/PR #23428 (auth-like file names get
  linked), #23652 (bundled plugins lost in shadow homes), #5817 (new runtime
  entries can disable shadow providers), #14325 (Windows EPERM); #20261 closed
  (sqlite -wal/-shm in shadow). **[V]**

**Mirror for Claude.** T3's Codex design is the same pattern as `t3.sh`'s
forest: link everything, keep credentials and a few local caches private, keep
the transcript store shared. The parts worth copying are (a) the vendor path
`providers/<driver>/<instanceId>/<role>` and (b) the "re-materialize on every
start" behaviour, which `t3.sh` approximates via `update skills`. Nothing in
T3 will materialize a Claude home for you; `providers-claude.md:35` rules it
out. **[V]**

## Q5 — Built-in sharing of skills/plugins or a "settings source" switch?

- No. Claude skills come from `<configDir>/skills`, project `.claude/skills`
  and enabled plugins (`provider/Drivers/ClaudeSkills.ts:417-460`,
  `docs/user/providers-claude.md:78-88`); there is no second-home or
  "shared home" setting for Claude. **[V]**
- Session launches do **not** set the SDK's `settingSources`; the only three
  uses are the status probe (`ClaudeProvider.ts:200-217`, `["user","project","local"]`
  with `disableAllHooks`) and two internal `resolveClaudeSettings` reads that
  use `["project","local"]` for a custom home and then read
  `<homePath>/settings.json` directly (`ClaudeAdapterV2.ts:3919-3975`). So a
  custom home's `settings.json` is read by path — a symlinked
  `settings.json` works. **[V]** (the SDK's own default for sessions could
  not be checked: `node_modules` is absent in the clone — **[I]**)
- `--settings <file>` in Launch arguments is silently replaced by T3's inline
  settings (#15073 open, #18638 closed) — not usable as a sharing mechanism. **[V]**
- Per-instance **Environment variables** exist (`providers-claude.md:37-38`)
  but `CLAUDE_CONFIG_DIR` there is not tilde-expanded (Q3). **[V]**

## Recommended layout

```
~/.t3/userdata/providers/claudeAgent/claudeAgent/home/   # private account (instance id claudeAgent)
~/.t3/userdata/providers/claudeAgent/claudeWork/home/    # work account    (instance id claudeWork)
```

`t3/settings.json`: `homePath: "~/.t3/userdata/providers/claudeAgent/claudeAgent/home"` etc.
`t3.sh`: `T3_CLAUDE_ROOT="$HOME/.t3/userdata/providers/claudeAgent"`, forest
in `$T3_CLAUDE_ROOT/<instanceId>/home`, keep `chmod 700` on the instance dir
(`userdata` itself is 755 on this machine).

Why this one:
- It is the exact shape T3 uses for its own per-instance state
  (`providers/<driver>/<instanceId>/<role>`), with `<driver>` = the
  `ProviderDriverKind` `claudeAgent` and `<role>` = `home`, matching the
  setting's name `homePath` / Codex's `effectiveHomePath`. If T3 ever adds a
  managed Claude layout it will almost certainly land in
  `providers/claudeAgent/<instanceId>/…`, and the dir names cannot collide with
  `providers/codex/…` or `providers/antigravity/…`. **[I]**
- Inside `userdata`, which is the part `t3 uninstall` keeps and which no cleanup
  or watcher sweeps (Q2). Top-level `~/.t3/<x>` is instead where T3 keeps
  disposable or runtime-managed trees (`bin/`, `caches/`, `worktrees/`,
  `runtime/`, `wsl-runtime/`, `ssh-launch/`, `device/`). **[V]**
- Keyed by **instance id**, not clauth profile name: that is what T3 keys
  everything by, and it stays correct if a profile is ever renamed in clauth.

Alternatives considered:
- `~/.t3/providers/claude/<profile>` (top-level): simpler, also never touched,
  but no vendor precedent and `~/.t3` top level is T3's runtime namespace. **[I]**
- `~/.t3/claude/<profile>` or `~/.t3/accounts/…`: same objection, plus
  `accounts` is a plausible future T3 name.
- Renaming instance ids to T3's generated form (`claudeAgent_private`,
  `claudeAgent_work`) would make the path read better, but changes the default
  id `claudeAgent` that existing threads reference (`t3/AGENTS.md`). Separate
  decision; not required for the move.

## Risks

1. **Thread continuity across the move**: continuation key changes with the
   path (`ClaudeHome.ts:67-75`); existing threads on both instances may need a
   handoff rather than a native resume (#20334 pattern). Finish or accept that
   for current threads first. **[I]**
2. **Re-login required** for both accounts (Keychain item is per config dir).
   The old `~/.claude-t3/*` dirs can be deleted afterwards (they hold only
   links plus the per-account files). **[I]**
3. **User-initiated `rm -rf ~/.t3/userdata`** now also removes the two Claude
   logins. Document it in `t3/AGENTS.md`. **[V]**
4. **Dev-mode stateDir** is `~/.t3/dev`, not `userdata`, when T3 is run from
   source; irrelevant for the cask but worth one line in AGENTS.md. **[V]**
5. **Pre-1.0 churn**: `providers/` is an internal convention with no doc
   promise; T3 could rename it. The cost would be a path edit in two files. **[I]**
6. **Import scanner double-read** of the shared `projects/` (Q2) — present
   today, unchanged by the move. **[I]**

## Contradictions / corrections to the current implementation

- `t3/AGENTS.md` and `_planning/t3code-integration.md` are consistent with the
  source on: `CLAUDE_CONFIG_DIR` only, `HOME` untouched (`ClaudeHome.ts:30-47`);
  skills from `<config>/skills` + project; `--settings` overridden; no
  automatic failover. No factual contradictions found. **[V]**
- `_planning` §3 says "Config writers resolve symlinks before an atomic write,
  so stow links survive" — the settings watcher does follow a symlinked
  `settings.json` to its target (`serverSettings.ts:1092-1116`). Consistent,
  though the overlay approach makes it moot. **[V]**
- Gap, not contradiction: AGENTS.md does not mention that T3's Codex shadow
  mechanism is re-materialized on every session start, while the Claude forest
  only refreshes on `update skills`/`just t3`. Worth noting as the reason a
  new top-level `~/.claude` entry is invisible to T3 until the next run. **[V]**
- Gap: AGENTS.md says the dirs mirror "the layout `clauth start` uses"; after
  the move the justification becomes "the layout T3 uses for Codex shadow
  homes", which is the stronger argument. **[I]**

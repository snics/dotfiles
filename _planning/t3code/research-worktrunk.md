# T3 Code and Worktrunk: research report (2026-10-22)

Question: can T3 Code (desktop GUI for Claude Code / Codex) and Worktrunk (`wt`) share
worktrees, and can T3 worktrees be created or managed through `wt`?

Sources:
- pingdotgg/t3code @ `2c8bdf61` (2026-10-22, pulled at the start of this research).
- Worktrunk `wt v0.81.0` (installed), the `worktrunk` skill reference docs, and
  `max-sixty/worktrunk` `src/config/expansion.rs` (via `gh api`).
- Live `~/.config/worktrunk/config.toml` (stowed from `worktrunk/`), `zsh/.local/bin/wt-issue`,
  `_agents/skills/wt-issue/SKILL.md`, `zsh/conf.d/65-worktrunk.zsh`.
- `~/.t3/userdata/settings.json`, non-secret keys only. Credentials were not read.
- `gh search issues` / `gh issue view` on pingdotgg/t3code, 2026-10-22.
- Companion report: `research-settings.md` (same folder), especially §2.3 and §4.

Paths are relative to the T3 repo root unless noted. `TLS` means
`apps/server/src/orchestration-v2/ThreadLaunchService.ts`, `Core` means
`apps/server/src/vcs/GitVcsDriverCore.ts`, `SC` means `apps/server/src/storageCleanup.ts`.

Markers: **[V]** verified with a file:line reference, **[I]** inference.

---

## 0. TL;DR

1. **T3 cannot delegate worktree creation or removal to an external command.** `git worktree add`
   and `git worktree remove` are hard-coded; there is no custom VCS driver, hook or setting for it
   **[V]** `Core:3737-3740`, `apps/server/src/vcs/worktreeRemoval.ts:50-57`. The only user-defined
   lifecycle points are the project scripts `runOnWorktreeCreate` (after creation, before or
   alongside the agent) and `runOnSettle` (when a thread settles). Nothing fires on archive,
   delete, merge or removal (§1).
2. **The paths are compatible.** With `"worktreesDirectory": "~/Projects/_worktrees"`, T3 creates
   `<root>/<repo dir name>/<branch with "/"→"-">`, and Worktrunk's `sanitize` filter is literally
   `branch.replace(['/', '\\'], "-")`, so both tools compute the same path for every repo except
   `~/.dotfiles` (wt override `dotfiles` vs T3 `.dotfiles`) **[V]** `Core:3710-3736`,
   `expansion.rs:565`. One catch: T3 renames the branch after creation (`t3/<hex>` → generated
   name) but keeps the `t3-<hex>` directory, so every auto-named T3 worktree shows `⚑`
   (branch/path mismatch) in `wt list` (§4).
3. **T3 can attach a thread to an existing worktree**, including one created by
   `wt switch --create`: the branch picker lists every branch that `git worktree list` reports as
   checked out (badge "worktree") and binds the thread to that path without any git operation
   **[V]** `apps/web/src/components/BranchPicker.tsx:276-281`,
   `BranchToolbarBranchSelector.tsx:392-402`, `TLS:56-60, 377-380`. Maintainers confirmed this on
   2026-10-21 (#1714). The CLI cannot do it: `t3 thread start --worktree` only creates (§2).
4. **`wt` handles T3 worktrees fine** (they are ordinary linked worktrees, addressed by branch),
   and **wt hooks can run from a T3 setup script**: the script runs inside the new worktree in an
   interactive `zsh` pty, so `wt hook pre-start && wt hook post-start` works, approvals included
   (§3).
5. **Recommendation (§6): a hybrid.** Put T3 worktrees in the Worktrunk root and add one global
   T3 project script that runs the wt hooks (Option A), keep T3's automatic cleanup off and remove
   everything through `wt remove` / `wt merge` after deleting the thread, and use "create with
   `wt issue`, attach in T3" for GitLab tickets and for `~/.dotfiles` (Option B). The CLI route
   `t3 thread start . --worktree <base> --branch <N>-<slug>` is a promising `wt issue --t3`
   extension but needs a live test (§6.4).

---

## 1. Q1: can T3 delegate worktree creation/removal? Which lifecycle points exist?

### 1.1 No external command, driver or hook for create/remove

- Creation: `createWorktree` builds the path and runs
  `git worktree add [-b <new>] -- <path> <ref>` directly **[V]** `Core:3705-3760`. The only
  injectable input is `input.path` (callers pass `null`, `TLS:436`), the `worktreesDirectory`
  setting, and `checkout.workers` from git config.
- Removal: `removeLinkedWorktree` runs `git worktree remove [--force] -- <path>` on non-Windows
  hosts **[V]** `worktreeRemoval.ts:40-57`; the Windows branch re-implements git's checks and
  deletes with Node `rm`.
- The settings schema has no key for an external worktree command. Worktree-related server
  settings are `worktreesDirectory`, `previousWorktreesDirectories`, `worktreeCleanup`,
  `defaultThreadEnvMode`, `newWorktreesStartFromOrigin`, `worktreeSubmodules`,
  `branchNamingMode`, `branchNamePrefix`, `branchNameInstructions`, `defaultProjectScripts`,
  `projectScriptOverrides` **[V]** `packages/contracts/src/settings.ts:970-1031, 1137-1147,
  1163-1166, 1241-1242, 1268-1271`.
- GitHub: no issue or discussion mentions "worktrunk", "custom worktree command" or an external
  worktree provider (§7).

### 1.2 Lifecycle points that exist

| Point | Trigger | Where | Blocking? |
|---|---|---|---|
| **Setup script** (`runOnWorktreeCreate: true`) | after `git worktree add` + submodule init, for every thread that gets a `worktreePath` (new **and** existing worktree) | `TLS:569-585` calls `ProjectSetupScriptRunner.runForThread` after `createWorktree` (`TLS:431-455`) **[V]** | `async: false` holds the agent until exit 0; non-zero exit fails the launch (`TLS:596-608`) **[V]**. `async: true` (default) starts the agent immediately (`t3ProjectFile.ts:49-55`) |
| **Settle script** (`runOnSettle: true`) | each time a thread in its own worktree settles; skipped when `worktreePath` is null or the directory is gone | `apps/server/src/orchestration-v2/ThreadSettlementService.ts:546-565` **[V]** | no (terminal) |
| Worktree handoff MCP tool (`t3_worktree_handoff`) | agent-initiated: creates a worktree mid-thread, optionally runs the setup script | `apps/server/src/mcp/WorktreeMcpService.ts:240-290`, schema `packages/contracts/src/worktreeMcp.ts:11-39` **[V]** | n/a |

Not available: pre-create, on-archive, on-delete, on-merge, on-remove. Removal happens at four
places, none of which runs a user script **[V]**:
- thread delete in the UI → confirm dialog → `vcsRemoveWorktree` with `force: true`
  (`apps/web/src/hooks/useThreadActions.ts:438-485, 538-549`, `apps/server/src/ws.ts:2884`);
- storage cleanup sweep (`SC:770-940`, §5);
- rollback of an abandoned/cancelled creation (`TLS:674-700`);
- handoff rollback and review-guide checkouts (`WorktreeMcpService.ts:262`,
  `PullRequestReviewGuideService.ts:319`).

### 1.3 What the setup script gets

- **cwd** = the worktree path **[V]** `apps/server/src/project/ProjectSetupScriptRunner.ts:357`.
- **env**: `T3CODE_PROJECT_ROOT` (the project's main checkout), `T3CODE_WORKTREE_PATH`, plus
  `COLORTERM=""`, `NO_COLOR=1`, `FORCE_COLOR=0` **[V]** `packages/shared/src/projectScripts.ts:52-62`,
  `ProjectSetupScriptRunner.ts:358-386`. **No branch, no base ref.** The branch is readable from
  cwd (`git rev-parse --abbrev-ref HEAD`); the base is not exposed at all (T3 knows it as
  `baseRefName`, `TLS:382-410`, but does not pass it).
- **How it runs**: the command is typed into a fresh interactive terminal of `$SHELL` (zsh gets
  `-o nopromptsp`), prefixed with a space to keep it out of history, and wrapped with a sentinel
  so T3 can detect the exit code **[V]** `apps/server/src/terminal/Manager.ts:482, 530-531`,
  `projectScripts.ts:87-93`, `ProjectSetupScriptRunner.ts:361-375, 380-420`. Consequences:
  `.zshrc` and `zsh/conf.d/*` load, so the `wt` shell function from `65-worktrunk.zsh`, the
  `wt-*` custom subcommands on `~/.local/bin` and interactive prompts (wt approvals) all work
  **[I from the pty + zsh startup; worth one live check]**. On exit 0 the terminal is closed, on
  failure it stays open with the output (`ProjectSetupScriptRunner.ts:429-434`).
- **Race with the branch rename**: for auto-named threads T3 forks the rename
  `t3/<hex>` → `<prefix>/<generated>` right before it starts the setup script
  (`TLS:473-484` fork, `TLS:569` setup) **[V]**. A wt hook that renders `{{ branch }}` during
  setup may therefore see the temporary name. Hooks that only copy files (`copy-ignored`) are
  unaffected; `hash_port`-style hooks are not stable until the rename lands.

### 1.4 Where setup scripts are configured (this matters for the dotfiles)

`resolveProjectScripts` picks, in order: a per-project override
(`projectSettingsOverrides[<id>].defaultProjectScripts`) → if `projectSettingsFolded` →
`defaultProjectScripts` (global) → legacy `projectScriptOverrides` → the project's stored
scripts → `defaultProjectScripts` **[V]** `packages/shared/src/projectScripts.ts:11-21`.

The user's `settings.json` has `projectSettingsFolded: true` **[V live file]**, so a repo's
`t3.json` scripts are **not** picked up automatically; `t3.json` is an import template
("A project's `t3.json` actions can be imported there", `docs/user/project-settings.md:155-157`;
open issue #14991 describes the folded-mode surprise). The lever for the dotfiles is therefore
the global `defaultProjectScripts` array in the settings overlay (§6.2), not a `t3.json`.

`ProjectScript` shape: `{ id, name, command, icon, runOnWorktreeCreate, async?, runOnSettle?,
previewUrl?, autoOpenPreview? }` with `icon ∈ play|test|lint|configure|build|debug` **[V]**
`packages/contracts/src/project.ts:24-45`.

---

## 2. Q2: can T3 attach a thread to an existing (wt-created) worktree?

Yes, in the GUI; no, from the CLI.

- **Server**: `ThreadLaunchWorkspaceStrategy` has `existing_worktree { worktreePath, branch? }`.
  It records the path and branch, runs no git command, then runs the setup script like any other
  worktree thread **[V]** `TLS:56-60, 377-380, 462-470, 569-585`. The agent's cwd is the
  worktree.
- **Branch picker**: `listRefs` annotates every local branch with `worktreePath` from
  `git worktree list --porcelain -z` **[V]** `Core:1192-1210, 3665-3680`, so wt-created worktrees
  appear with the badge "worktree" (`BranchPicker.tsx:276-281`). Selecting such a branch calls
  `resolveBranchSelectionTarget` → `reuseExistingWorktree` → `setThreadBranch(name, path)`, which
  sets the draft's `worktreePath` and `envMode` **[V]** `BranchToolbarBranchSelector.tsx:392-402,
  168-208`, `BranchToolbar.logic.ts:259-277`. Maintainers re-tested with a plain
  `git worktree add` worktree on 2026-10-21: "Selecting the external worktree started the agent
  there, and `t3_worktree_list` returned its correct path" (#1714 comment) **[V]**.
- **"New thread in this worktree"** (branch toolbar) and **previous worktree** (`mod+shift+l`,
  `composer.previousWorktree`) only cover worktrees that other T3 threads of the project already
  use (`resolvePreviousWorktreeSeed` over the project's threads) **[V]**
  `BranchToolbar.tsx:646-664`, `docs/user/keybindings.md:28-30`. They do not see wt-only
  worktrees until one thread has been attached via the branch picker.
- **Scheduled tasks** accept `existing_worktree` with a literal path **[V]**
  `apps/web/src/components/settings/ScheduledTasksSettings.tsx:1235-1236`.
- **CLI**: `t3 thread start <project> --worktree <base-ref> [--branch <name>]` always builds a
  `type: "worktree"` strategy, i.e. creates a new worktree; `--branch` sets the new branch name
  **[V]** `apps/server/src/cli/thread.ts:461-475, 553-561`. `t3 app <path>` only opens a project
  (`cli/app.ts:250-258`). `resolveProject` accepts "a path inside a project" (`thread.ts:274-300`),
  and a worktree under `~/Projects/_worktrees` is not inside the project folder, so a wt worktree
  path cannot be used as the project argument unless it is registered as its own project **[I]**.
- **Registering the worktree itself as a T3 project** works (any folder), but T3 then treats it
  as a plain local checkout (`worktreePath: null`), with its own project id, scripts and thread
  list; cleanup never touches it. Workable as a fallback, not recommended **[I]**.

Does T3 then behave correctly?
- Git status, diffs, PR actions use the thread's `worktreePath` as cwd **[V]**
  `apps/web/src/components/ChatView.tsx:1576-1579`. Fine.
- The setup script runs again on attach (`TLS:571-573`). A `wt hook post-start` is idempotent for
  `copy-ignored`; project hooks with `npm ci` just repeat work.
- Cleanup treats the attached worktree like any thread worktree (§5). Because
  `~/Projects/_worktrees/<repo>/<branch>` lies inside the managed root once `worktreesDirectory`
  points there, it is **eligible** for T3 rules if they are ever switched on, and T3's "delete
  worktree?" prompt appears when the last thread using it is deleted (declining is enough)
  **[V]** `SC:796-798`, `useThreadActions.ts:451-485`.
- Open bug to watch: #11099 (closed 2026-10-11) asked for "new worktree on an existing branch";
  `createWorktree` always passes `newRefName` from the launch path (`TLS:431-440`), so creating a
  worktree for a branch that already exists still fails with git's `-b` error **[V/I]**.

---

## 3. Q3: do wt commands handle T3 worktrees? Can wt hooks run from T3 scripts?

### 3.1 `wt list` / `wt switch` / `wt remove` / `wt merge`

- T3 worktrees are ordinary linked worktrees, so `wt` (which reads git's worktree list) shows
  them, and every command that takes a branch addresses them by branch name regardless of path
  (worktrunk skill rule 1; `switch.md:6` "Worktrees are addressed by branch name") **[V docs]**.
- A T3 worktree whose path is not what the template implies gets the `⚑ branch_worktree_mismatch`
  flag in `wt list` (`list.md:162`). This happens for **every auto-named T3 thread** (directory
  `t3-<hex>`, branch renamed, §4) and for `~/.dotfiles` (naming override). It is cosmetic;
  switching, removing and merging still work.
- `wt remove <t3-branch>` applies the same six integration checks and deletes the branch only if
  it adds nothing to the default branch; `--force` for dirty trees (`remove.md:34-70`). T3 leaves
  no files of its own in the worktree (the `.t3/setup-*` markers come from T3's own repo script,
  not from the app) **[V]** `scripts/setup-worktree.ts:12-16`.
- `wt merge` from inside a T3 worktree works like anywhere else: squash into the default branch,
  remove worktree and branch. See §5 for what that does to the T3 thread.

### 3.2 Running wt hooks for T3-created worktrees

- `wt hook <type>` runs the configured hooks on demand in the current worktree: `cwd` and
  `worktree_path` are the worktree, `branch` is its branch, repo variables resolve, and project
  hooks are read from the worktree's `.config/wt.toml` **[V]** `hook.md` "Running Hooks
  Manually", "cwd" rules, line 63. Since the T3 setup script already runs with cwd = worktree,
  **no `-C` is needed**.
- Variables only defined for switch/create (`base`, `base_worktree_path`, `pr_number`) are
  undefined in a manual run and error out unless the hook guards them or the call passes
  `--base=<ref>` (`hook.md` "Passing values"). The user's global hook
  (`[post-start] copy = "wt step copy-ignored --require-include"`) needs none of them.
- `wt step copy-ignored` copies gitignored files from the default-branch worktree into the current
  one; with `--require-include` it is a no-op in repos without `.worktreeinclude`, which keeps the
  global script safe everywhere.
- **Approvals**: project hooks need a one-time approval per repo. In T3 the prompt shows up in the
  setup terminal (interactive pty), and because the agent is held while `async: false`, the thread
  waits until the user answers. The cleaner path is to approve once from a normal shell with
  `wt config approvals add` before using that repo in T3. Never `--yes` in the T3 script: it would
  silently execute whatever the repo's `.config/wt.toml` says.
- The T3 setup terminal inherits T3's imported env (PATH, SSH_AUTH_SOCK, HOMEBREW_*, …; see
  `research-settings.md` §4) and then sources `.zshrc`, so `wt` resolves. `WORKTRUNK_DIRECTIVE_CD_FILE`
  is unset there, so `wt switch` inside a T3 terminal cannot `cd` the shell; only `wt hook`/`wt step`
  are useful from scripts **[I]**.

---

## 4. Q4: name and path compatibility

| | T3 | Worktrunk (user config) |
|---|---|---|
| root | `worktreesDirectory`, `~` expanded, must be absolute and not a filesystem root **[V]** `apps/server/src/worktreesDirectory.ts:15-27` | `~/Projects/_worktrees` |
| repo segment | `path.basename(path.resolve(project.workspaceRoot))` **[V]** `Core:3712` | `{{ repo }}` = repository directory name; `~/.dotfiles` overridden to `dotfiles` |
| branch segment | `targetBranch.replace(/\//g, "-")` **[V]** `Core:3710` | `sanitize` = `branch.replace(['/', '\\'], "-")` **[V]** `expansion.rs:565, 918-920` |

- Identical for every repo except `~/.dotfiles`: T3 would use `~/Projects/_worktrees/.dotfiles/…`
  (hidden), wt uses `…/dotfiles/…`. Options: accept the mismatch (T3 threads on the dotfiles are
  rare), or always create dotfiles worktrees with `wt` and attach in T3 (Option B). Dropping the
  wt override would hide the tree from Finder/fd/rg again, which is why it exists.
- **Branch names**: T3 creates `t3/<8 hex>` (`packages/shared/src/git.ts:14, 103-112`), or
  `t3-<hex>` if a plain `t3` branch exists, and the directory is `t3-<hex>`. After the first
  message it renames the branch via the text generator with `branchNamingMode`/`branchNamePrefix`
  (static → `<prefix>/<generated>`, semantic → semantic name, custom → exact) **[V]**
  `TLS:333-365, 473-484`; "Worktree directories keep their original names"
  (`docs/user/project-settings.md:59`) **[V]**. So the final branch (e.g. `t3/fix-login`) never
  matches the directory (`t3-1a2b3c4d`), and wt shows `⚑`. Only threads started with an explicit
  branch (CLI `--branch`, handoff `branch`) keep branch = directory, because
  `isTemporaryWorktreeBranch` is false and no rename runs (`TLS:369-376, 476-480`) **[V]**.
- wt-issue branches (`<N>-<slug>`, no prefix) and T3 branches (`t3/…`) coexist without conflict.
  `wt list`'s Task column (`git branch --edit-description`) stays empty for T3 branches.
- `previousWorktreesDirectories` is kept by T3 when `worktreesDirectory` changes, so the default
  `~/.t3/worktrees` keeps being swept and recognised as managed **[V]**
  `worktreesDirectory.ts:34-50`.

---

## 5. Q5: cleanup interplay

### 5.1 What T3 does

- **Archive**: no worktree action. Only `deleted_at` rows count as "deleted" for cleanup **[V]**
  `SC:735-745`; archived threads keep their worktree.
- **Delete thread (UI)**: if the worktree is used by no surviving thread, the project is not a
  scratch folder, the session has source-control write scope and `worktreeOnDelete` is off, T3
  asks "delete the worktree?"; on yes it runs `git worktree remove --force` **[V]**
  `useThreadActions.ts:438-485, 538-549`. **The branch is not deleted** (only the MCP rollback
  path calls `deleteLocalBranch`, `WorktreeMcpService.ts:262-272`). Declining keeps everything.
- **Automatic cleanup** (`worktreeCleanup`, default `null` = off; rules `worktreeAfterDays`,
  `worktreeSettledAfterDays`, `worktreeOnMerge`, `worktreeOnDelete`, `worktreeUnchanged`,
  `worktreeKeepWhen`) **[V]** `settings.ts:948-968`, `packages/shared/src/projectSettings.ts:238-239`.
  A worktree is only removed when: the directory exists, the thread(s) are idle, it is not shared
  (open bug #17816), no T3 terminal is open there, the path is not a symlink, and it is **inside a
  managed root** **[V]** `SC:780-798`; then one of deleted / inactive N days / settled N days /
  "no commits beyond default" / "PR merged" must hold (`SC:830-905`). Folders in the root that no
  thread references (all wt-only worktrees) are only **reported** as "No thread uses this
  worktree", never removed **[V]** `SC:425-448`, `docs/user/project-settings.md:208`.
- **Missing worktree at the next turn**: if a thread's `worktreePath` is gone and the path is
  `<managed root>/<x>/<y>` (two segments), T3 runs `git worktree prune` and
  `git worktree add <path> <branch>` to recreate it, bypassing wt **[V]**
  `apps/server/src/orchestration-v2/ProviderTurnStartService.ts:475-505`,
  `worktreesDirectory.ts:56-110`. If the branch is gone too, the recreate fails with a warning and
  the turn starts against a missing cwd **[I]**.

### 5.2 Cross effects

| Event | Effect on the other tool |
|---|---|
| `wt remove <branch>` on a T3 thread's worktree | T3 keeps the stale binding (no watcher). Next turn: recreated from the branch if wt kept it (`--no-delete-branch` or unmerged), otherwise the thread is broken until deleted or re-bound to "Local" via the branch picker. |
| `wt merge` on a T3 branch | Squash-merged locally, worktree and branch removed → same as above with the branch gone. Delete the T3 thread afterwards (decline its worktree prompt; the directory is already gone). |
| T3 deletes the worktree (UI prompt or rules) | Branch survives. `wt list --branches` / `wt ll` show it as branch-only; `wt gone` lists it once integrated; `wt remove <branch>` cleans the ref (worktree already absent) **[I: wt's branch-only removal path not exercised]**. |
| T3 rules enabled while wt worktrees are attached to threads | Those worktrees become eligible for T3 removal (they are inside the managed root). Keep rules off. |
| wt-issue worktree attached to a T3 thread, then `wt publish` / MR merged | Nothing automatic in T3 (`worktreeOnMerge` is GitHub-PR based and off). Finish with `wt remove` after deleting the thread, as in the wt-issue skill. |

---

## 6. Q6: recommendation

### 6.1 Options considered

| Option | Verdict |
|---|---|
| **A. T3 creates worktrees in the wt root; a global T3 setup script runs `wt hook`** | Recommended default for ad-hoc threads. T3 stays in charge of creation (unavoidable), wt hooks still run, everything is visible in `wt list`. Costs: `⚑` flags, `t3/` prefix, and `.dotfiles` naming. |
| **B. Create with `wt` (incl. `wt issue`), attach the thread in T3 via the branch picker** | Recommended for GitLab tickets (keeps the `<N>-<slug>` branch, MR mode and `wt publish`) and for `~/.dotfiles` (keeps `dotfiles/` naming). Two steps, but every lifecycle event goes through wt. |
| **C. Keep separate (`~/.t3/worktrees`)** | Not recommended: hidden tree, no hooks, no `wt list` visibility; `wt` commands would still "work" on them but nobody would see them. |
| **D. Register wt worktrees as T3 projects** | Fallback only (§2). |

Both A and B rely on the same rule: **removal is always a conscious `wt remove` / `wt merge`
after the T3 thread is deleted**, never T3's automatic cleanup.

### 6.2 What goes into the dotfiles

1. **Settings overlay** (`research-settings.md` §2, the keys below are additions):

   ```json
   {
     "worktreesDirectory": "~/Projects/_worktrees",
     "worktreeCleanup": { "mode": "off" },
     "branchNamingMode": "semantic",
     "branchNamePrefix": "t3",
     "defaultProjectScripts": [
       {
         "id": "worktrunk-hooks",
         "name": "Worktrunk hooks",
         "command": "wt hook pre-start && wt hook post-start",
         "icon": "configure",
         "runOnWorktreeCreate": true,
         "async": false
       }
     ]
   }
   ```

   Notes:
   - `worktreeCleanup: {"mode":"off"}` is explicit (not `null`), so the overlay re-applies it if
     the UI ever turns a rule on.
   - `defaultProjectScripts` is an array: the overlay replaces it wholesale, so any script added
     in the UI must be added to the overlay too. `projectSettingsFolded: true` means this global
     list applies to every project (§1.4).
   - `async: false` holds the agent until the hooks finish (env files must exist before the agent
     starts); the first run in a repo with project hooks also waits for the approval prompt. With
     the global `--require-include` hook, repos without `.worktreeinclude` finish in well under a
     second.
   - `pre-start` is included because T3 does not run it on creation; drop it if a repo's
     `pre-start` is too slow for an interactive start and move that work to `post-start`.
   - Keep `defaultThreadEnvMode` unset (local) and pick "New worktree" per thread until #23639 and
     #23151 are fixed (see `research-settings.md` §2.3).
2. **`t3/AGENTS.md`** (to be written when the integration is applied): the four rules from §6.3
   (worktrees live in the wt root; delete the thread, then `wt remove`; never answer "yes" to T3's
   delete-worktree prompt for wt-issue branches; approvals via `wt config approvals add`).
3. **Optional `t3.json` template** in the dotfiles for repos that are shared with other T3 users:
   same script as above (`scripts[].command`, `runOnWorktreeCreate`, `async`). It is only an
   import template for this user (§1.4), so it is not required for the setup to work.
4. **Optional `wt issue --t3` extension** (§6.4), only after a live test.

Nothing changes in `worktrunk/.config/worktrunk/config.toml`: T3 calls the hooks that are already
configured there.

### 6.3 Daily flow

| Situation | Steps |
|---|---|
| Ad-hoc task in any repo | T3: new thread → workspace "New worktree" → send. T3 creates `~/Projects/_worktrees/<repo>/t3-<hex>`, the setup terminal runs the wt hooks, the agent starts. `wt list` shows it (with `⚑` after the rename). |
| GitLab ticket | Shell: `wt issue 142 --no-agent` (worktree + MR-mode decision, shell cds there). T3: new thread → branch picker → `142-<slug>` (badge "worktree") → send. Publish with `wt publish` from a T3 terminal or the shell. |
| `~/.dotfiles` | Same as the ticket flow with `wt switch --create <branch>`, so the tree stays under `dotfiles/`. |
| Second thread on the same worktree | "New thread in this worktree" or `mod+shift+l`. |
| Finishing (MR mode on) | Merge the MR in GitLab → delete the T3 thread (decline the worktree prompt) → `wt remove 142-<slug>`. |
| Finishing (MR mode off / ad-hoc) | Delete the T3 thread (decline) → `wt merge` from the worktree, or `wt remove <branch>`. |
| A repo with project hooks, first time in T3 | Run `wt config approvals add` in that repo from a shell once; otherwise the first T3 thread waits on the prompt in its setup terminal. |
| Review | `wt what` / `wt rev` from the worktree, as today; the T3 diff panel reads the same worktree. |

### 6.4 Promising but untested: `wt issue --t3`

`t3 thread start . --worktree <base> --branch 142-<slug> "<prompt>"` creates the worktree through
T3 at the exact wt path (explicit branch → no temp name, no rename, `TLS:369-376`), runs the wt
hooks via the global script and starts the thread, all from the shell. Combined with
`wt issue N --branch-only` (branch name + MR-mode decision) this would be a one-command T3 variant
of `wt issue`. To verify before building it: that `resolveProject(".")` finds the registered
project from the main checkout, that `--branch` with the `<N>-<slug>` name survives
`refuseOptionLikeRefName` (`Core:314`), and that the setup script sees `wt` on PATH in the pty
(§1.3). Re-entry on an existing branch will not work (§2, #11099).

---

## 7. GitHub scan (pingdotgg/t3code, 2026-10-22)

| Query / issue | Result |
|---|---|
| "worktrunk", "custom worktree command" | no issues or discussions |
| "external worktree" → **#1714** (closed 2026-10-21) | externally created worktrees shown as "Local": maintainers confirmed that selecting an external worktree in the picker binds the thread correctly; the remaining bug was the handoff tool (#15136, closed 2026-10-21) |
| "existing worktree" → **#3796** (closed, dup of #1047) | "start a thread in an existing worktree" shipped via PR #3798 |
| **#11099** (closed 2026-10-11) | "new worktree on an existing branch instead of forking": the launch path still always passes `newRefName` (`TLS:431-440`) |
| **#17816** (open) | shared worktrees are never cleaned up |
| **#15541** (open) | parallel creation hits the 5-minute git timeout and leaves orphan worktrees |
| **#14991** (open) | scripts saved via `t3_project_update` ignored once settings are folded (matches §1.4) |
| **#23151, #23639, #16524, #12300** (open) | as in `research-settings.md` §2.3: SessionStart hook timeouts in fresh worktrees, new threads sometimes starting local, project subdirectory not preserved, `glab` cannot read `.git` in linked worktrees (relevant for `wt publish` from a T3 terminal: run it from the shell if it fails) |
| "worktree hook", "teardown script", "setup script environment variable" | nothing beyond the above |

---

## 8. Open points to verify live (all read-only or reversible)

1. Start one T3 thread with "New worktree" in a throwaway repo after setting the overlay and confirm:
   path under `~/Projects/_worktrees/<repo>/t3-<hex>`, setup terminal shows the wt hook output,
   `wt list` lists it, and `wt remove <branch>` after deleting the thread leaves nothing behind.
2. Attach a `wt issue … --no-agent` worktree via the branch picker and confirm the composer footer
   shows "Worktree · <branch>" and the diff panel reads it.
3. Check whether `wt` approval prompts render in the T3 setup terminal (§3.2) or whether approvals
   must always be done from a shell first.
4. Try the `t3 thread start … --branch` route (§6.4) once before extending `wt-issue`.

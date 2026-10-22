# T3 Code settings for Claude Code and Codex: research report (2026-10-22)

Sources:
- pingdotgg/t3code @ `2c8bdf61` (2026-10-22, pulled at the start of this research).
- Installed app `0.1.2-nightly.20261021.3473`, `claude 2.1.306`, `codex-cli 0.163.0`.
- Live files under `~/.t3/userdata/`, read only. Credentials were not read.
- `gh issue list -R pingdotgg/t3code` on 2026-10-22.

Paths are relative to the T3 repo root unless noted. `C/settings.ts` means
`packages/contracts/src/settings.ts`.

Markers:
- **[V]**: verified, with a file:line reference.
- **[I]**: inference.

---

## 0. TL;DR: what to change

1. **`t3/AGENTS.md` is wrong about the environment.** On a Dock launch, the desktop process imports the following from `zsh -ilc`, with a 5 s timeout:
   - PATH, SSH_AUTH_SOCK
   - LANG/LC_ALL/LC_CTYPE
   - HOMEBREW_PREFIX/CELLAR/REPOSITORY
   - XDG_CONFIG_HOME/DATA_HOME/RUNTIME_DIR, DISPLAY
   - SSL_CERT_FILE/DIR, NODE_EXTRA_CA_CERTS
   - `__MISE_DIFF`, T3CODE_TELEMETRY_ENABLED
   - `JAVA_HOME` is **not** imported on the desktop path. It is only imported by the server's own fallback, which is skipped when the desktop prepared the env.

   **[V]** `apps/desktop/src/shell/DesktopShellEnvironment.ts:76-99, 316, 395-479`; `apps/server/src/os-jank.ts:28, 102`.
2. **T3 can use the Worktrunk root.** `worktreesDirectory` (server setting) puts T3 worktrees at `<dir>/<repo basename>/<branch with "/"→"-">`. **[V]** `apps/server/src/vcs/GitVcsDriverCore.ts:3715-3736`. This is the same layout as Worktrunk's `~/Projects/_worktrees/{{ repo }}/{{ branch | sanitize }}`. Setting `"worktreesDirectory": "~/Projects/_worktrees"` puts both tools in one tree. Caveats are in §2.3.
3. **The overlay-merge strategy for `settings.json` is right.** Keep it. Add a few portable keys (§2, "overlay additions").
4. **`client-settings.json` is the desktop source of truth, not localStorage.** **[V]** `apps/web/src/localApi.ts:62-72`, `apps/desktop/src/settings/DesktopClientSettings.ts`. T3 reads it **once per app session** and rewrites the **full document** on every UI change. Several portable preferences live there (notifications, plan-mode toggle, context meter, timestamp format …). To track them, use a second overlay that is applied only while T3 is closed (§3).
5. **Auto mode has open bugs that affect this setup.** See §5:
   - #15353: ask rules are skipped in Auto.
   - #22483: the CLI can start in `default` mode on nightlies ≥ 20261020. The user runs 20261021.
   - #23151: SessionStart hooks can exceed the 90 s MCP registration window in fresh worktrees. claude-mem's SessionStart hook is a candidate.
   - Smoke-test Auto per instance before relying on it.

---

## 1. Inventory of every setting

### 1.1 Files and how T3 treats them

| File (`~/.t3/userdata/…`) | Owner / schema | Source of truth | Write style | External edits picked up? |
|---|---|---|---|---|
| `settings.json` | server, `ServerSettings` **[V]** C/settings.ts:1130-1317 | file | sparse: defaults stripped **[V]** `apps/server/src/serverSettings.ts:449-480, 604-626`. Atomic temp+rename, symlink target resolved **[V]** `packages/shared/src/atomicWrite.ts`, `symlink.ts` | **yes, live.** `fs.watch` on the dir plus on the symlink target's dir, 100 ms debounce **[V]** serverSettings.ts:1059-1131 |
| `client-settings.json` | desktop main, `ClientSettingsSchema` **[V]** C/settings.ts:314-487 | file in Electron. localStorage `t3code:client-settings:v1` only in the browser/web build **[V]** `apps/web/src/clientPersistenceStorage.ts`, `localApi.ts:62-72` | **full document** (every key, defaults included). Temp+rename, symlink resolved **[V]** DesktopClientSettings.ts:124-185 | **no.** Hydrated once, then `status === "ready"` short-circuits **[V]** `apps/web/src/hooks/useSettings.ts:131-133`. The next UI change overwrites external edits with in-memory state **[I]** |
| `desktop-settings.json` | desktop main **[V]** `apps/desktop/src/settings/DesktopAppSettings.ts:67-102` | file | sparse (only non-defaults) **[V]** :100-140. Temp+rename, symlink resolved **[V]** :402-460 | read at startup **[I]** |
| `keybindings.json` | server **[V]** `apps/server/src/keybindings.ts` | file, merged with built-in defaults at runtime **[V]** :437 | atomic, symlink resolved **[V]** :411-430. **On startup, missing defaults are back-filled into the file** **[V]** :469, :564. Ids of applied "late defaults" are stored in `keybindings-migrations` **[V]** :387-410 | live, but only `fs.watch(<dir of keybindings.json>)` **[V]** :599. A stow symlink edited at its target does **not** reload until restart **[I from code]** |
| `secrets/`, `clerk-tokens.json`, `statev2.sqlite`, `environment-id`, `model-manifest.json`, `logs/`, `attachments/` | runtime state | — | — | never track |

General notes:
- Server-settings writes are serialized and re-read the file first (`reloadSettings`), so external edits are not lost by a concurrent UI save **[V]** serverSettings.ts:1005-1015.
- A settings.json that fails to decode is left on disk, and T3 runs on defaults **with `continueThreadsAfterServerUpdate:false`**. A UI save then fails instead of overwriting it **[V]** :676-690, :1011-1017. A broken overlay merge therefore fails safely, but it also silently drops `defaultRuntimeMode: auto`, so runs fall back to Full access.
- Secrets: any field annotated `settingsSecret` or `control:"password"`, and per-instance `environment` entries with `sensitive:true`, are moved to the secret store. The file keeps only `""` plus a redaction flag **[V]** serverSettings.ts:620-655, C/settings.ts:525-535, `C/providerInstance.ts:36-41`. Non-sensitive env values stay inline in settings.json.
- Open bug #14967: atomic writes widen the file mode. `t3.sh` writes `0600`, and T3's next save makes it `0644` **[I]**. That is harmless, because no secret values are inline.

### 1.2 ServerSettings (`settings.json`)

Portability classes:
- **P**: portable preference, OK for the public repo.
- **M**: machine-specific.
- **J**: project-scoped (keyed by machine-local ProjectId or path).
- **S**: may contain secrets or identifying data. Keep out of the repo.
- **R**: runtime or server-maintained.

Every key below is also project-overridable when listed in `PROJECT_SCOPED_SERVER_SETTING_KEYS` **[V]** C/settings.ts:970-995. Those keys are marked †.

| Key | Type | Default | Class | Notes |
|---|---|---|---|---|
| `favorites` | `{provider,model}[] \| null` | null | P/R | model favorites, migrated here from client settings |
| `providerModelPreferences` | `Record<instanceId,{hiddenModels,modelOrder}> \| null` | null | P | per-instance model order/hide |
| `worktreeCleanup` † | null \| `{mode:off}` \| `{mode:custom,rules}` | null (inherit `storageCleanup`) | P | |
| `storageCleanup` | `{worktreeKeepWhen, worktreeAfterDays, worktreeSettledAfterDays, worktreeOnMerge, worktreeOnDelete, worktreeUnchanged, browserArtifactsAfterDays, logsAfterDays}` | `uncommitted-changes`, null, null, false, false, false, null, null | P | **[V]** C/settings.ts:1112-1128 |
| `worktreesDirectory` | string | `""` → `~/.t3/worktrees` | P (if `~/`-relative) | `~` expanded; must be absolute and not a root **[V]** `apps/server/src/worktreesDirectory.ts:16-27` |
| `previousWorktreesDirectories` | string[] | [] | R | server-maintained, so old roots stay cleanable |
| `responseStreamingMode` † | `turn\|paragraph` | paragraph | P | |
| `enableProviderUpdateChecks` | bool | true | P | |
| `continueThreadsAfterServerUpdate` † | bool | true | P | |
| `enableAgentBrowserAccess` † | bool | true | P | |
| `projectAgentBrowserAccessOverrides` | `Record<ProjectId,bool>` | {} | J | |
| `defaultAutoPull` † | bool | false | P | |
| `defaultProjectScripts` † | ProjectScript[] | [] | P (if generic) | run on the host at worktree creation / thread settle |
| `projectScriptOverrides` | `Record<ProjectId,…>` | {} | J | |
| `projectAutoPullOverrides` | `Record<ProjectId,bool>` | {} | J | |
| `defaultModelSelection` † | `{instanceId, model, options?[]}` \| null | null | P | live: `codex / gpt-6.1-sol` |
| `defaultRuntimeMode` † | `approval-required\|auto-accept-edits\|auto\|full-access` | **full-access** **[V]** `C/providerPolicy.ts:32` | P | overlay: `auto` |
| `projectSettingsOverrides` | `Record<ProjectId, ProjectSettingsOverrides>` | {} | J | |
| `projectSettingsFolded` | bool | false | R | |
| `enableAgentDeviceAccess` † | bool | false | P | |
| `enableDeviceSupport`, `deviceOnboardingCompleted` | bool | false | M/R | |
| `deviceHosts`, `easDeviceHosts` | arrays | [] | M/S | SSH/EAS hosts |
| `sidebarAutoSettleAfterDays` † | 1-90 \| null | 3 | P | |
| `compactIdleThreads` | bool (legacy) | false | R | written alongside `idleCompaction` for old clients **[V]** :1391-1395 |
| `idleCompaction` | `onReturn\|beforeCacheExpires\|off` | (absent → onReturn) | P | per-Claude-instance override exists |
| `snoozeLimitedThreads` | bool | false | P | "Snooze usage-limit stops until the reported reset time" |
| `autoResumeLimitedThreads` | bool | false | P | "Resume usage-limit stops at the reported reset time", same instance |
| `sidebarAutoSettleKeepPullRequests` † | bool | false | P | |
| `sidebarAutoSettleOnMerge` † | bool | true | P | |
| `backgroundActivity` | `{schemaVersion, profile, baseProfile?, overrides{…}}` | balanced | P | |
| `automaticGitFetchInterval` | ms | 30000 | P | |
| `providerHealthRefreshInterval` | ms | 300000 | P | |
| `backgroundActivityProfile` | balanced\|performance\|battery-saver | balanced | P (legacy) | |
| `defaultTheme`, `defaultThemeSetAt` | string | "" | R | set by `t3 theme set`, not by patch |
| `environmentIcon` | machine kind \| null | null | M | |
| `defaultThreadEnvMode` † | `local\|worktree` \| null | null → repo `t3.json` → local | P | |
| `newWorktreesStartFromOrigin` † | bool | true | P | |
| `worktreeSubmodules` † | recursive\|top-level\|none \| null | null → t3.json → recursive | P | |
| `addProjectBaseDirectory` | string | "" | P | e.g. `~/Projects` |
| `textGenerationModelSelection` † | ModelSelection | `codex / gpt-6-luna / reasoningEffort=low` **[V]** :1254-1267, `C/model.ts:138-141` | P | commit messages, titles, branch names |
| `branchNamingMode` † | static\|semantic\|custom | static | P | |
| `branchNamePrefix` † | string | `t3` | P | |
| `branchNameInstructions` † | string | "" | P | |
| `removeAgentCreditsOnMerge` † | bool | false | P | strips agent co-author lines on GitHub merges |
| `sourceControlWritingStyle` † | `{mode: repo_conventions\|conventional_commits\|custom, customInstructions, followChangeRequestTemplates}` | repo_conventions, "", true | P | |
| `sourceControlWriterModelSelection` † | ModelSelection \| null | null (uses text-gen model) | P | |
| `reviewGuidesEnabled` | bool | false | P | |
| `reviewGuideModelSelection` †, `reviewGuideInstructions` † | | null, "" | P | |
| `pullRequestMergeMethod` † | merge\|squash\|rebase \| null | null | P | |
| `providerInstances` | `Record<id,{driver, displayName?, accentColor?, environment?[], enabled?, config?}>` | {} (implicit `codex`, `claudeAgent`) | P (if no sensitive env) | per-driver config below |
| `observability` | `{otlpTracesUrl, otlpMetricsUrl, otlpLogsUrl}` | "" | M | |
| `sourceControlHosts` | `Record<host,…>` | {} | S/M | tokens redacted, still identifying |
| `usageLimitSources` | `Record<id,{kind:cliproxy,label?,url,managementKey(secret),enabled}>` | {} | S | |
| `cursorKeychainUsageEnabled` | bool | false | P | |
| `usagePriceOverrides`, `usageModelAliases` | records | {} | P | |

**Provider-instance `config` per driver:**

| Driver | Key | Type / default | Notes |
|---|---|---|---|
| `claudeAgent` **[V]** C/settings.ts:670-737 | `enabled` | true | |
| | `binaryPath` | `claude` | becomes `pathToClaudeCodeExecutable` |
| | `homePath` | "" | becomes `CLAUDE_CONFIG_DIR`, with `~` expanded. HOME untouched **[V]** `apps/server/src/provider/Drivers/ClaudeHome.ts:30-47` |
| | `customModels` | [] | string or `{slug,name,capabilities}` |
| | `launchArgs` | "" | parsed into SDK `extraArgs`. `--permission-mode` / `--dangerously-skip-permissions` **override the T3 runtime mode** **[V]** ClaudeAdapterV2.ts:1306-1355. `--settings` is replaced (#15073) |
| | `autoCompactWindow` | "" (100000-1000000) | passed as SDK setting `autoCompactWindow` **[V]** :1343-1348 |
| | `idleCompaction` | `default` | |
| `codex` **[V]** C/settings.ts:588-643 | `setupMode` | absent | only `"managed"` changes behaviour. `"existing"` is equivalent to unset **[V]** `apps/server/src/provider/Drivers/CodexDriver.ts:123` |
| | `enabled` | true | |
| | `binaryPath` | `codex` | |
| | `homePath` | "" → `~/.codex` | sets `CODEX_HOME` |
| | `shadowHomePath` | "" | per-account auth with shared state. Breaks Computer Use / bundled plugins (#23652) |
| | `launchArgs` | "" | extra args to `codex app-server` |
| | `customModels` | [] | |
| all drivers | `environment[]` | `{name, value, sensitive=false}` | merged over process env, with `~` expanded only for `CODEX_HOME` / `CLAUDE_CONFIG_DIR` **[V]** `packages/provider-core/src/server/instanceEnvironment.ts` |

### 1.3 ClientSettings (`client-settings.json`, Electron)

All keys are portable UI preferences (P) unless noted. Defaults are from **[V]** C/settings.ts:314-487. The "live" column shows non-default values found in the current file.

| Key | Default | Live | Note |
|---|---|---|---|
| `notificationMode` (off\|notifications\|sound\|notifications-and-sound) | off | off | **relevant** |
| `inAppNotificationsEnabled` | false | false | relevant |
| `diffColorScheme` (red-green\|blue-orange) | red-green | | |
| `chatWidth` (comfortable\|wide\|full) | comfortable | | |
| `loadBalancingEnabled` / `loadBalancingWeights` | false / {} | | balances across *environments*, not accounts |
| `appearanceContrast` 50-200 | 100 | | |
| `panelAnimationDurationMs` 0-400 | 0 | | |
| `browserDefaultViewport` / `ZoomFactor` / `Appearance` | fill / 1 / system | | |
| `browserRecordingFrameRate` / `ShowKeyPresses` / `ShowMousePresses` | 30 / false / false | | |
| `browserLinkTarget` (system\|app) | system | | |
| `browserSearchEngine` / `browserCustomSearchUrl` | duckduckgo / "" | (absent: file predates key) | |
| `browserAutoShowFloatingPreview` | true | | |
| `browserProfiles` / `browserDefaultProfileId` | [] / default | | M (profile ids) |
| `confirmQuit` (direct\|hold\|double-click) | hold | | |
| `confirmThreadArchive` / `Delete` / `Unpin` | false / true / false | | |
| `dismissedProviderUpdateNotificationKeys` | [] | | R, don't track |
| `diffFilesCollapsed` / `diffIgnoreWhitespace` / `diffLayout` | true / true / stacked | | |
| `environmentIdentificationMode` (artwork\|pill\|none) | artwork | | |
| `glassOpacity` 40-100 | 80 | **75** | |
| `fontSizeInterface/Prompt/Code/Terminal` | 16/14/13/12 | | |
| `fontFamilyCode/Composer/Sans/Terminal` | "" | | |
| `fontSmoothing` | true | **false** | |
| `onboardingCompletedAt` | null | set | R, don't track |
| `persistComposerContextStrip` | false | | |
| `favorites` / `providerModelPreferences` | [] / {} | | legacy; migrated to server **[V]** C/settings.ts:1485-1494 |
| `pullRequestMergeMethodOverrides` | {} | | J (keyed by repo) |
| `pullRequestLinksOpenInApp` | true | | |
| `planModeEnabled` | false | false | "Plan mode (legacy): restore Build/Plan, /plan, /default, Shift+Tab. Off uses build mode." **relevant** |
| `contextWindowMeterEnabled` | false | false | relevant (no status line in T3) |
| `composerCollapseOnScroll` / `composerRichTextEnabled` | true / true | | |
| `sendShortcut` (enter\|mod-enter-multiline\|mod-enter) | enter | | |
| `followUpBehavior` (queue\|steer) | queue | | relevant |
| `proactivePanelsEnabled` | false | | |
| `showSkillsInSlashMenu` | true | true | relevant |
| `legacySidebarEnabled` / `sidebarWorkingShelfEnabled` | false / false | | |
| `sidebarProjectGroupingMode` / `…Overrides` | repository / {} | | overrides are J |
| `sidebarProjectSortOrder` / `sidebarThreadSortOrder` / `sidebarThreadPreviewCount` | updated_at / updated_at / 6 | | |
| `timestampFormat` (locale\|12-hour\|24-hour) | locale | **24-hour** | |
| `snapShot*` (Enabled, IncludeAccessibility, Shortcut, PlaySound, Sound, Flash, Animations) | false, true, both-shift, true, soft-pop, true, true | | |
| `wordWrap` | true | | |
| `mathRenderingEnabled` | false | (absent) | |

### 1.4 Desktop settings (`desktop-settings.json`)

All of these are machine-specific (M). Do not track them. **[V]** DesktopAppSettings.ts:67-102.

| Key | Default | Live |
|---|---|---|
| `localEnvironmentEnabled` | true | |
| `linuxPasswordStore` | (linux) | |
| `mainWindowBounds` | null | set |
| `mainWindowMaximized` | false | true |
| `serverExposureMode` (local-only\|network-accessible) | local-only | |
| `tailscaleServeEnabled` / `tailscaleServePort` | false / default port | |
| `updateChannel` (latest\|nightly) | from app version | nightly |
| `updateChannelConfiguredByUser` | false | true |
| `wslBackendEnabled`, `wslMode`, `wslDistro`, `wslOnly` | Windows only | |

### 1.5 Keybindings (`keybindings.json`)

- The file is an array of `{key, command, when?}` rules.
- Runtime = file rules plus `DEFAULT_KEYBINDINGS`. Missing defaults are back-filled into the file at startup unless they conflict with a custom rule **[V]** keybindings.ts:460-570.
- The live file is defaults only, with one recorded migration (`composer.sendBackground:mod+enter`).
- Class: P.
- Tracking only pays off once a binding is customized, and even then the file churns when new defaults are back-filled.

---

## 2. Recommended values for Claude Code / Codex use

### 2.1 Permission / runtime mode

| Setting | Recommend | Why |
|---|---|---|
| `defaultRuntimeMode` | `"auto"` (already in the overlay) | It maps to Claude `permissionMode:"auto"` **[V]** ClaudeAdapterV2.ts:2078-2079. The `autoMode` allow/soft_deny rules in `~/.claude/settings.json` apply, because the forest links that file. For Codex it means `approvalPolicy:on-request, approvalsReviewer:auto_review, sandbox:workspaceWrite` **[V]** CodexAdapterV2.ts:700-706. This is the closest match to the CLI `defaultMode: auto`. |
| Claude `launchArgs` | leave empty | `--permission-mode` / `--dangerously-skip-permissions` in launchArgs override T3's mode **[V]** :1306-1355. `--settings` is silently replaced (#15073). `--append-system-prompt` is folded in, which is fine. |
| Codex `config.toml` `approval_policy` / `sandbox_mode` | irrelevant in T3 | T3 sends approvalPolicy, sandboxPolicy and approvalsReviewer explicitly on **every** turn **[V]** CodexAdapterV2.ts:732-807. |

Two caveats:
- If the Claude settings ever contain `disableAutoMode:"disable"`, T3 downgrades Auto to `default` **[V]** ClaudeAdapterV2.ts:2104-2112, 2180-2188.
- Open bug #15353 means Auto does **not** honour `permissions.ask` rules. The user has no `ask` rules today, only autoMode `soft_deny`, so the impact is low. Re-check if ask rules are added.

### 2.2 Model, effort, compaction

| Setting | Recommend | Why |
|---|---|---|
| `defaultModelSelection` | `{"instanceId":"codex","model":"gpt-6.1-sol"}` (current). Add it to the overlay. | Matches the CLI `model = "gpt-6.1-sol"`. **Leave `options` out.** Then Codex falls back to the model default / `config.toml` (`model_reasoning_effort="ultra"`, `service_tier="priority"`) **[I]**. T3 only sends `effort` / `serviceTier` when a selection carries them **[V]** CodexAdapterV2.ts:739-751. Effort ids are dynamic from `model/list` (`reasoningEffort`, `serviceTier`) **[V]** `apps/server/src/provider/CodexProvider.ts:203-235`. |
| Claude default model per instance | none (T3 has no per-instance default) | `defaultModelSelection` is global. The model picker remembers per thread. |
| `textGenerationModelSelection` | leave at default (codex / gpt-6-luna / low) | Cheap, and it spends ChatGPT quota rather than a Claude window. Pinning it risks a stale slug after T3 bumps its default **[I]**. |
| `sourceControlWriterModelSelection` | null (default) | |
| Claude `autoCompactWindow` | "" | Keeps Claude's own default, the same as the CLI (no `autoCompactWindow` in `~/.claude/settings.json`). |
| `idleCompaction` | leave at the default `onReturn` (don't put it in the overlay) | `beforeCacheExpires` is beta and spends tokens on idle threads. |
| `customModels` | none | Don't put it in the overlay: arrays replace, so UI additions would be wiped. |

### 2.3 Worktrees: T3 together with Worktrunk

- **[V]** T3 creates `<worktreesDirectory>/<basename(project cwd)>/<branch.replace("/", "-")>` via `git worktree add` (`GitVcsDriverCore.ts:3715-3740`).
- Worktrunk is configured as `~/Projects/_worktrees/{{ repo }}/{{ branch | sanitize }}` (live `~/.config/worktrunk/config.toml`).

**Recommendation: `"worktreesDirectory": "~/Projects/_worktrees"`** in the overlay.
- Both tools then share one visible tree. fzf, yazi, nvim pickers and `wt list` see T3 worktrees (they are normal linked worktrees).
- T3 stops filling the hidden `~/.t3/worktrees`, which is currently empty.

Caveats:
- **Names diverge for `~/.dotfiles`.** T3 uses `.dotfiles`, while the wt config overrides that repo to `dotfiles`. Other repos match, because both use the on-disk directory name **[I]** (wt's `sanitize` replacing `/` was not checked in wt source).
- **wt hooks don't run for T3-created worktrees.** T3 runs its own `defaultProjectScripts` / repo `t3.json` instead. Env files etc. that wt's post-start hooks copy will be missing in T3 worktrees **[I]**.
- **Cleanup safety:** T3 only *removes* worktrees attached to its threads, and only per the cleanup rules (all off by default). Foreign folders under the root are only *reported* as orphans (`outcome:"kept"`) **[V]** `apps/server/src/storageCleanup.ts:358-450`. Conversely, `wt remove` on a T3 thread's worktree breaks that thread **[I]**.
- **Branch names:** T3 defaults to `t3/<...>` (`branchNamePrefix:"t3"`, `branchNamingMode:"static"`). Recommend `branchNamingMode:"semantic"` and keeping prefix `t3`. T3 branches stay recognisable in `wt list`, and wt-issue branches keep their own scheme.
- **Codex trust:** `~/.codex/config.toml` trusts project paths individually. New worktree paths are untrusted, so project-level `.codex/` config may not load in them **[I]**. T3 still sets the sandbox explicitly.
- Bugs that apply: #23639 (new threads sometimes start in the main checkout even with "New worktree"), #16524 (project subdirectory not preserved), #12300 (glab cannot read `.git` in T3 worktrees; relevant for the GitLab work), #23151 (fresh-worktree SessionStart hook timeouts).

**`defaultThreadEnvMode`:** leave it null, which means local, and choose "worktree" per thread until #23639 and #23151 are fixed. `newWorktreesStartFromOrigin: true` (the default) is fine.

### 2.4 Limits, resume, notifications

| Setting | Recommend | Why |
|---|---|---|
| `autoResumeLimitedThreads` | `true` | Resumes **the same instance** at its reported reset. That is compatible with the "no account hopping" rule in `clauth/AGENTS.md`. |
| `snoozeLimitedThreads` | `true` | Keeps limited threads out of the inbox until the reset. Pairs with auto-resume. |
| `continueThreadsAfterServerUpdate` | true (default) | |
| `notificationMode` (client) | `"notifications"` | herdr / Superset hooks no-op in T3 (no `HERDR_ENV` / `SUPERSET_HOME_DIR`), so T3 is the only signal. |
| `inAppNotificationsEnabled` (client) | true | |

### 2.5 Composer / Claude-CLI parity (client)

| Setting | Recommend | Why |
|---|---|---|
| `showSkillsInSlashMenu` | true (default) | The skills come from the forest's `skills/` link. Gap: #23507 (skills-directory plugin skills missing from `$`). |
| `planModeEnabled` | true | Restores the Build/Plan toggle, `/plan`, and Shift+Tab as in the CLI. Off means build-only. |
| `contextWindowMeterEnabled` | true | Partial stand-in for the CLI status line, which T3 has no equivalent for. |
| `followUpBehavior` | `"steer"` if CLI-like mid-turn steering is wanted, else `queue` | preference |
| `timestampFormat` 24-hour, `glassOpacity` 75, `fontSmoothing` false | keep (current prefs) | |

### 2.6 Git / PR

| Setting | Recommend | Why |
|---|---|---|
| `removeAgentCreditsOnMerge` | `true` | Global rule: never add Co-Authored-By. `includeCoAuthoredBy:false` is already set for Claude, but Codex and T3's writer are not covered. Note that it only acts on GitHub merges. |
| `sourceControlWritingStyle.mode` | `repo_conventions` (default) | Repos differ, and dotfiles use gitmoji plus Conventional Commits. `repo_conventions` follows the history. |
| `pullRequestMergeMethod` | null | per repo |
| `defaultAutoPull` | false (default) | |

### 2.7 Other

| Setting | Recommend | Why |
|---|---|---|
| `enableProviderUpdateChecks` | `false` **[I]** | `claude` comes from Homebrew and `codex` lives in `~/.local/bin`, both updated via `update`. In-app updates can fight brew (see #19252 for shared-install update failures). Keep `true` only if notifications without action are wanted. |
| `addProjectBaseDirectory` | `"~/Projects"` | |
| Per-instance `environment` | none needed | `~/.claude/settings.json` `env` is `{}`, and no `CLAUDE_*` / `CODEX_*` vars are exported in zsh. Never put `sensitive:true` entries in the overlay: arrays replace, and redacted values would clash. |

**Overlay additions (portable, enforced):**

```json
{
  "defaultRuntimeMode": "auto",
  "defaultModelSelection": { "instanceId": "codex", "model": "gpt-6.1-sol" },
  "worktreesDirectory": "~/Projects/_worktrees",
  "autoResumeLimitedThreads": true,
  "snoozeLimitedThreads": true,
  "removeAgentCreditsOnMerge": true,
  "branchNamingMode": "semantic",
  "addProjectBaseDirectory": "~/Projects",
  "enableProviderUpdateChecks": false
}
```

Notes on the overlay:
- Overlay keys equal to T3 defaults are stripped by T3 on its next save. `just t3` re-adds them, which only causes churn and does no harm. Prefer keys that differ from defaults. `enabled:true` inside providerInstances is not stripped, because `config` is opaque.
- Keep `setupMode:"existing"`. It is a no-op but documents intent, and it protects against the onboarding wizard writing `managed` (#5817 / #17461).

---

## 3. Dotfile strategy per file

| File | Strategy | Reasoning |
|---|---|---|
| `settings.json` | **overlay deep-merge (keep as is)** | A stow symlink would technically work: writes resolve the link **[V]** atomicWrite.ts, and the watcher follows the link target **[V]** serverSettings.ts:1091-1121. But T3 would then write `projectSettingsOverrides` (ProjectIds), `previousWorktreesDirectories`, `favorites`, `sourceControlHosts`, `deviceHosts` etc. straight into the public repo. The overlay is applied live, because the watcher sees `mv` into the dir. |
| `client-settings.json` | **optional second overlay, applied only while T3 is not running.** Otherwise don't track. | Full-document writes plus read-once hydration mean that a merge while T3 runs is ignored, then overwritten on the next UI change **[V]** useSettings.ts:131-133, DesktopClientSettings.ts:124-185. The candidate overlay is `notificationMode`, `inAppNotificationsEnabled`, `planModeEnabled`, `contextWindowMeterEnabled`, `followUpBehavior`, `timestampFormat`, `glassOpacity`, `fontSmoothing`. In `t3.sh`: `pgrep -f "T3 Code"` → skip with a hint. A symlink is not recommended: the file holds `onboardingCompletedAt`, `dismissedProviderUpdateNotificationKeys`, `browserProfiles`, and repo-keyed overrides. |
| `desktop-settings.json` | don't track | window bounds and update channel are machine state |
| `keybindings.json` | don't track until something is customized. Then a "custom rules" overlay merged by script (dedupe on `command`+`when`), or stow if churn is acceptable. | Startup back-fills defaults into the file, which with stow means commits into the repo **[V]** keybindings.ts:564. The watcher only watches the link's own directory, so edits at the stow target need a restart **[V]** :599. |

---

## 4. Environment when launched from the Dock

- **[V]** The desktop runs `$SHELL -ilc <capture>` (interactive **and** login, so `.zshrc` is sourced) with a 5 s timeout. If no PATH comes back, it falls back to `launchctl getenv PATH` (`DesktopShellEnvironment.ts:104, 307-323, 414-420`).
- On this machine `env -i HOME=… zsh -ilc` takes **0.33 s** and resolves `codex` (`~/.local/bin`), `claude` (`/opt/homebrew/bin`) and `herdr`, so `binaryPath: "codex" / "claude"` resolve **[V measured]**. Bug #10534 (a timeout recorded as success) does not apply at this speed. If `.zshrc` ever grows past 5 s, use absolute `binaryPath` values.
- **Imported** **[V]** :76-99, 425-466:
  - PATH (merged), SSH_AUTH_SOCK
  - LANG/LC_ALL/LC_CTYPE as a group. If none is set, the fallback is `LC_CTYPE=en_US.UTF-8`.
  - HOMEBREW_PREFIX/CELLAR/REPOSITORY
  - XDG_CONFIG_HOME/DATA_HOME/RUNTIME_DIR, DISPLAY/WAYLAND/DBUS/XDG_SESSION_*
  - SSL_CERT_FILE/DIR, NODE_EXTRA_CA_CERTS
  - T3CODE_TELEMETRY_ENABLED, `__MISE_DIFF`
- **Not imported:** everything else. From the user's zsh that means EDITOR, BAT_THEME, MANPAGER, FZF_*, EZA_*, HOMEBREW_NO_AUTO_UPDATE / HOMEBREW_BUNDLE_FILE, ZSH_CACHE_DIR, HERDR_*, and JAVA_HOME. The server's `fixPath` imports JAVA_HOME but returns early when the desktop prepared the env **[V]** `os-jank.ts:28, 102`.
- **What breaks for this user:**
  - Nothing critical. No `CLAUDE_*` / `CODEX_*` / API vars are exported in zsh, and the Claude `settings.json` `env` is empty.
  - HERDR / SUPERSET hooks no-op (intended).
  - `HOMEBREW_BUNDLE_FILE` is missing, so an agent running `brew bundle` in T3 would not find `~/.Brewfile` **[I]**. Add it to `~/.claude/settings.json` `env` if that matters, or as a non-sensitive per-instance `environment` entry.
  - Interactive tools that need EDITOR are irrelevant to agents.
- **How to provide env:**
  1. For Claude, prefer `~/.claude/settings.json` `env`. It applies to CLI and T3 alike through the forest link.
  2. For Codex, use `config.toml` `shell_environment_policy.set`.
  3. Use per-instance `environment` only for values that must differ per account. Mark secrets `sensitive:true` in the UI; never put them in the overlay.
- T3 itself sets only `CLAUDE_CONFIG_DIR` for `homePath` and leaves HOME alone **[V]** ClaudeHome.ts:30-47. Each instance has its own continuation group (`claude:home:<path>`), so switching a thread between `claudeAgent` and `claudeWork` is a hand-off, not a resume **[V]** ClaudeHome.ts:66-75 (see #23086).
- Forest risk **[I]**: shared links such as `daemon/`, `sessions/`, `jobs/`, `session-env/` and `shell-snapshots/` are per-process Claude state shared across both accounts and the CLI. Watch for cross-talk. `.claude.json`, credentials, `policy-limits.json` and `remote-settings.json` are already excluded.
- Status: both forests still report `loggedIn: false` (`CLAUDE_CONFIG_DIR=~/.claude-t3/{private,work} claude auth status`). The logins are the remaining manual step.

---

## 5. Open GitHub issues that matter (pingdotgg/t3code, open as of 2026-10-22)

**Permission modes**
- **#22483**: Claude Full access asks on every tool call since nightly 20261020. The CLI init reports `permissionMode: default`, and T3 no longer sends `set_permission_mode`. A commenter sees it on 0.1.2-nightly.20261021 / claude 2.1.306, which is exactly this setup. It may affect Auto too **[I]**. Smoke-test: the thread's provider log should show `system/init permissionMode=auto`.
- **#15353**: Claude Auto mode runs `permissions.ask` commands without prompting.
- **#18386**: a Claude thread blocked by auto-mode denials ends as "Completed".
- **#22147**: switching a running Claude thread to Full access doesn't take effect.
- **#13987**: Codex Auto / Auto-accept-edits reset sandbox network access to false.
- **#20266**: Codex `.env` read-deny entries are lost after Auto → Full → Auto.

**Provider instances / multi-account**
- **#19025**: instance setting changes don't reach live sessions. Use "Restart agent session" after `just t3`.
- **#18762**: an instance switch isn't synced across devices and reverts.
- **#23086**: switching back to a Claude instance resumes a large, cold context.
- **#22748**: switching instance mid-turn kills the turn.
- **#20343**: the old Claude process keeps running after sending to another instance.
- **#16565**: the MCP token keeps the old provider after switching back.
- **#3530**: Max OAuth verifies but every generation 401s, only in T3.
- **#22816**: a token from the shell profile is not seen. Not this setup, which uses keychain logins.
- **#20245**: a custom `ANTHROPIC_BASE_URL` instance sends the OAuth token.

**Codex**
- **#23720**: `codex login` account switches are not picked up by the running shared app-server. Restart T3 after re-login.
- **#23652**: shadow-home instances lose Computer Use and bundled plugins. Avoid `shadowHomePath`.
- **#5817**: new Codex runtime entries can disable existing shadow-home providers.
- **#17461**, **#16132**: managed-mode auth problems. A reason to stay on `existing`.
- **#19252**: Codex update fails when instances share one install.
- **#21435**: the Codex provider fails to start on nightly.

**Skills / plugins / hooks / MCP**
- **#23507**: skills-directory plugin skills are missing from the `$` picker.
- **#11161**: same-name skills collide.
- **#17418**: commands registered by Claude Code mods are missing from `/`.
- **#17531**: UI-dependent Claude Code mods (tool.call + pane) hang Bash calls.
- **#22949**: plugin Stop-hook summaries are shown as warnings after every turn.
- **#23151**: in fresh worktrees, SessionStart hooks longer than the 90 s `setMcpServers` limit fail the turn. Check claude-mem's SessionStart hook latency.
- **#14878**: MCP elicitations are declined without a prompt.
- **#16465**: Claude threads get T3 instructions meant for other agents.
- **#15073**: the `--settings` launch arg is replaced.
- **#16672**: custom-model effort / thinking selections are dropped.

**Worktrees / env / files**
- **#23639**: new threads sometimes start in the main checkout.
- **#16524**: the project subdirectory is not preserved in worktrees.
- **#12300**: glab can't read `.git` in T3 worktrees (GitLab MR linking).
- **#9245**: symlinked path identity.
- **#23727**: a symlinked T3 home confuses session import.
- **#10534**: the macOS PATH capture timeout is recorded as success.
- **#14967**: atomic writes widen the file mode and are not crash-durable.

---

## 6. Corrections to the current dotfiles docs

- `t3/AGENTS.md`, "Environment" says *"T3 only imports PATH and JAVA_HOME"*. Replace it with the list in §4: JAVA_HOME is *not* imported on the desktop path, but SSH_AUTH_SOCK, locale, HOMEBREW_*, XDG_* and the CA vars are.
- `_planning/t3code-integration.md` §4: "client-settings.json (UI preferences only)" is accurate. Add that the file is the Electron source of truth, is read once per session, and is written as a full document. Model favorites and order moved to server `settings.json` (`favorites`, `providerModelPreferences`).
- Add the `worktreesDirectory` decision (§2.3) to `t3/AGENTS.md`, together with the `.dotfiles` / `dotfiles` naming caveat.

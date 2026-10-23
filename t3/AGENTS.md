# t3 — Agent Instructions

Config for [T3 Code](https://github.com/pingdotgg/t3code), a GUI that drives
Claude Code and Codex. Research and decisions: `_planning/t3code-integration.md`
and `_planning/t3code/`.

## This is not a stow package

`~/.t3/userdata/` mixes settings with runtime state: `statev2.sqlite`,
`secrets/`, `clerk-tokens.json`, `logs/`, `attachments/`. Stowing it would put
that state one write away from this public repo. So nothing is linked; the
JSON files here are **overlays** that `_install/t3.sh` (`just t3`) deep-merges
into the live files — overlay keys win, everything else T3 stored is kept:

| Overlay | Live file | When |
|---|---|---|
| `settings.json` | `~/.t3/userdata/settings.json` | always; T3 watches the file and reloads live |
| `client-settings.json` | `~/.t3/userdata/client-settings.json` | only while T3 is closed — the app reads it once per start and rewrites the whole file on every UI change |

`.stow-local-ignore` only exists so an accidental `stow t3` cannot link them.

Rules for the overlays:

- Arrays replace instead of merging. `defaultProjectScripts` is therefore owned
  by the overlay (UI edits to global scripts get reset); `customModels` and
  per-instance `environment` stay out so UI additions survive.
- Never add project-scoped keys (`projectSettingsOverrides`,
  `projectScriptOverrides`): they are keyed by machine-local project IDs.
- Keys equal to T3's defaults are stripped by T3 on its next save; `just t3`
  re-adds them. Harmless churn — prefer keys that differ from the defaults.

## Theme and fonts

Everything else runs Catppuccin Mocha (Ghostty, Neovim, Zed, Cursor, lazygit,
k9s, herdr), so T3 does too. `themes/catppuccin-mocha.json` uses T3's seeded
theme format (`canvas` + `accent`, T3 derives the rest, `colors` overrides
roles by their theme-editor names). Canvas is Mantle `#181825` to match
Ghostty's background, accent Mauve like lazygit.

`just t3` copies `themes/*.json` into `~/.t3/userdata/themes/` (filename = id)
and sets `defaultTheme` in `settings.json` — what `t3 theme set` does. It writes
`defaultThemeSetAt` only when the id changes, because each new timestamp makes
every client re-apply the theme and would undo a pick made in Settings.
Changing colors in the file needs no re-set: clients follow a published theme.

Fonts (`client-settings.json`): Lilex Nerd Font at 14 for code and the
terminal, like Ghostty/Zed; UI and composer keep the system font.

`keybindings.json` and `desktop-settings.json` are not tracked: the first holds
only T3's defaults (T3 back-fills it on start), the second only window bounds
and the update channel.

## Accounts = provider instances

| Instance id | Account | Config |
|---|---|---|
| `claudeAgent` | private Claude subscription | `homePath: ~/.t3/userdata/providers/claudeAgent/claudeAgent/home` |
| `claudeWork` | work Claude subscription | `homePath: ~/.t3/userdata/providers/claudeAgent/claudeWork/home` |
| `codex` | ChatGPT subscription | `setupMode: existing` → the CLI login in `~/.codex` |

- `claudeAgent` and `codex` are T3's default instance ids (= driver name);
  keep them, existing threads reference them.
- The homes live in T3's own per-instance namespace,
  `providers/<driver>/<instanceId>/<role>` — where managed Codex keeps its
  shadow homes. Nothing in T3 deletes, scans or migrates that subtree, and
  `t3 uninstall` keeps `userdata`.
- T3 sets `CLAUDE_CONFIG_DIR=<homePath>` and leaves `HOME` alone. Claude Code
  names its Keychain item after the config dir, so each instance has its own
  login, independent of `~/.claude` and of clauth. Log in once per home:
  `CLAUDE_CONFIG_DIR=~/.t3/userdata/providers/claudeAgent/<id>/home claude auth login`.
- **Deleting a home does not delete its login.** The Keychain item stays
  behind; log out first (`… claude auth logout`) when retiring a home.
  Likewise `rm -rf ~/.t3/userdata` loses both homes but not the Keychain items.
- MCP OAuth tokens live in that same per-home Keychain item. Servers that need
  OAuth must be authenticated once per instance (`/mcp` in a T3 thread).
- Codex `existing` mode uses `~/.codex` as is. Avoid `shadowHomePath`: shadow
  homes lose bundled plugins (#23652). T3's `managed` mode runs its own
  ChatGPT runtime without subagents.
- The account is picked per thread (model picker, `Cmd+Shift+M`). There is no
  automatic failover between instances, on purpose — see `clauth/AGENTS.md`.
  `autoResumeLimitedThreads` only resumes the *same* instance after its reset.

## What the homes share

`_install/t3.sh` links only configuration from `~/.claude` into each home:
`CLAUDE.md agents commands hooks keybindings.json output-styles plugins
settings.json settings.local.json skills` (whichever exist). Everything else —
transcripts (`projects/`), history, caches, policy and billing state — is
per account and owned by Claude Code. A shared `projects/` would make T3
import one session under both instances, and the policy/billing caches belong
to whichever account wrote them. To resume a T3 thread in the terminal, use
the same home: `CLAUDE_CONFIG_DIR=<home> claude --resume`.

- `.claude.json` is seeded once from an allowlist of `~/.claude.json` keys
  (MCP servers and UI preferences — never `oauthAccount`, `primaryApiKey` or
  the model/billing caches); afterwards only `mcpServers` is synced.
- If Claude Code replaces the `settings.json` link with a regular file, the
  next run keeps it as `settings.json.t3-<timestamp>` and relinks.
- A shared entry that exists in the home as a real directory is left alone
  with a warning — the script never deletes directories.
- New entries only appear after a re-run, which `update skills` does. In T3,
  "Restart agent session" picks up changes for running threads (#19025).

## Worktrees together with Worktrunk

T3 cannot delegate worktree creation to `wt` (it runs `git worktree add`
itself), but both tools use the same path layout. The overlay therefore sets:

- `worktreesDirectory: ~/Projects/_worktrees` — T3 worktrees land in wt's tree
  and show up in `wt list`.
- `worktreeCleanup: off` — only `wt` removes worktrees.
- A global project script `wt-hooks` (`runOnWorktreeCreate`, `async: false`)
  running `wt hook pre-start && wt hook post-start --foreground`, so wt's hooks
  (e.g. `wt step copy-ignored`) also run for T3-created worktrees. They also
  re-run when a thread is attached to an existing worktree, so hooks must stay
  idempotent (`copy-ignored` skips existing files). Unapproved project hooks
  are skipped silently — approve them with `wt config approvals add`, never
  `--yes`. Project-level script overrides replace this global entry.

Daily flow:
- Quick task: new T3 thread with "New worktree".
- GitLab ticket or `~/.dotfiles`: `wt issue <N> --no-agent` / `wt switch
  --create`, then attach the T3 thread via the branch picker (badge
  "worktree"). `~/.dotfiles` must go this way: wt names its dir `dotfiles`, T3
  would use `.dotfiles`.
- Removal: delete the T3 thread first and **decline "Delete the worktree
  too?"** (accepting force-removes it), then `wt remove` / `wt merge`.
- Auto-named T3 branches are renamed later but keep the `t3-<hex>` dir, so
  `wt list` flags them with ⚑. Harmless. `branchNamingMode: semantic` ignores
  the `t3/` prefix.

## Behaviour differences to the CLI

- **Permission default:** T3's built-in default is `full-access`
  (`bypassPermissions` / Codex `dangerFullAccess`). The overlay sets
  `defaultRuntimeMode: "auto"` = Claude auto mode (the `autoMode` rules in
  `settings.json` apply) and Codex `on-request` + auto review +
  `workspaceWrite`. T3 sends the Codex approval/sandbox policy on every turn, so
  those keys in `~/.codex/config.toml` do not apply in T3.
  Open bugs: #22483 (Claude may start in `default` mode on recent nightlies —
  check the provider log for `permissionMode=auto`), #15353 (Auto skips
  `permissions.ask` rules).
- **Codex effort:** `defaultModelSelection` carries no options. Whether threads
  then inherit `model_reasoning_effort` / `service_tier` from `config.toml` is
  unverified — check a thread's effort picker.
- **Attribution:** `removeAgentCreditsOnMerge` only edits GitHub merge/squash
  messages. Ordinary commits rely on `includeCoAuthoredBy: false` (Claude) and
  the instruction files.
- **Environment:** launched from the Dock, T3 runs `$SHELL -ilc` (5 s timeout)
  and imports PATH, SSH_AUTH_SOCK, locale, HOMEBREW_*, XDG_* and CA variables —
  not JAVA_HOME. Anything else must come from `settings.json` `env`, Codex
  `shell_environment_policy`, or a per-instance `environment` entry.
- **herdr/clauth context:** hooks that key on `HERDR_ENV` no-op, so T3's own
  notifications are on in the client overlay. The clauth MCP server still
  loads, but its "active profile" is the global CLI account, not the T3
  instance's account.
- `followUpBehavior: steer` sends a message typed during a running turn into
  that turn (like the CLI); `Cmd+Shift+Enter` steers with a queued message.
- Slash commands only work at the start of a message; there is no status line
  (the context-window meter is on instead).

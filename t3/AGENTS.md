# t3 — Agent Instructions

Config for [T3 Code](https://github.com/pingdotgg/t3code), a GUI that drives
Claude Code and Codex. Research and decisions:
`_planning/t3code-integration.md`.

## This is not a stow package

`~/.t3/userdata/` mixes settings with runtime state: `statev2.sqlite`,
`secrets/`, `clerk-tokens.json`, `logs/`, `attachments/`. Stowing it would
put that state one write away from this public repo. So nothing is linked:

- `t3/settings.json` is an **overlay**. `_install/t3.sh` (`just t3`)
  deep-merges it into `~/.t3/userdata/settings.json` — overlay keys win,
  everything else T3 stored is kept. T3 watches the file and reloads live.
- `.stow-local-ignore` only exists so an accidental `stow t3` cannot link it.

Only put keys in the overlay that should be enforced on every run. Arrays
replace rather than merge (so `customModels` is left out — models added in
the UI would be wiped). Never add project-scoped keys
(`projectSettingsOverrides`, `projectScriptOverrides`): they are keyed by
machine-local project IDs.

`keybindings.json` is not tracked either: it currently holds only T3's
defaults. Track it once a binding is actually customized.

## Accounts = provider instances

| Instance id | Driver | Account | Config |
|---|---|---|---|
| `claudeAgent` | claudeAgent | private Claude subscription | `homePath: ~/.claude-t3/private` |
| `claudeWork` | claudeAgent | work Claude subscription | `homePath: ~/.claude-t3/work` |
| `codex` | codex | ChatGPT subscription | `setupMode: existing` → `~/.codex` |

- `claudeAgent` and `codex` are T3's default instance ids (= driver name);
  keep them, existing threads reference them.
- T3 sets `CLAUDE_CONFIG_DIR=<homePath>` and leaves `HOME` alone. Claude Code
  names its Keychain item per config dir, so each instance has its own login,
  independent of `~/.claude` and of clauth. Log in once per dir:
  `CLAUDE_CONFIG_DIR=~/.claude-t3/<profile> claude auth login`.
- Codex `setupMode: existing` uses the CLI login in `~/.codex`. T3's
  `managed` mode runs its own ChatGPT runtime, which disables subagents and
  ignores `~/.codex/config.toml`.
- The account is picked per thread (model picker). There is no automatic
  failover between instances, on purpose — see `clauth/AGENTS.md` on why
  auto-hopping accounts at their limits is off the table.

## The config dirs are symlink forests

`_install/t3.sh` links every top-level entry of `~/.claude` into
`~/.claude-t3/<profile>/` — the layout `clauth start` uses. Skills, plugins,
hooks, agents, `CLAUDE.md`, `settings.json` and transcripts (`projects/`) are
therefore identical to the CLI, and threads stay resumable from `claude
--resume`.

Never linked (per account): `.credentials.json`, `.claude.json`,
`policy-limits.json`, `remote-settings.json`, `mcp-needs-auth-cache.json`.
`.claude.json` is seeded once from `~/.claude.json` without `oauthAccount`;
afterwards only its `mcpServers` block is synced. Never symlink it — it holds
the signed-in account's identity.

New top-level entries in `~/.claude` only appear after a re-run, which
`update skills` does. If Claude Code replaces the `settings.json` link with a
regular file, the next run keeps it as `settings.json.t3-<timestamp>` and
relinks.

## Behaviour differences to the CLI

- **Permission default:** T3's built-in default is `full-access`
  (`bypassPermissions` / Codex `dangerFullAccess`). The overlay sets
  `defaultRuntimeMode: "auto"`, matching `permissions.defaultMode` in
  `claude/.claude/settings.json`.
- **Environment:** launched from the Dock, T3 only imports `PATH` and
  `JAVA_HOME` from the login shell. Anything else must come from
  `settings.json` `env`, Codex `shell_environment_policy`, or a per-instance
  `environment` entry in the overlay.
- **herdr/clauth context:** hooks that key on `HERDR_ENV` no-op. The clauth
  MCP server still loads, but its "active profile" is the global CLI account,
  not the T3 instance's account.
- Slash commands only work at the start of a message; there is no status line.

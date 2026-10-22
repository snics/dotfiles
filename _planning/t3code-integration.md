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

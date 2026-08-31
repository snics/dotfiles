# claude — Agent Instructions

Stow package for Claude Code user config (`~/.claude/`) plus MCP server setup.

## Package contents

| File | Target | Mechanism |
|------|--------|-----------|
| `.claude/settings.json` | `~/.claude/settings.json` | **Copied, not symlinked** (see below) |
| `mcp-servers.json` | `~/.claude.json` (`mcpServers`) | Merged via `jq` in `_install/claude.sh` |
| `README.md` | — | Docs only, stow-ignored |

## settings.json is NOT symlinked — copy/sync instead

Claude Code rewrites `~/.claude/settings.json` **in place** (atomic
write + rename) whenever a setting changes — model, theme, plugins, permission
mode, etc. That replaces any stow symlink with a fresh regular file, so:

- A stowed symlink silently breaks on the first GUI/config change.
- The repo copy goes stale (the live file diverges and `stow` would later
  re-link the old state, or abort with a conflict).

Therefore `settings.json` is listed in `.stow-local-ignore` and handled like
`mcp-servers.json` — outside the symlink mechanism:

- **Bootstrap** (fresh machine): `_install/claude.sh` copies the repo template
  to `~/.claude/settings.json` only if none exists.
- **Sync back** (after changing settings live): run `just claude-sync`
  (or `make claude-sync`) to copy `~/.claude/settings.json` into the repo,
  then review the diff and commit.

Do **not** re-add `settings.json` to the stow symlink set, and do not
`stow --adopt` it — the symlink will just break again on the next write.

## Notable settings (current defaults)

- `model: "opus[1m]"` — the `opus` alias auto-tracks the latest Opus; `[1m]`
  enables the 1M-token context. No manual bump needed for new Opus releases.
- `permissions.defaultMode: "auto"` — every session starts in Auto mode
  (auto-approves except dangerous ops, classifier-guarded). Toggle live with
  Shift+Tab.
- `includeCoAuthoredBy: false` — enforces the "no Co-Authored-By trailers" rule
  from the global CLAUDE.md at the harness level.

## `autoMode.environment` is stripped on sync — do not re-add it

Claude Code auto-generates `autoMode.environment` from whatever repository it
was last run in. In this case it captured an employer's infrastructure: the
self-hosted GitLab host and project paths, where secrets live in that repo,
internal services, branch-protection rules, and an absolute worktree path. No
credentials, but a map to them — and this repository is public.

It reached GitHub on 2026-08-29 via `bc9d20b6`, an ordinary `claude-sync`, and
was removed again on 2026-09-01. Removing it does not un-publish it; the git
history on the remote still carries it. What the removal stops is further
exposure, and the `jq 'del(.autoMode.environment)'` filter in `claude-sync` is
what stops it coming straight back on the next sync.

The block stays in the LIVE `~/.claude/settings.json` — Claude Code needs it,
and it is fine there. It is only kept out of the repository.

`autoMode.allow` and `soft_deny` are deliberately left in: generic CLI patterns
(`glab issue view`, `npm run doctor`) with no hostnames or paths.

## Sync obligation

When you change Claude Code settings and want them tracked, run `just claude-sync`
before committing. The `claude-sync` target exists in **both** `justfile` and
`Makefile` — keep them in sync per the repo-wide Justfile/Makefile rule.

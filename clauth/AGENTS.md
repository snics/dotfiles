# clauth — Agent Instructions

Tracked config for [clauth](https://github.com/uwuclxdy/clauth), a multi-account
manager for Claude Code. Design and rationale:
`docs/superpowers/specs/2026-08-30-clauth-integration-design.md`.

## This is not a stow package

`clauth/.clauth/profiles.toml` mirrors the path it targets, but nothing here is
symlinked. clauth rewrites `profiles.toml` in place, which would destroy a stow
symlink on first write — the same reason `claude/.claude/settings.json` is
copied. `.stow-local-ignore` exists purely so an accidental `stow clauth`
cannot cause that breakage.

- **Bootstrap:** `_install/clauth.sh` (`just clauth`) copies the template only
  when `~/.clauth/profiles.toml` does not exist.
- **Sync back:** `just clauth-sync` after clauth has changed the live file
  (profile ordering, the active marker), then review the diff and commit.

## Scope: profiles.toml only

Never track, copy, or link anything else under `~/.clauth/`. OAuth tokens live
in `~/.clauth/profiles/<name>/credentials.json`, and per-profile `config.toml`
may hold API keys. `profiles.toml` itself is secret-free.

### Profile names become public

This repository is public, and `just clauth-sync` copies `profiles.toml` into
it. Everything else in that file is a boolean, a number or an enum — the only
free-form values are the profile names, which appear in `profiles`,
`active_profile`, `fallback_chain` and `auth_broken` (`ProfileName` is a plain
`String`).

So name profiles neutrally — `personal`, `work`, `alt`. Never an email address,
a client name, or an employer's name: `clauth login <name>` is the one moment
where a careless choice ends up on GitHub.

## Guardrails

These are not style preferences — each one prevents a specific, verified
failure:

- **Never run `clauth herdr install` without `--no-config`.** It appends its
  keybinding and sidebar row to herdr's `config.toml`, which is a stow symlink,
  so the write lands in this repository unreviewed. `_install/clauth.sh` always
  passes the flag.
- **Keep `uwuclxdy/clauth/herdr-plugin` in Herdr Lazy's `plugins.list`.** The
  installer still registers the plugin with `--no-config`, while the
  declarative entry prevents `herdr-lazy sync --prune` from removing it again.
- **Keep `fallback_chain` empty.** It was tried with `private` in it on
  2026-09-01 and deliberately removed again, because the trade turned out to be
  bad on this platform:

  - It does **not** rescue a running session. `clauth start --with-fallback` is
    refused on macOS (`swap_support()` → `KeychainFirst`, because Claude Code
    resolves credentials keychain-first). All a switch achieves is that the
    *next* session starts on an account with headroom — a manual
    `clauth start <other>` does the same thing, when you want it.
  - Every switch does a read-modify-write on the login Keychain item, which
    also holds every MCP server's OAuth login (`src/keychain.rs`). That is a
    standing risk in exchange for saving one command.
  - Every switch also rewrites `~/.claude/settings.json`. The early-exit in
    `apply_profile_to_claude_settings` only fires when the file does not exist,
    so it rewrites unconditionally. Harmless while no profile sets `model`,
    `env` or `apiKeyHelper` — set any of them and a switch starts moving them.
  - Auto-hopping accounts at their limits is also the only part of this tool
    that sits near Anthropic's usage policy. Holding two accounts is fine;
    switching to evade a limit is the part that is not clearly fine.

  The empty chain is what keeps the daemon inert: `next_auto_switch_target`
  returns `None` when the active profile is not a chain member.

  Two operational notes if this is ever revisited: `fallback_chain.push` has
  exactly one call site (`add_chain_candidate`, one TUI action), so it never
  fills itself — but it is one keystroke away, and it filled twice during
  setup. And stop the daemon before editing the chain by hand, or a running one
  can write its own state back over the edit.
- **Never run a global switch** — `clauth <profile>`, or the MCP
  `switch_profile` tool. It rewrites `model`, `env` and `apiKeyHelper` into
  `~/.claude/settings.json` and does a read-modify-write on the login Keychain
  item, which also holds every MCP server's OAuth login.
- **The keybinding is `prefix+d`, not clauth's default `prefix+a`.** That key
  is bound to `next_agent` in `herdr/.config/herdr/config.toml`. When checking
  a herdr key for conflicts, grep the bare key string: built-in actions bind as
  `<action> = "prefix+…"` while plugin actions use `key = "prefix+…"`, and
  checking only the latter is how `prefix+a` was once wrongly believed free.

## Two things clauth did on its own during setup

Both were caught after the fact and are worth knowing before the next install:

- **`clauth completions --install` writes into `~/.zshrc`** with an absolute
  path. That file is a stow symlink, so the write lands in this repository and
  hardcodes one machine's home directory. Decline that offer; the completions
  are sourced from `zsh/conf.d/66-clauth.zsh` with `$HOME` instead.
- **`fallback_chain` came back populated during setup.** That single line is
  what arms the daemon's auto-switch, so it had to be emptied again.

  It does NOT repopulate on its own: `fallback_chain.push` has exactly one call
  site in the whole codebase (`add_chain_candidate`, reached from one TUI
  action), and neither `clauth login` nor the daemon nor any CLI path touches
  it. So the empty chain is a real defense rather than a snapshot — but it is
  one TUI keystroke from being undone, and nothing enforces it. Check it after
  spending time in the TUI, not after every login.

Note also that comments do **not** survive: clauth rewrites `profiles.toml`
without them, so every `just clauth-sync` strips whatever was written there.
That is why these rules live in this file and not in the config.

## Editing profiles.toml by hand

Two traps, both hit during the initial setup:

- `pane_tag` and `border_label` are **booleans** (`true`/`false`). The CLI
  prints them as `on`/`off` via `clauth herdr config get`, but a string value
  fails to parse.
- Top-level keys (`profiles`, `fallback_chain`) must stay **above** the
  `[herdr]` table. TOML assigns every key after a table header to that table,
  so moving them down silently turns them into herdr knobs.

There is no CLI setter for the `[herdr]` knobs — only `clauth herdr config get`.
Edit the file, or use the TUI's Setup tab.

## Version pinning

clauth is installed from a **git commit**, not crates.io: the published 0.14.1
does not contain the herdr subcommand at all. See the entry and its reasoning
in `_install/cargo-tools.list`. To move the pin, review the new commit and edit
that file — `just cargo-tools-update` deliberately skips pinned git entries.

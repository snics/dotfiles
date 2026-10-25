# clauth pin review: 85d28a1 (v0.15.1) → mommy

Date: 2026-10-23. Read-only review of a clone of `uwuclxdy/clauth` (no build, no install, no
state-changing clauth commands, no credential files read). Background:
`_planning/clauth-relogin-diagnosis.md`, `clauth/AGENTS.md`.

## Recommendation

**Pin `df5410c6c51f878cef8a65e63936c79e5ad4740f`** (`mommy`, 2026-10-23, "docs: describe the
self-update bounds…", Cargo version `0.17.0`, CI green). That is 707 commits past the pin. It
contains every fix we need:

| fix | commit | first tag |
|---|---|---|
| #81 census deletes only items in its ownership ledger | `858a9c95` | v0.16.0 |
| suspend/wake no longer trips the watchdog | `72f32606` | v0.16.0 |
| `security -i` 4096 B truncation (supersedes PR #66) | `be5c39e2` | v0.15.2 |
| pre-arming sessions converge onto the rolling token | `eaf6dac8` | v0.16.0 |
| #104 live `.credentials.json` follows re-stamps/rotations; no divergence prompt for current refreshless logins | `fe511591`, `885474ef`, `f7cf1011` | mommy only |
| #105 `clauth which` resolves a Keychain-only login | `da771e3e` | mommy only |
| tokio AsyncFd advisory | `646662fa` | mommy only |

The latest mommy commit at review time, `c1c4a31e`, was still in CI and only changes the TUI.
Use it only if it turns green, and nothing is gained by it.

**Fallback if a tag is preferred:** `v0.17.0` (`80020277`). It carries #81, the watchdog and the
`security -i` fixes, but not #104/#105, so the "live login no longer matches" banner and
`clauth which` → `unknown` remain. **Never `v0.15.2`** (`46f04adc`): its census predates the
ledger (#81).

## Checklist

1. **Foreign Keychain deletion (#81): fixed.** `census_orphan_keychain_services` (`src/claude.rs`)
   deletes a service only when it is namespaced, **listed in
   `~/.clauth/keychain-item-owners.json`**, and not live. An unreadable ledger deletes nothing
   (fail-closed). The stale-runtime GC goes through the same ledger gate. T3 Code's
   `Claude Code-credentials-<sha8>` items are never written by clauth, so they never enter the
   ledger. After the upgrade the ledger starts empty and the first census deletes nothing.
   Deletions now salvage the raw item into `~/.clauth/keychain-quarantine/` first and are logged
   to `clauth.log`. The GitHub issue is still *open*, but the owner has confirmed the fix, which
   shipped in v0.16.0.
2. **Divergence banner / frozen `.credentials.json`: fixed on mommy only.** TUI quit still detaches
   the symlink into a regular file (`shutdown` → `detach_credentials_link`, unchanged). The new
   file-layer follower (`follow_live_file_login`) rewrites that regular file on every re-stamp
   or rotation, replacing only the `claudeAiOauth` block. **Caveat:** it only follows a file
   holding a bearer clauth recognizes (the previous or the new one) or a logged-out shell. Our
   current live file holds a bearer that was rotated away weeks ago, so it stays `NotOurs` and
   gets a `clauth.log` line, and the banner remains until it is resolved once with
   `d` → **discard / restore** (never overwrite). After that it should not recur.
3. **Daemon: compatible.** `daemon --standby` / `--no-standby` / `--replace` / `--status` keep the
   same flags and help text. New flags (`--listen`, `--cert`, `--key`, `--openapi`) are opt-in.
   Nothing listens and `~/.clauth/bridge.sock` is not bound unless `--listen` is passed. The suspend
   fix treats a frozen-clock gap as a suspend rather than a wedge. A real wedge still
   `abort()`s "for launchd", and our `KeepAlive=true` restarts it. The new `daemon.log` size cap
   truncates in place (`set_len`) and is designed for launchd's `O_APPEND` fd, so our
   `StandardOutPath`/`StandardErrorPath` keep working. Upstream still ships no `daemon install`,
   so keep `_install/clauth-daemon.sh`.
4. **herdr: present.** `clauth herdr {install,uninstall,config get}` still exist, and
   `install --no-config` still exists. `herdr-plugin/` at the target is **byte-identical** to the
   commit Herdr Lazy already locks (`0b8dae42`, `herdr/.config/herdr/plugins.lock`), so the bump
   brings the binary back in line with the plugin scripts. **New risk, see R1.**
5. **Config: no breaking migration.**
   - `rolling_token` in the per-profile `config.toml` is unchanged (`clauth rolling-token` and
     `clauth static-token` still exist).
   - New `profiles.toml` keys are all omitted at their defaults: `[update] auto_update` (default
     **true**), `[serve]`, `home_tab`, `walk_order`, `bell_command`, `preset_binds_offered`,
     `preserve_non_login_keys` (default **true**), and others. Unknown nested keys now survive
     rewrites.
   - Rotation staging moved from `credentials.json.pending` to `.staged`. A legacy `.pending` is
     still adopted.
   - The v0.17.0 notes require stopping clauth processes older than 0.14.0. We are on 0.15.1, but
     stop everything anyway.
   - Rollback caveat: the 0.15.1 binary does not know `[update]` and drops it on its next save.
6. **Writes to stowed files, `~/.zshrc` and `fallback_chain`: unchanged surface.**
   - Completions still offer to append to `~/.zshrc`, but only once, behind the
     `~/.clauth/.completions_installed` sentinel, which already exists here (2026-08-31).
   - `herdr install` without `--no-config` and the TUI Services-tab herdr "fix" / `delegate row
     text` toggle (`herdr::heal`) still write herdr's stowed `config.toml`. Same as at the pin.
   - `fallback_chain.push` still has exactly one call site (TUI, `src/tui/app.rs:19044`). The new
     `set_chain_order` (TUI move rows and REST `POST /api/v1/chain/order`) only accepts a
     permutation of the current chain, so it cannot add members.
   - New auto-switch guards: it skips accounts with no login and has a credit-cap gate.
7. **Claude Code plugin: grows a code module.**
   - `hooks.json` keeps the same three hooks (`hook-profile-changed-note` on
     UserPromptSubmit/PostToolUse/SessionStart, `self-heal` on SessionStart, `mcp-await-job`).
     The delegate matcher was broadened.
   - It adds `"modules": ["./register.ts"]`, an in-process mod that bridges every session to
     `~/.clauth/bridge.sock`. It posts transcript row ids, tool-permission asks (tool and
     input), and turn start/end. It holds an ask for a paired phone **only when the daemon
     answers `hold: true`**, which requires `--listen` plus a paired control-tier device. With
     no socket every fetch fails and it backs off 5 s, so the module is inert. It still runs in
     every session, including T3 sessions, because those homes symlink `~/.claude/plugins`.
   - The plugin is re-materialized from the binary by the daemon tick and `clauth mcp`
     (`plugin_host::heal_detached`, not gated by `auto_update`), so it moves to 0.17.0 by itself
     after the bump.
   - #134 (self-heal starts `claude` twice per session event) is still open.
8. **Keychain security**
   - `be5c39e2`: a write whose `security -i` line exceeds 4096 B now goes through **argv** (up to
     512 KiB; larger writes are refused) instead of silently truncating. That trades away the
     "secret never in argv / EDR exec log" property for those large items only, and the secret
     is briefly visible to same-user `ps`. Small items still use stdin.
   - `d787c3ed`: writes are verified, and corrupt reads are quarantined.
   - `acdb16cf`: a locked keychain (exit 36) is classified (#85 partly addressed; issue still
     open).
   - `0ce58ba3`: no Keychain writes while a guarded delete is in flight.
   - **New disk copies of Keychain content**, see R2.

## Risks

- **R1: daemon reinstalls the herdr plugin against Herdr Lazy (high, introduced after the pin).**
  `17660d32` changed `herdr::heal_detached`. It now reinstalls `uwuclxdy/clauth/herdr-plugin` at
  the **latest release tag** whenever the installed `resolved_commit` differs from that tag's
  commit. It runs `herdr plugin install … --ref v0.17.0 --yes` from every daemon tick (throttled
  to 30 min) and from `clauth mcp` startup. Herdr Lazy pins `0b8dae42`, so this would downgrade
  the plugin to `v0.17.0` and fight `herdr-lazy sync` indefinitely. (At the pin the heal only
  fired when the manifest version was older than the binary, so it stayed a no-op.) The gate is
  `[update] auto_update` **and** `CLAUTH_NO_UPDATE`. **Mitigation: set both** (steps below). The
  same gate also stops the TUI's binary update check. That check is notify-only for us anyway,
  because `/Users/nico/.cargo/bin/clauth` counts as cargo-installed and is never self-replaced.
- **R2: plaintext copies of Keychain items (medium, mommy only, from `da771e3e` and
  `dab547fe`/`5a967a22`).**
  - `clauth which` and the plugin's `hook-profile-changed-note` now fall back to reading the
    Keychain item for the session's config dir. They cache the **whole item blob** for 30 s as
    `~/.clauth/keychain-which-cache/<service>` (0600, swept after a day). In a T3 session
    (`CLAUDE_CONFIG_DIR` = T3 home, file tiers miss) that is T3's own per-instance item, refresh
    token included. Inferred from code; not observed at runtime.
  - `preserve_non_login_keys` (default on) copies `mcpOAuth` / `designOauth` from the live store
    into `~/.clauth/profiles/<name>/` on relinks and switch-away.

  Both stay inside `~/.clauth`, which already holds plaintext refresh chains at 0600, so this
  adds no new trust boundary. It does widen what a `~/.clauth` leak exposes, notably T3's logins.
  Options: accept it, or keep the clauth plugin out of T3 homes (`t3/AGENTS.md` /
  `_install/t3.sh` currently symlink `plugins`).
- **R3: churn.** 707 commits; upstream lands roughly 20 commits a day with frequent fixes. New
  surfaces stay off unless configured: codex switching, shunt gateway/proxies, REST API, push,
  phone bridge, bell command, credit-cap gates. Open issues worth watching: #106 (bare `claude`
  overwrites the mirrored item after a switch; irrelevant while we never switch globally), #134,
  #85, #137/#136/#138 (all `clauth start`-only).
- **R4: one-time banner.** See item 2. The resolution is the same "discard" rule as today.
- **R5: rollback.** Going back to 85d28a1 is safe, but it drops `[update]`, so R1's env var must
  then carry the gate. The ledger and quarantine files are simply ignored by the old binary.

## Migration steps (do not run unattended)

1. Edit `_install/cargo-tools.list`: change `rev=` to
   `df5410c6c51f878cef8a65e63936c79e5ad4740f`, and add a comment block like the previous bump's
   (fixes #81/#104/#105 plus watchdog; skips v0.15.2; herdr subcommand and `herdr-plugin/`
   verified present; plugin identical to the Herdr Lazy lock).
2. Gate the auto-updater (R1) before any new-binary process starts:
   - Add `CLAUTH_NO_UPDATE=1` to the plist's `EnvironmentVariables` in `_install/clauth-daemon.sh`.
   - `export CLAUTH_NO_UPDATE=1` in `zsh/conf.d/66-clauth.zsh`. That covers the pane-spawned
     daemon, the TUI and `clauth mcp` under herdr; T3 launched from the Dock does not inherit
     it, hence the next step.
3. Stop every clauth process: quit the TUI, `pkill -f '(^|/)clauth daemon'` (or
   `launchctl bootout gui/$(id -u)/com.dotfiles.clauth-daemon` if loaded), and end Claude Code /
   T3 sessions, because each one runs a `clauth mcp` child.
4. `just cargo-tools`. This does `cargo install --locked --git … --rev …`; it needs rustc with
   edition 2024, and 1.99.1 is installed.
5. With the new binary, before starting a daemon: add to `~/.clauth/profiles.toml` and to the
   tracked template `clauth/.clauth/profiles.toml`, keeping it **below** the top-level keys:
   ```toml
   [update]
   auto_update = false
   ```
   It serializes explicitly when false, so it survives clauth's rewrites and `just clauth-sync`.
6. Start the daemon (`just clauth-daemon`, or open a herdr pane). Check `clauth daemon --status`,
   `tail ~/.clauth/daemon.log`, and confirm there is no `herdr plugin heal` / `installing … at
   v0.17.0` line in `clauth.log` or `daemon.log`.
7. Open the TUI once. If the banner shows, press `d` → **discard this login and restore
   '<active>'**. Then `clauth which` should print the active profile. Quit the TUI, wait for
   the next re-stamp (≤ 6 h), and confirm that the banner stays gone on the next launch and
   that `.credentials.json` mtime moves with the re-stamp.
8. Verify the invariants: `fallback_chain = []`; the herdr plugin registration still at `0b8dae42` (Herdr Lazy's lock);
   `git status` shows no unexpected change under `herdr/` or `zsh/`; T3 instances stay signed in
   after a `clauth mcp` start (census) and over a day.
9. Docs: in `clauth/AGENTS.md`:
   - the "Plugin tab" is now the **Services tab**;
   - the banner note becomes "fixed at the pin, resolve once";
   - the `[update] auto_update = false` / `CLAUTH_NO_UPDATE` guardrail with R1's reason;
   - the plugin's `register.ts` module and the R2 cache;
   - "no global OAuth MCP servers" can be relaxed. The truncation is fixed and
     `preserve_non_login_keys` keeps MCP logins with their account, but that is a separate
     decision.

   Also update the memory notes (`clauth setup`).

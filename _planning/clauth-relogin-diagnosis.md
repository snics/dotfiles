# clauth re-login and "live login no longer matches" diagnosis

Date: 2026-10-23 (read-only investigation; nothing was switched, relinked, edited or restarted).
Installed: clauth 0.15.1, pinned rev `85d28a1` (`_install/cargo-tools.list:38`).
Times below are UTC unless marked "local" (CEST = UTC+2).

## TL;DR

There are two problems here, and they have different causes.

1. **The banner** (`! live login no longer matches 'private' · press d to resolve`) is
   expected behaviour at the pinned rev. It is mostly cosmetic, but pressing `d` and taking
   the default row can do real damage. The TUI judges divergence from the plaintext
   `~/.claude/.credentials.json`. On every quit the TUI turns that path into a frozen
   regular-file snapshot. On macOS the daemon's rolling-token re-stamp updates only the
   Keychain, never that file. So the file goes stale within about 6 h, and from then on every
   TUI launch flags it. Fixed upstream on `mommy` (unreleased, after v0.17.0) under issue #104.
2. **The real logouts** come from the rolling bearer (8 h lifetime) expiring while the
   daemon is not running. The daemon is the only re-stamper. At the pin, a sleep/wake trips
   its 30 s watchdog, which "aborts for a clean launchd restart". No LaunchAgent exists, so
   nothing restarts it until a new herdr pane opens. Two refresh-chain deaths (HTTP 400,
   `invalid_grant`) on 09-30 and 10-04 also forced `clauth login`. The watchdog was fixed
   upstream in v0.16.0.

There is also a side finding that needs attention now. `active_profile` flipped from `work`
to `private` at 21:55 UTC on 10-22 without any Keychain write. The Keychain item was last
written at 21:02:50, when `work` was active. So bare `claude` sessions most likely still run
on **work, which is at 99 % of its 7-day window**, until the next re-stamp mirrors `private`
in (about 03:02 UTC / 05:02 local).

T3 Code is not involved at the pin. It becomes a risk with v0.15.2 specifically (see below).

## Evidence

### Credential state (hashes and structural fields only)

| item | state |
|---|---|
| `~/.claude/.credentials.json` | Regular file (not a symlink), 376 B, mtime **2026-10-21 20:57:40**. Only `claudeAiOauth`, **no refreshToken**, `expiresAt` 2026-10-22 04:53:41 (**expired**). Its access token matches **neither** profile's `credentials.json` nor `session-token.json`. |
| `profiles/{work,private}/credentials.json` | Both rotated at 2026-10-22 21:02:50. They have refresh tokens and expire 2026-10-23 05:02:50. |
| `profiles/{work,private}/session-token.json` | Rolling bearer with no refresh token. Its access token **equals the chain's access token** for each profile, written at 21:02:50. |
| `config.toml` (both) | `rolling_token = true` |
| Keychain `Claude Code-credentials` | `mdat` **2026-10-22 21:02:50**. That is the same second as the daemon boot re-stamp. It is the only `Claude Code-credentials*` item. |
| `profiles.toml` | `active_profile = "private"`, mtime 21:55 (the repo copy still says `work`). `fallback_chain = []`. |
| `clauth which` / MCP `profiles scope:session` | `unknown`. At the pin, `which` reads only the file tiers, and the stale file matches no profile. Fixed upstream in `da771e3e` (#105). |

### Timeline

- **10-21 20:53:41**: daemon re-stamp (rolling bearers good until 04:53:41).
- **10-21 20:57:34**: TUI launched (`clauth.log`: lease stand-down line). **20:57:40**: the live
  file is written as a regular file holding that bearer. This matches the TUI's
  quit path (`shutdown` → `detach_credentials_link`, `src/tui/app.rs:9786`), which converts the
  symlink into a same-bytes regular file.
- **10-22 02:54, 08:55, 14:55**: re-stamps roughly every 6 h (`ROLLING_RESTAMP_HORIZON_MS` = 2 h on an
  8 h bearer, `src/oauth.rs:2327`). Each one writes `session-token.json` and the Keychain, never
  the stale regular file.
- **10-22 ~20:17 → 21:02**: the old daemon (running since 10-15) died **without any log line**.
  A new herdr pane started a new one at **21:02:48**, which re-stamped both profiles and mirrored
  the then-active `work` into the Keychain at **21:02:50**.
- **10-22 21:55:29**: TUI launched. **21:55:48**: `profiles.toml` changed to `active_profile = "private"`
  (daemon: "reloaded config"). The live file was **not** relinked (still the 10-21 regular file)
  and the Keychain was **not** written (mdat still 21:02:50). Every switch path in clauth
  (`switch_profile*`, `src/actions.rs:100-160`) relinks the file and writes the Keychain before
  `finish_switch`, so this flip did not come from a clauth switch. **The cause is still open.**
  Ask the user what they did at about 23:55 local (TUI action, manual edit, something else).

### Daemon outages (from `daemon.log`)

| outage | last re-stamp before it | bearer dead |
|---|---|---|
| 10-13 10:16 watchdog abort → restart 15:22 | 05:08 → expires 11:08 | about 4 h |
| 10-14 14:54 watchdog abort → restart 10-15 08:33 | 09:22 → expires 17:22 | about 15 h |
| 10-12 several silent deaths (only new `running` lines at 07:06, 15:01, 17:07) | — | gaps up to about 5 h |
| 10-22 silent death about 20:17–21:02 | 14:55 → expires 22:55 | none (restarted in time) |

Both watchdog lines say `aborting for a clean launchd restart`. `~/Library/LaunchAgents` has no
clauth agent, and `zsh/conf.d/66-clauth.zsh` only starts the daemon when a herdr pane opens.
Upstream `72f32606` ("survive a suspend without a watchdog abort", v0.16.0) confirms that
suspend is the trigger.

### Chain deaths (need `clauth login`)

- `clauth.log` 2026-09-30 15:23–15:26: `refresh for 'private' failed: HTTP 400` (x5). `private/account_id.json`
  is dated 09-30 17:27 local, which is the re-login.
- `daemon.log` 2026-10-04 19:16:59: `refresh for 'work' failed: HTTP 400` → `flagged auth_broken` → "usage chain
  is dead". The only transcript-recorded API auth error in the last 20 days follows at
  **10-04 21:20:44**: `Please run /login · API Error: 401 OAuth access token has expired`. `work` was
  re-logged in at 10-04 23:26 local.
- No HTTP 400 since. On 10-12 17:04 there were two `no response` failures, which were transient and recovered.

The HTTP 400s mean another party spent the single-use refresh token. A likely culprit is a
Claude Code session started before the rolling token was armed, which still holds a refresh
token in memory. Upstream `eaf6dac8` ("converge pre-arming sessions onto the rolling token",
v0.16.0) and open issue #106 cover that pattern.

## Mechanism of the banner (code at `85d28a1`)

- The banner text comes from `src/tui/app.rs:657` (`DivergenceNotice::banner_message`). The `sibling: None`
  variant means the live token matches no stored profile.
- It is raised by `poll_credentials_divergence` (`src/tui/app.rs:9578`) →
  `classify_credentials_link` (`src/claude.rs:917`) → `classify_link_at`. A regular file whose access
  token differs from the active profile's install source counts as `Diverged`.
  `live_login_is_stored` (`src/claude.rs:1034`) only exempts a token equal to a stored one, and
  the stale bearer has been rotated away.
- The file goes stale because of two things:
  - **TUI quit** detaches the symlink into a regular file (`src/tui/app.rs:9786`, `detach_credentials_link`
    `src/claude.rs:2126`).
  - **Re-stamp** (`restamp_rolling_token`, `src/oauth.rs:2359`) mirrors only into the Keychain
    (`keychain_mirror_rotation`) and does so only for the *active* profile. It never touches a
    regular live file.
- Self-reinforcing: `Daemon::boot` calls `let _ = link_profile_credentials(&active)`
  (`src/daemon/mod.rs:~450`). Its refuse-guard (`src/claude.rs:1504-1535`) bails *before* the Keychain
  mirror when the live regular file differs, and the error is silently discarded. Every boot
  relink and TUI reconcile therefore does nothing until the divergence is resolved by hand.

### What `d` does, and what to choose

The resolver lists the following (`src/tui/app.rs:680`, `src/tui/render/modals.rs:365`):

1. **`overwrite 'private' with this login`** (first row) runs `force_snapshot_active_credentials` and then
   `force_link`. **Do not pick this.** It would store the *expired, refresh-less* bearer as
   private's `credentials.json`, which destroys private's refresh chain. The next re-stamp then
   fails and `clauth login private` becomes necessary. This choice is itself a re-login generator.
2. `save this login to another account…` is pointless here, because the login is dead.
3. **`discard this login and restore 'private'`** (`run_discard_divergence`, `src/tui/app.rs:8718`) runs
   `force_link_profile_credentials(private)`. It symlinks the live path to private's
   `session-token.json` and installs private's bearer into the Keychain, keeping MCP logins
   (`Keep::CarriedOnly`). This is the correct choice. It also fixes the work/private
   Keychain mismatch immediately.

At the pin, the banner **will come back** after the next TUI quit plus re-stamp. Treat it as
noise, and only ever choose "discard". Never set `default_divergence = Overwrite`.

### Does the stale file log anyone out?

Not directly. Claude Code on macOS reads the Keychain first. It does matter in three cases:
(a) through the `d` → overwrite footgun above, (b) because it blocks the daemon's boot relink
silently, and (c) if a Keychain read ever fails (locked keychain, `security` timeout), Claude
Code falls back to the expired file, gets a 401, and asks you to log in.

## T3 Code

- At the pin it is **unrelated**. The T3 homes (`~/.t3/userdata/providers/claudeAgent/<id>/home`,
  created 10-23 00:01 local) do not share `.credentials.json` (`SHARED` in `_install/t3.sh:45`).
  No `Claude Code-credentials-<hash>` items exist yet, and the stale file predates T3 (10-21).
  The pinned source has no Keychain census (`grep census src` is empty).
- **Risk on upgrade:** issue **#81**. In **v0.15.2** the `clauth mcp` boot census deletes every
  `Claude Code-credentials-<8hex>` item that clauth did not seed. That includes T3's per-instance
  logins, and it would show up as T3 instances landing on "Select login method" within minutes.
  It is fixed in v0.16.0 (`858a9c95`, ownership ledger). The issue is still open but the
  maintainer confirms the fix. **Never pin v0.15.2.** Pin at least v0.16.0, ideally a `mommy` rev.
- The T3 homes symlink `~/.claude/plugins` and `settings.json`, so T3 sessions also load the clauth
  plugin and its hooks. That is harmless at the pin.

## Other drift found

- **The clauth Claude Code plugin is installed and enabled** (`installed_plugins.json`: `clauth@clauth`
  0.15.1, installed 2026-10-07). The memory note says it was "deliberately NOT installed". Its hooks
  run `clauth hook-profile-changed-note` on every prompt and tool use, and `clauth self-heal` on
  SessionStart. That is the source of the "session switched to private" note. Open upstream
  issue #134 reports that self-heal starts `claude` twice per session event.
- PR **#66** is **closed unmerged**, superseded by `be5c39e2` ("stop an oversized item truncating
  through security -i", Fixes #66). That fix is in **v0.15.2**, so the pin is still exposed.
  Keep the "no global OAuth MCP servers" rule until the pin moves.
- Seven stale `.status.json.tmp.*` files in `~/.clauth` (cosmetic).

## Fixes, ranked by safety

### Manual (user)

1. **Now:** open the TUI, press `d`, choose **discard / restore 'private'**, and confirm. This repoints the
   Keychain to private. It costs one Keychain read-modify-write with MCP logins carried, the same
   as the daemon does on boot. Never choose the first "overwrite" row. Check that `clauth which`
   then prints `private`. *If you actually meant to stay on `work`, set it back the same way
   instead. Either way, find out what flipped `active_profile` at 23:55 local.*
2. **After any sleep, or if a session asks you to log in:** check `pgrep -fl '^clauth daemon'` and look for a
   `watchdog` line at the tail of `~/.clauth/daemon.log`. Opening a new herdr pane restarts the daemon.
   Once the bearer has expired, the daemon's first tick re-stamps it and running sessions
   recover on their next Keychain read. `clauth login` is only needed when the log says `auth_broken`
   or `HTTP 400`.
3. Restart long-lived bare `claude` sessions that started before the rolling token was armed
   (09-05). Any session that holds a refresh token can spend the chain (HTTP 400).

### Dotfiles

Status 2026-10-23: 4 is implemented as `_install/clauth-daemon.sh` (`just
clauth-daemon`), not loaded yet. 6 is done in `clauth/AGENTS.md`. 5 and 7 are open.

4. **Supervise the daemon with launchd.** Add a `~/Library/LaunchAgents/…clauth.daemon.plist` with
   `KeepAlive=true`, logging to `~/.clauth/daemon.log`, installed by `_install/clauth.sh`. Then drop or keep the
   herdr-pane spawn in `zsh/conf.d/66-clauth.zsh` as a fallback (clauth's singleton lock already
   handles duplicates). This addresses the dominant logout cause even at the current pin, and the
   watchdog message assumes launchd is there anyway. Check first whether a newer clauth ships its own
   `daemon install`. None was found at the pin.
5. **Bump the pin to a current `mommy` rev** (≥ `fe511591`/`885474ef`/`f7cf1011`/`da771e3e`, refs #104/#105), or at least
   **v0.16.0+** for the suspend watchdog (`72f32606`), the `security -i` truncation fix (`be5c39e2`), and the
   #81 census fix. **Skip v0.15.2.** Review the changes first: 687 commits since the pin, and later
   versions add a Keychain census, an ownership ledger and Codex switching. Re-check `fallback_chain`
   and the plugin hooks after upgrading.
6. Docs: update `clauth/AGENTS.md` and the memory note. Record that the TUI quit detaches the live link
   (so the banner recurs by design at the pin), the "d → discard, never overwrite" rule, that the
   plugin is in fact installed, that #66 is superseded by `be5c39e2` (v0.15.2), and the T3/#81
   upgrade caveat.
7. Optional: decide whether to keep the clauth Claude Code plugin. Uninstall it from the TUI's
   Plugin tab, because its marker gate keeps a deliberate uninstall removed. Weigh that against
   the per-prompt hook cost and #134.

### Upstream (file / watch)

8. **Watch** #104 (closed; fixes on `mommy` after v0.17.0), #106 (open: bare `claude` writes a stale
   account back into the shared Keychain item), #81 (open, fix landed), #134 (open), #85 (locked
   keychain).
9. **File:**
   - (a) `Daemon::boot` discards the `link_profile_credentials` error (`let _ =`), so a diverged
     live file silently disables the boot relink and Keychain mirror. It should at least log.
   - (b) The divergence resolver puts **Overwrite** first even when the live login is *expired and
     refresh-less*. Capturing it destroys the profile's chain. Suggest refusing or demoting
     Overwrite for a live login that is expired or refresh-less on a rolling-token profile.
   - (c) An `active_profile` change that bypasses the switch path leaves the Keychain on the old
     account until the next re-stamp. Only file this if (a) and the 21:55 flip can be reproduced.

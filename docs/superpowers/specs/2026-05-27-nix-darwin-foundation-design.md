# Nix-Darwin Foundation Design

Establish a maintainable nix-darwin + home-manager flake skeleton on macOS that future package- and config-migration specs can fill in incrementally. No tools migrate in this spec — the existing Stow + Brewfile + Homebrew setup remains fully active and **untouched**.

## Goal

Move from a Stow + Brewfile dotfiles setup to a declarative Nix-managed system in three discrete, session-bounded specs. This first spec establishes only the **architecture** — directory layout, module skeleton, helper functions, host/user parameterization, and Touch ID — so that subsequent specs (packages, then configs) can plug in without touching plumbing.

**Why now:** The user is new to Nix. Migrating both architecture and tools in one spec produces too many unknowns at once. Splitting "where things live" from "what lives there" gives a debuggable, reversible foundation.

**Critical design constraint:** Foundation **does not touch Homebrew**. nix-homebrew, `homebrew = {}` declarations, and the Brewfile transition are all deferred to Spec #2.

## Multi-Session Roadmap

This spec is **#1 of 3**:

```
Spec #1 — Foundation (this document)
  └─ Flake skeleton, nix-darwin module wired, home-manager wired,
     Touch ID, one proof-setting (Dark Mode). Stow + Brewfile + Homebrew
     FULLY UNCHANGED.

Spec #2 — Package Migration (future spec)
  └─ Adds nix-homebrew + nix-darwin's homebrew = {} module
  └─ Nix-first policy:
     - Every tool with a nixpkgs equivalent → home.packages
     - Casks, MAS apps, Apple-only brews → nix-darwin's homebrew module
     - brew/Brewfile.* deleted; 15-brew.zsh generator deleted
     - nix-darwin becomes authoritative for ALL package state

Spec #3 — Home Manager / Config Migration (future spec)
  └─ Configs migrate tool-by-tool via programs.* (native HM) or
     mkOutOfStoreSymlink for configs that stay in ~/.dotfiles/.
     Stow gets uninstalled at the end.

Parallel feature (independent timing): _planning/ideas/unified-formatter.md
  └─ Foundation only wires `nix fmt` to nixfmt-rfc-style for Nix files.
     Full multi-language treefmt is its own feature spec.
```

Each spec gets its own implementation plan, its own VM test, its own merge gate.

## Scope

### In scope (this spec)

- `nix/flake.nix` with inputs (nixpkgs-unstable, nix-darwin, home-manager) — **no nix-homebrew yet**
- `nix/lib/mkDarwin.nix` host constructor (parameterized by hostname/username/userModule)
- Two hosts: `pikachu` (daily driver) and `vm-test` (for Tart VM validation)
- `nix/users/nico.nix` (also imported by `vm-test` with `username = "admin"`)
- `nix/modules/darwin/touchid.nix` — Touch ID for sudo via `sudo_local`
- `nix/modules/darwin/system-defaults.nix` — single proof setting (Dark Mode)
- `nix/modules/home/symlinks.nix` — empty mkOutOfStoreSymlink buffer
- `nix/modules/home/migration/{cli,editors,shell}-tier.nix` — empty tier stubs
- `nix/modules/shared/` — created empty (with `.gitkeep`), for future cross-OS modules
- `flake.formatter` exposes `nixfmt-rfc-style` (so `nix fmt nix/` works)
- VM-test workflow for the Foundation (Tart smoke test, headless-safe validation)
- Determinate Systems Nix installer is the assumed installer; nix-darwin sets `nix.enable = false`
- Stow + Brewfile + Homebrew remain fully active throughout this spec

### Out of scope (deferred to later specs)

- **`nix-homebrew` input and module** — Spec #2 adds it (with `autoMigrate = true` and Brewfile transition steps)
- **`homebrew = {}` declarations** — Spec #2
- Tool migration (no `home.packages`, no `programs.*` enabled)
- macOS settings beyond Dark Mode (`_macOS/settings.sh` migration — Spec #3)
- Stow uninstall
- Brewfile deletion or `15-brew.zsh` removal
- Full treefmt-nix (only Nix-file formatting wired)
- `nix develop` / devshells
- `nix flake check` as CI gate
- sops-nix / agenix secrets
- flake-parts refactor

## Architecture

### Directory Layout

```
nix/
├── flake.nix                              # Inputs + outputs only
├── flake.lock                             # Auto-generated
├── lib/
│   └── mkDarwin.nix                       # Host constructor (takes userModule param)
├── hosts/
│   ├── pikachu.nix                        # Daily driver
│   └── vm-test.nix                        # Tart VM test target (reuses users/nico.nix)
├── users/
│   └── nico.nix                           # User identity + HM module imports
│                                          #   (parameterized by username, so admin user
│                                          #    in vm-test works without a second file)
└── modules/
    ├── darwin/                            # nix-darwin system modules
    │   ├── touchid.nix
    │   └── system-defaults.nix            # Proof setting only (Dark Mode)
    │                                      # NO homebrew.nix — deferred to Spec #2
    ├── home/                              # home-manager user modules
    │   ├── symlinks.nix                   # Empty buffer for mkOutOfStoreSymlink
    │   └── migration/
    │       ├── cli-tier.nix               # Stub for Spec #2 follow-ons
    │       ├── editors-tier.nix           # Stub for Spec #3
    │       └── shell-tier.nix             # Stub for Spec #3
    └── shared/                            # Cross-OS modules (empty, future)
        └── .gitkeep
```

**Why this shape:**

- `flake.nix` stays under 40 lines — pure dispatch, no devshells/checks/packages inline. This is the "thin-flake discipline" that makes a future upgrade to `flake-parts` a 1-2h refactor instead of a rewrite.
- `lib/mkDarwin.nix` centralizes host construction. It takes `userModule` as a parameter (path), so the same module file can be reused across hosts with different usernames.
- `hosts/` holds machine-specific facts (hostname, hardware). Generic modules in `modules/darwin/` are imported by the host file.
- `users/nico.nix` is parameterized — it reads `username` from `specialArgs`, so the `admin` user in `vm-test` reuses the same file without duplication.
- `modules/home/migration/` is pre-structured for the future Tier specs. Files exist but are empty — Spec #2/#3 fills them.
- `modules/shared/` is empty but visible — a contract with the future for cross-OS code if a Linux host appears.

### File Walkthrough

#### `nix/flake.nix`

```nix
{
  description = "nico's dotfiles";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url   = "github:nix-darwin/nix-darwin/master";
    home-manager.url = "github:nix-community/home-manager";

    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    darwinConfigurations = {
      pikachu = import ./lib/mkDarwin.nix inputs {
        hostname   = "pikachu";
        username   = "nico";
        userModule = ./users/nico.nix;
      };
      vm-test = import ./lib/mkDarwin.nix inputs {
        hostname   = "vm-test";
        username   = "admin";
        userModule = ./users/nico.nix;   # same module, admin reads `username` from specialArgs
      };
    };

    formatter.aarch64-darwin =
      inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
  };
}
```

Notes:
- `nix-darwin/nix-darwin/master` — the repo moved away from `LnL7/`. The new canonical location.
- `nixpkgs-unstable` is mandatory on Darwin to avoid from-source builds for darwin-specific packages.
- `follows` directives keep input closure deduplicated.
- **`nix-homebrew` is intentionally not an input.** Spec #2 adds it. Adding it as an unused input would pollute `flake.lock` without benefit.
- `formatter` is exposed so `nix fmt nix/` works from day one with RFC-166 style.

#### `nix/lib/mkDarwin.nix`

```nix
inputs: { hostname, username, userModule }:
  inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs hostname username; };
    modules = [
      ../hosts/${hostname}.nix
      ../modules/darwin/touchid.nix
      ../modules/darwin/system-defaults.nix
      # NOTE: modules/darwin/homebrew.nix is intentionally absent — added by Spec #2

      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs       = true;
        home-manager.useUserPackages     = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs    = { inherit inputs hostname username; };
        home-manager.users.${username}   = import userModule;
      }
    ];
  };
```

Notes:
- **`userModule` is an explicit path parameter.** Solves the `users/${username}.nix` problem from the earlier draft (where `vm-test` with `username = "admin"` would have tried to load a nonexistent `users/admin.nix`).
- `specialArgs` propagates `inputs`, `hostname`, `username` to all darwin modules
- `extraSpecialArgs` does the same for all home-manager modules
- `backupFileExtension = "backup"` is the rollback insurance: any file home-manager would overwrite is renamed to `.backup` instead of silently lost
- `useGlobalPkgs + useUserPackages` is the standard integrated-HM mode
- **`system = "aarch64-darwin"` is intentionally absent** — set in the host via `nixpkgs.hostPlatform` (the modern way).

#### `nix/hosts/pikachu.nix`

```nix
{ hostname, username, ... }: {
  networking.hostName     = hostname;
  networking.computerName = "Pikachu";
  system.primaryUser      = username;
  system.stateVersion     = 7;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Determinate Systems owns /etc/nix/nix.conf — nix-darwin MUST NOT also manage Nix.
  nix.enable = false;
}
```

Notes:
- **`nix.enable = false`** is the key Determinate-compat directive. nix-darwin won't write to `/etc/nix/nix.conf`. Experimental features (`nix-command`, `flakes`) are already enabled by Determinate's default install.
- `system.stateVersion = 7` matches current nix-darwin (was `5` in earlier draft, bumped).
- `nixpkgs.hostPlatform` replaces the old `system = "..."` argument to `darwinSystem` — modern style.

#### `nix/hosts/vm-test.nix`

```nix
{ hostname, username, ... }: {
  networking.hostName = hostname;
  system.primaryUser  = username;
  system.stateVersion = 7;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
}
```

VM-test host deliberately omits `computerName` and any non-essential settings. Foundation validation only — not a daily-driver simulation.

#### `nix/users/nico.nix`

```nix
{ inputs, hostname, username, ... }: {
  imports = [
    ../modules/home/symlinks.nix
    ../modules/home/migration/cli-tier.nix
    ../modules/home/migration/editors-tier.nix
    ../modules/home/migration/shell-tier.nix
  ];

  home.username      = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion  = "25.11";

  programs.home-manager.enable = true;
}
```

This module is parameterized by `username`, so it works for both `nico` (on pikachu) and `admin` (on vm-test) without a second file. If a real per-user override is needed later, add `users/admin.nix` and switch `userModule` in `flake.nix`.

#### `nix/modules/darwin/touchid.nix`

```nix
{ ... }: {
  security.pam.services.sudo_local.touchIdAuth = true;
}
```

Modern nix-darwin option — writes `/etc/pam.d/sudo_local`. Validated headlessly in the VM via file-content check.

#### `nix/modules/darwin/system-defaults.nix`

```nix
{ ... }: {
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
}
```

Proof-of-pipeline only. Full migration of `_macOS/settings.sh` (1005 lines) is Spec #3.

#### `nix/modules/home/symlinks.nix`

```nix
{ config, ... }: {
  # Empty buffer. Spec #3 populates this with entries like:
  #   xdg.configFile."nvim".source =
  #     config.lib.file.mkOutOfStoreSymlink
  #       "${config.home.homeDirectory}/.dotfiles/nvim/.config/nvim";
}
```

#### `nix/modules/home/migration/cli-tier.nix` (and editors-tier.nix, shell-tier.nix)

```nix
{ pkgs, ... }: {
  # Empty. Future tier specs add packages and programs.* here.
}
```

## Data Flow

```
$ darwin-rebuild switch --flake ~/.dotfiles/nix#pikachu
       │
       ▼
flake.nix → outputs.darwinConfigurations.pikachu
       │
       ▼
lib/mkDarwin.nix { hostname = "pikachu"; username = "nico"; userModule = ./users/nico.nix; }
       │
       ▼
nix-darwin.lib.darwinSystem
       ├─ hosts/pikachu.nix       (hostName, primaryUser, nix.enable=false, hostPlatform)
       ├─ modules/darwin/touchid.nix       (writes /etc/pam.d/sudo_local)
       ├─ modules/darwin/system-defaults.nix (Dark Mode)
       └─ home-manager.darwinModules.home-manager
              └─ import userModule  (= ./users/nico.nix)
                     ├─ modules/home/symlinks.nix       (empty)
                     ├─ modules/home/migration/cli-tier.nix    (empty)
                     ├─ modules/home/migration/editors-tier.nix (empty)
                     └─ modules/home/migration/shell-tier.nix  (empty)
```

**Notable absences:**
- No nix-homebrew module → Homebrew is untouched
- No `nix.settings.*` → Determinate owns Nix config

## Coexistence with Existing System

| System | Owned by | State after Foundation |
|--------|----------|------------------------|
| Stow symlinks | `stow */` from `~/.dotfiles/` | **unchanged**, all 16 packages still stowed |
| Brewfile generation | `zsh/conf.d/15-brew.zsh` concatenates `brew/Brewfile.*` to `~/.Brewfile` | **unchanged** |
| Homebrew installation | Existing `/opt/homebrew` | **unchanged** — not touched, not migrated, not managed |
| Homebrew packages | `brew bundle install` via `~/.Brewfile` | **unchanged** |
| `/etc/nix/nix.conf` | Determinate Systems | unchanged (nix-darwin has `nix.enable = false`) |
| Touch ID for sudo | Was manual `/etc/pam.d/sudo` edit (or fresh) | now declarative via `/etc/pam.d/sudo_local` |
| Dark Mode | Was manual System Settings | now declarative |
| `~/.config/*` symlinks | Stow | unchanged |

Translation: applying this Foundation should produce **no behavioral changes** to your daily work other than:
- Touch ID continues to work (now declaratively via `sudo_local`)
- Dark Mode stays on (now declaratively)
- `darwin-rebuild` is now a meaningful command on your system

## Testing Strategy (VM-first)

### VM bootstrap flow (Tart, headless)

The Foundation has **no Homebrew dependency** in the VM, so VM testing is much simpler than the broader dotfiles VM-test. The VM only needs Nix + the flake:

```bash
# 1. Clone fresh Tart base macOS image
tart clone ghcr.io/cirruslabs/macos-sequoia-base:latest nix-foundation-test

# 2. Boot headless, mount dotfiles
tart run --no-graphics --dir=dotfiles:~/.dotfiles nix-foundation-test &
ssh admin@$(tart ip nix-foundation-test)   # default admin/admin

# Inside VM:
# 3. Install Determinate Systems Nix
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install --determinate

# 4. First switch (bootstrap — darwin-rebuild not yet on PATH)
nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- \
  switch --flake ~/.dotfiles/nix#vm-test

# 5. Validate (see checklist below)

# 6. Cleanup
tart delete nix-foundation-test
```

### Validation checklist (headless-safe)

Run inside the VM (and later on `pikachu`):

- [ ] `darwin-rebuild switch --flake <flake>#<host>` exits 0
- [ ] `darwin-rebuild --list-generations` shows ≥1 generation
- [ ] `test -f /etc/pam.d/sudo_local && grep -q pam_tid /etc/pam.d/sudo_local` (Touch ID file-content check, headless-safe — does NOT attempt `sudo`)
- [ ] `defaults read -g AppleInterfaceStyle` returns `Dark`
- [ ] `nix fmt nix/flake.nix` formats without error
- [ ] `nix flake check ~/.dotfiles/nix` passes (evaluates all configs)
- [ ] `darwin-rebuild build --flake <flake>#<other-host>` also builds (sanity: both hosts evaluate independently)
- [ ] Inside VM: `which brew` returns "not found" (no Homebrew migration happened — Foundation truly didn't touch it)
- [ ] `darwin-rebuild --rollback` works (test once in VM, then re-switch to current)

### Local apply on `pikachu`

After the VM validates:

- [ ] `darwin-rebuild switch --flake ~/.dotfiles/nix#pikachu`
- [ ] All validation-checklist items pass on pikachu
- [ ] **Critical post-checks** (Foundation must not have broken existing system):
  - [ ] `stow --restow */` from `~/.dotfiles` exits 0 (Stow still functional)
  - [ ] `brew bundle check` reports the expected state (no unexpected uninstalls)
  - [ ] `brew list | wc -l` matches the count before applying Foundation
  - [ ] Open a fresh terminal — Zsh starts cleanly, prompt renders, atuin history works
  - [ ] `nvim` launches, plugins load, no errors
  - [ ] `git status` works (no auth disruption)
  - [ ] `lazygit`, `k9s` launch normally

### Smoke test (24-48h)

After the local switch and post-checks, use the machine normally for 24-48h before declaring the Foundation done. Watch for:
- Unexpected `.backup` files appearing in `$HOME` (would indicate HM clashed with Stow)
- Touch ID prompts failing (would indicate `sudo_local` got disturbed)
- Brewfile-managed apps misbehaving (would indicate Homebrew got disturbed despite all guarantees)

If anything in that window is wrong → rollback (next section).

## Rollback Strategy

If the Foundation breaks something:

### First-line rollback (Nix-level)
1. `darwin-rebuild --rollback` — return to previous nix-darwin generation
   - **Caveat:** this only rolls back what nix-darwin set. Specifically: `/etc/pam.d/sudo_local`, `system.defaults`, the user's home-manager profile. It does NOT roll back the Determinate Nix install itself.

### Full state-list to audit during rollback

State touched by the Foundation:
- `/etc/pam.d/sudo_local` — written by nix-darwin's TouchID module (rolled back by `darwin-rebuild --rollback`)
- `/var/db/com.apple.universalaccess.plist`-equivalent for `AppleInterfaceStyle` — set by `system.defaults`
- nix-darwin profile links: `/etc/static`, `/run/current-system` → rolled back
- Home-Manager profile + backup files: `find $HOME -name "*.backup"` and rename if any appeared
- **Determinate-installed state (NOT rolled back by `darwin-rebuild --rollback`):**
  - `/nix/store` — the entire Nix store
  - `/etc/nix/nix.conf`, `/etc/determinate/config.json` — Determinate-owned
  - `/etc/zshrc`, `/etc/bashrc` lines added by the installer
  - `/etc/synthetic.conf` mount-point entry
  - APFS volume for `/nix`

### Removing Nix completely (nuclear)
If the Foundation must be uninstalled entirely (not just rolled back to a previous generation):
```bash
/nix/nix-installer uninstall                     # Determinate's reverse installer
# Then verify:
ls /nix /etc/nix /etc/synthetic.conf 2>/dev/null  # should be gone
```

### Restoring Stow / Brewfile if disturbed
Foundation is engineered so this is unnecessary, but just in case:
```bash
cd ~/.dotfiles
stow */                                  # re-stow everything
brew bundle check                        # report state
brew bundle install                      # restore expected brews
```

### Why the Foundation makes rollback rare
- Foundation does NOT touch Homebrew (no nix-homebrew imported)
- Foundation does NOT touch Stow (no symlinks migrated)
- Foundation does NOT touch daily-use configs (no `programs.*` enabled)
- `backupFileExtension = "backup"` means no files are silently overwritten
- Determinate's installer has its own clean uninstaller

## Acceptance Criteria

The Foundation is **done** when:

- [ ] `nix/` directory exists at repo root with the file layout above
- [ ] Determinate Systems Nix is installed on `pikachu`
- [ ] `nix flake check ./nix` passes from `~/.dotfiles`
- [ ] `nix flake show ./nix` lists both `pikachu` and `vm-test` darwinConfigurations
- [ ] `darwin-rebuild build --flake ./nix#pikachu` builds without error
- [ ] `darwin-rebuild build --flake ./nix#vm-test` builds without error
- [ ] VM-test script validates `vm-test` host successfully (full bootstrap flow above)
- [ ] Local switch on `pikachu` succeeds
- [ ] All validation-checklist items pass on `pikachu`
- [ ] All post-checks pass (Stow + Brewfile + daily tools unaffected)
- [ ] 24-48h smoke test stable
- [ ] Spec is reviewed by user
- [ ] Implementation plan exists (separate document, written via `writing-plans` skill)
- [ ] `_planning/ideas/roadmap-2026.md` Phase 3 updated to reference the 3-spec split
- [ ] `_planning/TODO.md` updated with current Foundation status

## Implementation Sequencing

Per-session breakdown (designed for `executing-plans` skill):

### Session 1 — Bootstrap & flake skeleton (1-2h)

1. Install Determinate Systems Nix on `pikachu` (`curl ... determinate.systems/nix | sh -s -- install --determinate`)
2. Create `nix/` directory with placeholder files
3. Write `flake.nix`, `lib/mkDarwin.nix`, `hosts/pikachu.nix`, `hosts/vm-test.nix`, `users/nico.nix`
4. Add `.gitignore` entry for `nix/result*`
5. Run `nix flake show ./nix` — verify outputs resolve
6. Commit (does not apply yet)

### Session 2 — Modules wired (1-2h)

1. Write `modules/darwin/touchid.nix`, `system-defaults.nix`
2. Write `modules/home/symlinks.nix` + tier stubs
3. Add `modules/shared/.gitkeep`
4. `darwin-rebuild build --flake ./nix#pikachu` — verify it builds (no apply yet)
5. `darwin-rebuild build --flake ./nix#vm-test` — verify both hosts build
6. Commit

### Session 3 — VM-test integration (1-2h)

1. Write a new `_test/vm-test-nix-foundation.sh` (or extend `vm-test-macos.sh` with a `--foundation-only` flag) implementing the headless bootstrap flow above
2. Add a `just` target: `just test-nix-foundation`
3. Run VM test until green (all validation checklist items pass)
4. Commit

### Session 4 — Local apply + smoke test (1-2h apply, then 24-48h watch)

1. `darwin-rebuild switch --flake ./nix#pikachu` on the actual machine
2. Run validation checklist + post-checks on pikachu
3. Use the machine normally for 24-48h
4. If stable: spec is done. Move to Spec #2 brainstorming.
5. If unstable: rollback, debug, retry.

Total estimated: **4-8 hours of active work across 3-4 sessions** (plus 24-48h passive smoke window).

## Multi-Session Handoff Checklist

At the **end** of every session, record this in the commit message (or update `_planning/TODO.md` Foundation section):

```
SESSION HANDOFF — Nix-Darwin Foundation
─────────────────────────────────────────
Last commit:          <git sha>
Last action:          <e.g., "wrote flake.nix + lib/mkDarwin.nix", "ran darwin-rebuild build successfully">
darwin-rebuild state: <not run | build only | switch ran on vm-test | switch ran on pikachu>
Current generation:   <output of `darwin-rebuild --list-generations | tail -1`, or "n/a">
Installer mode:       Determinate Systems (--determinate flag)
Homebrew prefix:      /opt/homebrew (untouched, count: <brew list | wc -l>)
Next command:         <exact command to run on resume, e.g., "darwin-rebuild build --flake ./nix#vm-test">
Blocking issue:       <none | description if rollback was needed>
```

At the **start** of every session:
1. `cd ~/.dotfiles && git log --oneline -10` — see what's in flight
2. Read this spec
3. Read the implementation plan (created via `writing-plans`)
4. Read the most recent SESSION HANDOFF
5. If `darwin-rebuild` has run: `darwin-rebuild --list-generations | tail -5`
6. Resume from "Next command"

## Open Questions / Implementation-Time Decisions

These are NOT spec-blockers — they're flagged for the implementation plan to resolve.

1. **`just nix-build` / `just nix-switch` targets.** Recommendation: yes, add to both `justfile` and `Makefile` (per the project's sync rule). Implementation plan should include them. Targets:
   ```
   just nix-build           # darwin-rebuild build --flake ./nix#pikachu
   just nix-switch          # darwin-rebuild switch --flake ./nix#pikachu
   just nix-rollback        # darwin-rebuild --rollback
   just nix-list            # darwin-rebuild --list-generations
   just test-nix-foundation # the VM-test target from Session 3
   ```

2. **`_install/nix.sh`** — committed installer wrapper for reproducibility? Recommendation: yes, thin wrapper that runs the Determinate `curl ... | sh -s -- install --determinate` line. So a fresh machine bootstrap is `bash _install/nix.sh && darwin-rebuild switch ...`.

3. **`stateVersion` review at implementation time.** Pinned to `7` for nix-darwin and `25.11` for home-manager. Re-check at implementation: `nix-darwin` may have bumped further. The rule: pin to whatever is current when you first apply; don't change it after.

4. **VM-test host's username.** `admin` matches the default Tart macOS image. If Tart's default changes, update `vm-test.nix` accordingly.

5. **`nix flake check` integration with GitHub Actions CI.** Foundation doesn't add this — deferred to the Unified Formatter Phase B spec.

## Related

- [`_planning/ideas/roadmap-2026.md`](../../_planning/ideas/roadmap-2026.md) — Phase 3 (this spec replaces the old tier-based plan with a 3-spec split)
- [`_planning/ideas/unified-formatter.md`](../../_planning/ideas/unified-formatter.md) — Parallel feature, references nixfmt-rfc-style which this spec wires
- [`_planning/TODO.md`](../../_planning/TODO.md) — Updated Foundation status
- [nix-darwin (new repo location)](https://github.com/nix-darwin/nix-darwin)
- [nix-darwin Manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Determinate Systems Nix Installer](https://docs.determinate.systems/)
- [Determinate + nix-darwin guide](https://docs.determinate.systems/guides/nix-darwin/)
- [nix-homebrew](https://github.com/zhaofengli/nix-homebrew) — deferred to Spec #2
- [RFC 166 — Nix formatting](https://github.com/NixOS/rfcs/pull/166)

---

**Created:** 2026-05-27
**Last revised:** 2026-05-27 (Codex review applied — defer nix-homebrew, fix `userModule`, `nix.enable=false`, repo URL, stateVersion=7, headless VM validation, expanded rollback, session handoff checklist)
**Status:** Design (awaiting user review before writing implementation plan)
**Priority:** High (foundation for Phase 3)

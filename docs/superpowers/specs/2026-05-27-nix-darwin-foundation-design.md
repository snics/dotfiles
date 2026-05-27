# Nix-Darwin Foundation Design

Establish a maintainable nix-darwin + home-manager flake skeleton on macOS that future package- and config-migration specs can fill in incrementally. No tools migrate in this spec — the existing Stow + Brewfile setup remains fully active.

## Goal

Move from a Stow + Brewfile dotfiles setup to a declarative Nix-managed system in three discrete, session-bounded specs. This first spec establishes only the **architecture** — directory layout, module skeleton, helper functions, host/user parameterization, and Touch ID — so that subsequent specs (packages, then configs) can plug in without touching plumbing.

**Why now:** The user is new to Nix. Migrating both architecture and tools in one spec produces too many unknowns at once. Splitting "where things live" from "what lives there" gives a debuggable, reversible foundation.

## Multi-Session Roadmap

This spec is **#1 of 3**:

```
Spec #1 — Foundation (this document)
  └─ Flake skeleton, nix-darwin module wired, home-manager wired,
     nix-homebrew bridge in place (but empty), Touch ID, one proof-setting.
     Stow + Brewfile fully unchanged.

Spec #2 — Package Migration (separate, future spec)
  └─ Nix-first policy:
     - Every tool with a nixpkgs equivalent → home.packages
     - Casks, MAS apps, Apple-only brews → nix-darwin's homebrew = {} module
     - brew/Brewfile.* deleted; 15-brew.zsh generator deleted
     - nix-darwin becomes authoritative for ALL package state

Spec #3 — Home Manager / Config Migration (separate, future spec)
  └─ Configs migrate tool-by-tool via programs.* (native HM) or
     mkOutOfStoreSymlink for configs that stay in ~/.dotfiles/.
     Stow gets uninstalled at the end.

Parallel feature (independent timing): _planning/ideas/unified-formatter.md
  └─ treefmt-nix unified formatter. Foundation only wires `nix fmt` to
     nixfmt-rfc-style for Nix files. Full multi-language treefmt is its
     own feature spec.
```

Each spec gets its own implementation plan, its own VM test, its own merge gate.

## Scope

### In scope (this spec)

- `nix/flake.nix` with inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew)
- `nix/lib/mkDarwin.nix` host constructor (parameterized by hostname/username)
- Two hosts: `pikachu` (daily driver) and `vm-test` (for Tart VM validation)
- One user: `nico`
- `nix/modules/darwin/touchid.nix` — Touch ID for sudo
- `nix/modules/darwin/homebrew.nix` — nix-homebrew bridge, lists empty
- `nix/modules/darwin/system-defaults.nix` — single proof setting (Dark Mode)
- `nix/modules/home/symlinks.nix` — empty mkOutOfStoreSymlink buffer
- `nix/modules/home/migration/{cli,editors,shell}-tier.nix` — empty tier stubs
- `nix/modules/shared/` — created empty, for future cross-OS modules
- `flake.formatter` exposes `nixfmt-rfc-style` (so `nix fmt nix/` works)
- VM-test workflow for the foundation (Tart smoke test)
- Determinate Systems Nix installer instructions
- Stow and Brewfile remain fully active throughout this spec

### Out of scope (deferred to later specs)

- Any tool migration (no `home.packages` entries, no `programs.*` enabled)
- Cask migration (`homebrew.casks` stays `[]`)
- MAS app migration (`homebrew.masApps` stays `{}`)
- macOS settings migration from `_macOS/settings.sh` (only Dark Mode as proof)
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
│   └── mkDarwin.nix                       # Host constructor
├── hosts/
│   ├── pikachu.nix                        # Daily driver
│   └── vm-test.nix                        # Tart VM test target
├── users/
│   └── nico.nix                           # User identity + HM module imports
└── modules/
    ├── darwin/                            # nix-darwin system modules
    │   ├── touchid.nix
    │   ├── homebrew.nix                   # nix-homebrew bridge (empty lists)
    │   └── system-defaults.nix            # Proof setting only
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
- `lib/mkDarwin.nix` centralizes host construction — adding a host is "one file in `hosts/` + one line in `flake.nix`".
- `hosts/` holds machine-specific facts (hostname, hardware). Generic modules in `modules/darwin/` are imported by the host file.
- `users/nico.nix` is the single import-point for all home-manager modules — Tier specs edit `cli-tier.nix` etc. without touching imports.
- `modules/home/migration/` is pre-structured for the future Tier specs. Files exist but are empty — Spec #2/#3 fills them.
- `modules/shared/` is empty but visible — a contract with the future for cross-OS code if a Linux host appears.

### File Walkthrough

#### `nix/flake.nix`

```nix
{
  description = "nico's dotfiles";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url   = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    darwinConfigurations = {
      pikachu = import ./lib/mkDarwin.nix inputs {
        hostname = "pikachu";
        username = "nico";
      };
      vm-test = import ./lib/mkDarwin.nix inputs {
        hostname = "vm-test";
        username = "admin";
      };
    };

    formatter.aarch64-darwin =
      inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
  };
}
```

Notes:
- `nixpkgs-unstable` is mandatory on Darwin to avoid from-source builds for darwin-specific packages
- `follows` directives keep input closure deduplicated
- `nix-homebrew` is wired as an input from day one so the Spec #2 transition is `homebrew.casks = []` → `[...stuff...]`, no input change
- `formatter` is exposed so `nix fmt nix/` works from day one with RFC-166 style

#### `nix/lib/mkDarwin.nix`

```nix
inputs: { hostname, username, system ? "aarch64-darwin" }:
  inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    specialArgs = { inherit inputs hostname username; };
    modules = [
      ../hosts/${hostname}.nix
      ../modules/darwin/touchid.nix
      ../modules/darwin/homebrew.nix
      ../modules/darwin/system-defaults.nix

      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs       = true;
        home-manager.useUserPackages     = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs    = { inherit inputs hostname username; };
        home-manager.users.${username}   = import ../users/${username}.nix;
      }
    ];
  };
```

Notes:
- `specialArgs` propagates `inputs`, `hostname`, `username` to all darwin modules
- `extraSpecialArgs` does the same for all home-manager modules
- `backupFileExtension = "backup"` is the rollback insurance: any file home-manager would overwrite (e.g., a Stow symlink) is renamed to `.backup` instead of silently lost
- `useGlobalPkgs + useUserPackages` is the standard integrated-HM mode

#### `nix/hosts/pikachu.nix`

```nix
{ hostname, username, ... }: {
  networking.hostName     = hostname;
  networking.computerName = "Pikachu";
  system.primaryUser      = username;
  system.stateVersion     = 5;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users         = [ username ];
}
```

#### `nix/hosts/vm-test.nix`

```nix
{ hostname, username, ... }: {
  networking.hostName = hostname;
  system.primaryUser  = username;
  system.stateVersion = 5;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Note: VM-test host deliberately omits `computerName` and any non-essential settings. Foundation validation only — not a daily-driver simulation.

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

#### `nix/modules/darwin/touchid.nix`

```nix
{ ... }: {
  security.pam.services.sudo_local.touchIdAuth = true;
}
```

#### `nix/modules/darwin/homebrew.nix`

```nix
{ inputs, username, ... }: {
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable        = true;
    enableRosetta = false;
    user          = username;
    mutableTaps   = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade    = false;
      cleanup    = "none";
    };
    brews    = [];
    casks    = [];
    masApps  = {};
    taps     = [];
  };
}
```

Critical: `cleanup = "none"` ensures nix-darwin **does not uninstall** any brew that isn't declared in Nix. The current Brewfile-managed installation continues to function uninterrupted. Cleanup escalates in Spec #2 (`"uninstall"` → `"zap"`).

#### `nix/modules/darwin/system-defaults.nix`

```nix
{ ... }: {
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
}
```

Proof-of-pipeline only. The full migration of `_macOS/settings.sh` (1005 lines) is a separate spec.

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
lib/mkDarwin.nix { hostname = "pikachu"; username = "nico"; }
       │
       ▼
nix-darwin.lib.darwinSystem
       ├─ hosts/pikachu.nix       (host-specific)
       ├─ modules/darwin/touchid.nix
       ├─ modules/darwin/homebrew.nix      → nix-homebrew installs brew; empty lists
       ├─ modules/darwin/system-defaults.nix → Dark Mode
       └─ home-manager.darwinModules.home-manager
              └─ users/nico.nix
                     ├─ modules/home/symlinks.nix       (empty)
                     ├─ modules/home/migration/cli-tier.nix    (empty)
                     ├─ modules/home/migration/editors-tier.nix (empty)
                     └─ modules/home/migration/shell-tier.nix  (empty)
```

## Coexistence with Existing System

During this spec, **both systems run side-by-side**:

| System | Owned by | State after Foundation |
|--------|----------|------------------------|
| Stow symlinks | `stow */` from `~/.dotfiles/` | unchanged, all 16 packages still stowed |
| Brewfile generation | `zsh/conf.d/15-brew.zsh` concatenates `brew/Brewfile.*` to `~/.Brewfile` | unchanged |
| Homebrew packages | `brew bundle install` via `~/.Brewfile` | unchanged — all brews, casks, MAS apps installed via Homebrew |
| Touch ID for sudo | Now declared in `modules/darwin/touchid.nix` | declarative, but functionally same as before |
| Dark Mode | Now declared in `modules/darwin/system-defaults.nix` | declarative, but functionally same as before |
| `~/.config/*` symlinks | Stow | unchanged |
| `~/.local/state/nix/profile/*` | nix-darwin | only the proof settings |

Translation: applying this Foundation should produce **no behavioral changes** to your daily work other than:
- Touch ID continues to work (now declaratively)
- Dark Mode stays on (now declaratively)
- `darwin-rebuild` is now a meaningful command on your system

## Testing Strategy (VM-first)

### Test sequence

1. **Tart VM is the proving ground.** Reuse the existing `_test/vm-test-macos.sh` infrastructure. Add a new test script (or extend the existing one) that:
   - Clones the dotfiles repo into the VM
   - Installs Nix via Determinate Systems installer
   - Runs `darwin-rebuild switch --flake ~/.dotfiles/nix#vm-test`
   - Validates: nix-darwin generation created, Touch ID PAM entry exists, Dark Mode is active, home-manager backup-extension is configured, `nix fmt` works.

2. **Only if VM-test passes**, apply locally:
   - `darwin-rebuild switch --flake ~/.dotfiles/nix#pikachu`
   - Validate the same checks on `pikachu`
   - Verify Stow + Brewfile remain functional (run `stow --restow */`, `brew bundle check`)

3. **Smoke-test daily flows for 24-48h before merging Spec #2:**
   - Open new terminals, verify Zsh starts cleanly
   - Run NeoVim, verify plugins load
   - Verify `brew install <something>` still works (manual brew is not blocked)
   - Verify `git`, `lazygit`, `k9s` continue to function

### Validation checklist (per host)

- [ ] `darwin-rebuild switch` exits 0
- [ ] `darwin-version` reports a generation number
- [ ] `sudo -k && sudo true` prompts for Touch ID (not password)
- [ ] `defaults read -g AppleInterfaceStyle` returns `Dark`
- [ ] `~/.config/*` symlinks created by Stow still exist and resolve
- [ ] `brew list` returns the expected set of brews (no unexpected uninstalls)
- [ ] `nix fmt nix/flake.nix` formats without error
- [ ] `darwin-rebuild --rollback` works (test once, then re-apply)

## Rollback Strategy

If the Foundation breaks daily work:

1. **First-line rollback:** `darwin-rebuild --rollback` — returns to previous nix-darwin generation
2. **Nix completely off:** Remove `/etc/zshenv` lines added by Determinate Systems installer, restart shells
3. **Restore any HM-backed-up files:** `find $HOME -name "*.backup" -type l` (or `-type f`) and rename back
4. **Stow re-restore (if symlinks got disturbed):** `cd ~/.dotfiles && stow */`
5. **Nuclear:** Determinate Systems uninstall command + remove `nix/` directory in git

The Foundation is engineered to make rollback rare:
- `cleanup = "none"` means no brews are uninstalled
- `backupFileExtension = "backup"` means no files are silently overwritten
- No Stow symlinks are touched
- No daily-use config (zsh, nvim, git, ...) is migrated yet

## Acceptance Criteria

The Foundation is **done** when:

- [ ] `nix/` directory exists at repo root with the file layout above
- [ ] `nix flake check ./nix` (or `nix flake show`) passes from `~/.dotfiles`
- [ ] `darwin-rebuild build --flake ./nix#pikachu` builds without error
- [ ] `darwin-rebuild build --flake ./nix#vm-test` builds without error
- [ ] VM-test script validates `vm-test` host successfully
- [ ] Local apply succeeds on `pikachu`
- [ ] All validation-checklist items pass (above)
- [ ] Stow + Brewfile remain fully functional, no symlinks broken
- [ ] Spec is reviewed by user
- [ ] Implementation plan exists (separate document, written via `writing-plans` skill)
- [ ] `_planning/ideas/roadmap-2026.md` Phase 3 updated to reference the 3-spec split
- [ ] `_planning/TODO.md` updated with current Foundation status

## Implementation Sequencing

Per-session breakdown (designed for `executing-plans` skill):

### Session 1 — Bootstrap & flake skeleton (1-2h)

1. Install Nix via Determinate Systems on `pikachu`
2. Create `nix/` directory with placeholder files
3. Write `flake.nix`, `lib/mkDarwin.nix`, `hosts/pikachu.nix`, `users/nico.nix`
4. Add `.gitignore` entry for `nix/result*`
5. Run `nix flake show` — verify outputs resolve
6. Commit (does not apply yet)

### Session 2 — Modules wired (1-2h)

1. Write `modules/darwin/touchid.nix`, `homebrew.nix`, `system-defaults.nix`
2. Write `modules/home/symlinks.nix` + tier stubs
3. `darwin-rebuild build --flake ./nix#pikachu` — verify it builds
4. Commit

### Session 3 — VM-test integration (1-2h)

1. Write `hosts/vm-test.nix`
2. Extend `_test/vm-test-macos.sh` to provision Nix + run `darwin-rebuild switch --flake ... #vm-test`
3. Run VM test until green
4. Commit

### Session 4 — Local apply + smoke test (1-2h)

1. `darwin-rebuild switch --flake ./nix#pikachu` on the actual machine
2. Run validation checklist
3. Use the machine normally for 24-48h
4. If stable: spec is done. Move to Spec #2 brainstorming.
5. If unstable: rollback, debug, retry.

Total estimated: **4-8 hours across 3-4 sessions.**

## Multi-Session Continuity (where to pick up next time)

Each session starts by:

1. Reading this spec (`docs/superpowers/specs/2026-05-27-nix-darwin-foundation-design.md`)
2. Reading the implementation plan (created in next step via `writing-plans` skill)
3. Reading current state of `nix/` directory
4. Checking git log for the most recent Foundation commit
5. Running `darwin-rebuild --list-generations` to see what's already been applied

The spec, the plan, and `git log` together are the persistent state. No undocumented context required to continue.

## Open Questions

1. **Determinate Systems installer URL/version pinning:** Should the installer command be committed to a script in `_install/`? (Recommendation: yes, add `_install/nix.sh` for reproducibility, but defer to the implementation plan.)

2. **Where does `darwin-rebuild` get invoked from?** Options: ad-hoc command, `justfile` target, or both. (Recommendation: add `just nix-switch` + `just nix-build` targets to match the existing Justfile pattern.)

3. **`stateVersion` for nix-darwin:** Pinned to `5` initially. Should be reviewed against latest nix-darwin docs at implementation time.

4. **VM-test host's username:** `admin` matches the default Tart macOS image. Document this so future VM-test changes don't break.

5. **`nix flake check` integration with CI:** Foundation doesn't add this — should it? Recommendation: defer to the Unified Formatter Phase B spec.

## Related

- [`_planning/ideas/roadmap-2026.md`](../../_planning/ideas/roadmap-2026.md) — Phase 3 (this spec replaces the old tier-based plan with a 3-spec split)
- [`_planning/ideas/unified-formatter.md`](../../_planning/ideas/unified-formatter.md) — Parallel feature, references nixfmt-rfc-style which this spec wires
- [Nix-Darwin Manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-homebrew](https://github.com/zhaofengli/nix-homebrew)
- [Determinate Systems Installer](https://install.determinate.systems/)
- [RFC 166 — Nix formatting](https://github.com/NixOS/rfcs/pull/166)

---

**Created:** 2026-05-27
**Status:** Design (awaiting user review before writing implementation plan)
**Priority:** High (foundation for Phase 3)
**Author:** brainstorming session with codex:rescue, general-purpose research agents

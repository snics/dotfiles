# Nix-Darwin Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a maintainable nix-darwin + home-manager flake skeleton under `nix/`, exposing two host configurations (`pikachu` daily driver, `vm-test` Tart VM) that successfully apply Touch ID + Dark Mode declaratively while leaving Stow + Brewfile + Homebrew completely untouched.

**Architecture:** Plain modular flake with `lib/mkDarwin.nix` host constructor + `hosts/` (machine-specific) + `users/` (parameterized) + `modules/{darwin,home,shared}/`. nix-darwin's home-manager module integrates HM. nix-homebrew + `homebrew = {}` are deliberately deferred to Spec #2. Determinate Systems owns `/etc/nix/nix.conf`; nix-darwin sets `nix.enable = false`.

**Tech Stack:** Nix (Determinate Systems installer), nix-darwin (`github:nix-darwin/nix-darwin/master`), home-manager (`github:nix-community/home-manager`), nixpkgs-unstable, nixfmt-rfc-style.

**Design Spec:** `docs/superpowers/specs/2026-05-27-nix-darwin-foundation-design.md`

---

## Verification Commands

After every task that touches `nix/`, run from the repo root:

```bash
nix flake show ./nix
# Expected: lists darwinConfigurations.pikachu and darwinConfigurations.vm-test
# Plus: formatter.aarch64-darwin = nixfmt-rfc-style
```

For host-specific build verification (does not apply, only evaluates):

```bash
darwin-rebuild build --flake ./nix#pikachu
darwin-rebuild build --flake ./nix#vm-test
# Expected: both exit 0, produce ./result symlinks (gitignored)
```

> Note: `darwin-rebuild` is not on PATH until the **first successful switch** completes. Until then, use:
> ```bash
> nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- build --flake ./nix#pikachu
> ```

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `_install/nix.sh` | Create | Thin wrapper around Determinate's installer |
| `.gitignore` | Modify | Add `nix/result*` |
| `nix/flake.nix` | Create | Inputs + outputs (darwinConfigurations, formatter) |
| `nix/lib/mkDarwin.nix` | Create | Host constructor parameterized by hostname/username/userModule |
| `nix/hosts/pikachu.nix` | Create | Daily driver — hostname, primaryUser, hostPlatform, nix.enable=false |
| `nix/hosts/vm-test.nix` | Create | Tart VM test target |
| `nix/users/nico.nix` | Create | User identity + HM module imports (reused by vm-test) |
| `nix/modules/darwin/touchid.nix` | Create | `sudo_local` PAM Touch ID |
| `nix/modules/darwin/system-defaults.nix` | Create | Proof setting (Dark Mode) |
| `nix/modules/home/symlinks.nix` | Create | Empty `mkOutOfStoreSymlink` buffer |
| `nix/modules/home/migration/cli-tier.nix` | Create | Empty stub for Spec #2 |
| `nix/modules/home/migration/editors-tier.nix` | Create | Empty stub for Spec #3 |
| `nix/modules/home/migration/shell-tier.nix` | Create | Empty stub for Spec #3 |
| `nix/modules/shared/.gitkeep` | Create | Cross-OS placeholder dir |
| `justfile` | Modify | Add nix-build, nix-switch, nix-rollback, nix-list, test-nix-foundation targets |
| `Makefile` | Modify | Mirror the above (sync rule) |
| `_test/vm-test-nix-foundation.sh` | Create | Headless Tart VM test for the Foundation |
| `_planning/TODO.md` | Modify | Tick off Foundation checkboxes at the end |

---

## Session 1 — Bootstrap (Tasks 1-3)

### Task 1: Determinate Nix installer wrapper

**Files:**
- Create: `_install/nix.sh`

- [ ] **Step 1: Write the installer wrapper**

Create `_install/nix.sh`:

```bash
#!/usr/bin/env bash
# Install Nix via the Determinate Systems installer.
# Re-runnable: the installer detects existing installations and prompts.

set -euo pipefail

echo "==> Installing Nix (Determinate Systems)..."

if command -v nix >/dev/null 2>&1; then
    echo "    Nix is already installed: $(nix --version)"
    echo "    To re-install, run: /nix/nix-installer uninstall  (then re-run this script)"
    exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix \
    | sh -s -- install --determinate

echo ""
echo "==> Nix installed. Open a new shell, then:"
echo "    nix --version"
echo "    nix flake show ~/.dotfiles/nix"
```

- [ ] **Step 2: Make it executable**

Run:
```bash
chmod +x _install/nix.sh
ls -l _install/nix.sh
```
Expected: file has `-rwxr-xr-x` (or similar with execute bit).

- [ ] **Step 3: Commit**

```bash
git add _install/nix.sh
git commit -m "✨ feat(install): add Determinate Nix installer wrapper"
```

---

### Task 2: Install Nix (interactive)

**Files:** none (system state only)

- [ ] **Step 1: Run the installer**

```bash
bash _install/nix.sh
```

Follow the interactive prompts (the installer asks for sudo password, confirmation, etc.). Determinate uses `--determinate` flag which enables their own daemon + telemetry opt-in (skipped via prompts if undesired).

Expected: installer creates `/nix/store`, APFS volume for `/nix`, edits `/etc/zshrc` (adds Nix env shim).

- [ ] **Step 2: Open a fresh terminal and verify Nix is available**

In a **new** terminal (so the shell sources the new `/etc/zshrc`):
```bash
nix --version
```
Expected: prints version (e.g., `nix (Determinate Nix 3.x.x) ...`).

```bash
nix flake show github:nix-darwin/nix-darwin/master 2>&1 | head -5
```
Expected: shows nix-darwin's flake outputs (proves network + flakes work).

- [ ] **Step 3: No commit (system state only)**

Nothing to commit. Continue to Task 3.

---

### Task 3: Bootstrap `nix/` directory + .gitignore

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add `nix/result*` to .gitignore**

Append to `.gitignore`:
```
# nix-darwin / home-manager build outputs
nix/result
nix/result-*
```

If `.gitignore` does not yet have a Nix section, place the entries at the bottom under a `# Nix` heading.

- [ ] **Step 2: Create the nix/ directory tree**

```bash
mkdir -p nix/lib nix/hosts nix/users \
         nix/modules/darwin nix/modules/home/migration nix/modules/shared
touch nix/modules/shared/.gitkeep
```

Verify:
```bash
find nix/ -type d
```
Expected:
```
nix/
nix/lib
nix/hosts
nix/users
nix/modules
nix/modules/darwin
nix/modules/home
nix/modules/home/migration
nix/modules/shared
```

- [ ] **Step 3: Commit the empty skeleton**

```bash
git add .gitignore nix/modules/shared/.gitkeep
git commit -m "🏗️ chore(nix): bootstrap nix/ directory structure"
```

---

## Session 2 — Flake skeleton (Tasks 4-9)

### Task 4: Write `nix/flake.nix`

**Files:**
- Create: `nix/flake.nix`

- [ ] **Step 1: Write the flake**

Create `nix/flake.nix`:

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
        userModule = ./users/nico.nix;
      };
    };

    formatter.aarch64-darwin =
      inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
  };
}
```

- [ ] **Step 2: Verify the flake parses (will fail eval since modules missing — that's OK)**

```bash
nix flake metadata ./nix 2>&1 | head -20
```
Expected: prints input list + commit SHAs after fetching. **No** Nix syntax errors.

If you see a syntax error: fix the file, re-run.

If you see "path '/path/to/nix/lib/mkDarwin.nix' does not exist" — that's expected, we write it next.

- [ ] **Step 3: No commit yet** (incomplete; commit after Task 9 validates the whole skeleton)

---

### Task 5: Write `nix/lib/mkDarwin.nix`

**Files:**
- Create: `nix/lib/mkDarwin.nix`

- [ ] **Step 1: Write the host constructor**

Create `nix/lib/mkDarwin.nix`:

```nix
inputs: { hostname, username, userModule }:
  inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs hostname username; };
    modules = [
      ../hosts/${hostname}.nix
      ../modules/darwin/touchid.nix
      ../modules/darwin/system-defaults.nix
      # NOTE: modules/darwin/homebrew.nix is intentionally absent — added by Spec #2.

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

- [ ] **Step 2: No commit yet**

Continue to Task 6.

---

### Task 6: Write `nix/users/nico.nix` + tier stubs

**Files:**
- Create: `nix/users/nico.nix`
- Create: `nix/modules/home/symlinks.nix`
- Create: `nix/modules/home/migration/cli-tier.nix`
- Create: `nix/modules/home/migration/editors-tier.nix`
- Create: `nix/modules/home/migration/shell-tier.nix`

- [ ] **Step 1: Write `nix/users/nico.nix`**

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

- [ ] **Step 2: Write `nix/modules/home/symlinks.nix`**

```nix
{ config, ... }: {
  # Empty buffer. Spec #3 populates this with entries like:
  #   xdg.configFile."nvim".source =
  #     config.lib.file.mkOutOfStoreSymlink
  #       "${config.home.homeDirectory}/.dotfiles/nvim/.config/nvim";
}
```

- [ ] **Step 3: Write `nix/modules/home/migration/cli-tier.nix`**

```nix
{ pkgs, ... }: {
  # Empty. Spec #2 adds packages here:
  #   home.packages = with pkgs; [ direnv starship ... ];
}
```

- [ ] **Step 4: Write `nix/modules/home/migration/editors-tier.nix`**

```nix
{ pkgs, ... }: {
  # Empty. Spec #3 adds editor configs here (programs.* or mkOutOfStoreSymlink).
}
```

- [ ] **Step 5: Write `nix/modules/home/migration/shell-tier.nix`**

```nix
{ pkgs, ... }: {
  # Empty. Spec #3 adds shell config here.
}
```

- [ ] **Step 6: No commit yet**

Continue to Task 7.

---

### Task 7: Write Darwin modules

**Files:**
- Create: `nix/modules/darwin/touchid.nix`
- Create: `nix/modules/darwin/system-defaults.nix`

- [ ] **Step 1: Write `nix/modules/darwin/touchid.nix`**

```nix
{ ... }: {
  # Enable Touch ID for `sudo` via /etc/pam.d/sudo_local.
  # nix-darwin writes the sudo_local file, which macOS Sequoia+ reads in
  # addition to /etc/pam.d/sudo (preserves Touch ID across macOS updates).
  security.pam.services.sudo_local.touchIdAuth = true;
}
```

- [ ] **Step 2: Write `nix/modules/darwin/system-defaults.nix`**

```nix
{ ... }: {
  # Proof-of-pipeline only. Spec #3 migrates the full _macOS/settings.sh.
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
}
```

- [ ] **Step 3: No commit yet**

Continue to Task 8.

---

### Task 8: Write host files

**Files:**
- Create: `nix/hosts/pikachu.nix`
- Create: `nix/hosts/vm-test.nix`

- [ ] **Step 1: Write `nix/hosts/pikachu.nix`**

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

- [ ] **Step 2: Write `nix/hosts/vm-test.nix`**

```nix
{ hostname, username, ... }: {
  networking.hostName = hostname;
  system.primaryUser  = username;
  system.stateVersion = 7;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
}
```

- [ ] **Step 3: No commit yet**

Continue to Task 9.

---

### Task 9: Validate skeleton evaluates + commit

**Files:** none (validation only)

- [ ] **Step 1: Run `nix flake show`**

```bash
nix flake show ./nix 2>&1 | tee /tmp/nix-flake-show.log
```

Expected output (similar to):
```
git+file:///Users/nico/.dotfiles?dir=nix
├───darwinConfigurations
│   ├───pikachu: NixOS configuration
│   └───vm-test: NixOS configuration
└───formatter
    └───aarch64-darwin: package 'nixfmt-...'
```

If you see "error: ... module imports a path that does not exist": check that ALL file paths from Tasks 4-8 actually exist. Re-create any missing file.

If you see "error: attribute 'X' missing": typo in `flake.nix` outputs. Compare against Task 4.

- [ ] **Step 2: Build the `pikachu` host (does not apply)**

```bash
nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- build --flake ./nix#pikachu
```

Expected: builds successfully, creates `./result` symlink. May take 1-2 minutes the first time (downloads nix-darwin closure).

If error: read it carefully. Common issues:
- `attribute 'sudo_local' missing` → nix-darwin too old; check `nix-darwin/nix-darwin/master` is pinned (Task 4)
- `nix-command and flakes are required` → Determinate should have enabled these. Run `cat /etc/nix/nix.conf | grep experimental` to verify.

- [ ] **Step 3: Build the `vm-test` host**

```bash
nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- build --flake ./nix#vm-test
```

Expected: same as Step 2, builds successfully.

- [ ] **Step 4: Format the new Nix files**

```bash
nix fmt ./nix
git diff nix/
```

`nix fmt` invokes the formatter exposed in `flake.nix` (nixfmt-rfc-style). Expected: minor whitespace/indent fixes. Review the diff to make sure it looks reasonable.

- [ ] **Step 5: Commit the skeleton**

```bash
git add nix/
git commit -m "$(cat <<'EOF'
✨ feat(nix): scaffold nix-darwin + home-manager flake skeleton

Foundation per docs/superpowers/specs/2026-05-27-nix-darwin-foundation-design.md.
Adds:
- flake.nix with nix-darwin + home-manager inputs (no nix-homebrew yet)
- lib/mkDarwin.nix host constructor (userModule param so vm-test reuses
  users/nico.nix with admin username)
- hosts/{pikachu,vm-test}.nix with nix.enable=false (Determinate owns nix.conf)
- modules/darwin/{touchid,system-defaults}.nix (Touch ID + Dark Mode proof)
- modules/home/{symlinks,migration/{cli,editors,shell}-tier}.nix (empty stubs)
- formatter.aarch64-darwin = nixfmt-rfc-style

Stow + Brewfile + Homebrew fully untouched. nix-homebrew + homebrew = {}
deferred to Spec #2.

Verified: `nix flake show` lists both hosts; `darwin-rebuild build` succeeds
for both pikachu and vm-test.

SESSION HANDOFF — Nix-Darwin Foundation
─────────────────────────────────────────
Last action:          Skeleton committed, both hosts BUILD (not switched yet)
darwin-rebuild state: build only — no switch attempted
Current generation:   n/a
Installer mode:       Determinate Systems (--determinate flag)
Homebrew prefix:      /opt/homebrew (untouched)
Next command:         Task 10 — add just/Makefile nix targets
EOF
)"
```

---

## Session 3 — Tooling (Tasks 10-12)

### Task 10: Add `just` + `Makefile` nix targets (sync rule)

**Files:**
- Modify: `justfile`
- Modify: `Makefile`

- [ ] **Step 1: Append nix targets to `justfile`**

Open `justfile` and append at the end:

```just
# ── Nix-Darwin ──────────────────────────────────────────

# Build the Nix-Darwin config (no apply) — sanity check
nix-build:
    darwin-rebuild build --flake {{ DOTFILES }}/nix#$(hostname -s)

# Apply the Nix-Darwin config (activates Touch ID, Dark Mode, etc.)
nix-switch:
    darwin-rebuild switch --flake {{ DOTFILES }}/nix#$(hostname -s)

# Roll back to the previous Nix-Darwin generation
nix-rollback:
    darwin-rebuild --rollback

# List Nix-Darwin generations
nix-list:
    darwin-rebuild --list-generations

# Format all .nix files with nixfmt-rfc-style
nix-fmt:
    nix fmt {{ DOTFILES }}/nix

# Run the Nix Foundation VM test (Tart)
test-nix-foundation:
    bash {{ DOTFILES }}/_test/vm-test-nix-foundation.sh
```

- [ ] **Step 2: Append matching targets to `Makefile`**

Open `Makefile` and append at the end (before any final newline-only line):

```make
# ── Nix-Darwin ──────────────────────────────────────────

nix-build: ## Build the Nix-Darwin config (no apply)
	darwin-rebuild build --flake $(DOTFILES)/nix#$$(hostname -s)

nix-switch: ## Apply the Nix-Darwin config
	darwin-rebuild switch --flake $(DOTFILES)/nix#$$(hostname -s)

nix-rollback: ## Roll back to the previous Nix-Darwin generation
	darwin-rebuild --rollback

nix-list: ## List Nix-Darwin generations
	darwin-rebuild --list-generations

nix-fmt: ## Format all .nix files
	nix fmt $(DOTFILES)/nix

test-nix-foundation: ## Run the Nix Foundation VM test (Tart)
	bash $(DOTFILES)/_test/vm-test-nix-foundation.sh
```

Also update the `.PHONY` declaration near the top of `Makefile` (search for it) to include the new targets:

```make
.PHONY: ... nix-build nix-switch nix-rollback nix-list nix-fmt test-nix-foundation
```

(Append space-separated to whatever's already there; don't replace.)

- [ ] **Step 3: Verify both list the new targets**

```bash
just --list | grep '^    nix-\|^    test-nix-foundation'
```
Expected: lists `nix-build`, `nix-switch`, `nix-rollback`, `nix-list`, `nix-fmt`, `test-nix-foundation`.

```bash
make help 2>&1 | grep -E 'nix-|test-nix-foundation'
```
Expected: same six targets shown with their `##` comments.

- [ ] **Step 4: Commit**

```bash
git add justfile Makefile
git commit -m "✨ feat(just,make): add nix-{build,switch,rollback,list,fmt} + test-nix-foundation"
```

---

### Task 11: Write VM test script

**Files:**
- Create: `_test/vm-test-nix-foundation.sh`

- [ ] **Step 1: Create the VM test script**

Create `_test/vm-test-nix-foundation.sh`:

```bash
#!/usr/bin/env bash
# Nix-Darwin Foundation VM test (headless).
#
# Spins up a Tart macOS VM, installs Determinate Nix, applies the
# `vm-test` darwinConfiguration, validates Touch ID PAM file + Dark Mode.
#
# Does NOT install Homebrew — Foundation doesn't depend on it.

set -euo pipefail

VM_NAME="nix-foundation-test"
TART_IMAGE="${TART_IMAGE:-ghcr.io/cirruslabs/macos-sequoia-base:latest}"
SSH_USER="${SSH_USER:-admin}"
SSH_PASS="${SSH_PASS:-admin}"
DOTFILES_HOST_PATH="${DOTFILES_HOST_PATH:-$HOME/.dotfiles}"

ssh_opts=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o LogLevel=ERROR
)

cleanup() {
    echo "==> Cleaning up VM..."
    tart stop "$VM_NAME" 2>/dev/null || true
    tart delete "$VM_NAME" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Pre-flight checks..."
command -v tart >/dev/null || { echo "tart not installed (brew install cirruslabs/cli/tart)"; exit 1; }
command -v sshpass >/dev/null || { echo "sshpass not installed (brew install sshpass)"; exit 1; }
[[ "$(uname -m)" == "arm64" ]] || { echo "Tart requires Apple Silicon"; exit 1; }

echo "==> Cloning Tart image (this may take a few minutes on first run)..."
tart clone "$TART_IMAGE" "$VM_NAME"

echo "==> Booting VM..."
tart run --no-graphics --dir="dotfiles:${DOTFILES_HOST_PATH}" "$VM_NAME" &
TART_PID=$!

echo "==> Waiting for VM SSH..."
VM_IP=""
for _ in $(seq 1 60); do
    VM_IP="$(tart ip "$VM_NAME" 2>/dev/null || true)"
    [[ -n "$VM_IP" ]] && break
    sleep 2
done
[[ -n "$VM_IP" ]] || { echo "VM never reported an IP"; exit 1; }
echo "    VM IP: $VM_IP"

# Wait for SSH to actually answer
for _ in $(seq 1 30); do
    sshpass -p "$SSH_PASS" ssh "${ssh_opts[@]}" "$SSH_USER@$VM_IP" true 2>/dev/null && break
    sleep 3
done

ssh_run() {
    sshpass -p "$SSH_PASS" ssh "${ssh_opts[@]}" "$SSH_USER@$VM_IP" "$@"
}

echo "==> Installing Determinate Nix in VM..."
ssh_run 'curl --proto "=https" --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --determinate --no-confirm'

echo "==> Running first darwin-rebuild switch..."
ssh_run '. /etc/zshrc; \
    nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- \
        switch --flake /Volumes/My\ Shared\ Files/dotfiles/nix#vm-test'

echo "==> Validating Foundation..."

# 1. Touch ID PAM file exists (headless-safe check)
ssh_run 'test -f /etc/pam.d/sudo_local && grep -q pam_tid /etc/pam.d/sudo_local' \
    && echo "    OK: Touch ID sudo_local file present" \
    || { echo "    FAIL: Touch ID sudo_local file missing or wrong"; exit 1; }

# 2. Dark Mode is set
ssh_run 'defaults read -g AppleInterfaceStyle 2>/dev/null' \
    | grep -q Dark \
    && echo "    OK: Dark Mode active" \
    || { echo "    FAIL: AppleInterfaceStyle is not Dark"; exit 1; }

# 3. Homebrew not installed (we promised not to touch it)
ssh_run 'command -v brew >/dev/null 2>&1' \
    && { echo "    FAIL: brew exists in VM — Foundation touched Homebrew"; exit 1; } \
    || echo "    OK: brew not installed (Foundation did NOT touch Homebrew)"

# 4. nix-darwin generation exists
ssh_run '. /etc/zshrc; darwin-rebuild --list-generations | tail -1' \
    && echo "    OK: nix-darwin generation listed"

# 5. nix fmt works
ssh_run '. /etc/zshrc; cd /Volumes/My\ Shared\ Files/dotfiles && nix fmt nix/flake.nix' \
    && echo "    OK: nix fmt runs"

echo ""
echo "==> All Foundation validations passed ✓"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x _test/vm-test-nix-foundation.sh
```

- [ ] **Step 3: Lint with shellcheck**

```bash
shellcheck _test/vm-test-nix-foundation.sh
```
Expected: clean (no warnings). Fix any reported issues.

- [ ] **Step 4: Commit (script only, before running)**

```bash
git add _test/vm-test-nix-foundation.sh
git commit -m "✨ feat(test): add headless Tart VM test for Nix Foundation"
```

---

### Task 12: Run VM test, fix issues, commit handoff

**Files:** none unless fixes needed

- [ ] **Step 1: Run the VM test**

```bash
just test-nix-foundation
# (or: make test-nix-foundation, or: bash _test/vm-test-nix-foundation.sh)
```

Expected: all 5 validation lines print "OK", final line "All Foundation validations passed ✓".

Expected duration: 5-15 minutes on first run (Tart image download + Nix install + nix-darwin closure).

- [ ] **Step 2: If failures occur — debug and fix**

Common failure modes:

| Failure | Fix |
|---------|-----|
| `tart not installed` | `brew install cirruslabs/cli/tart` (add to Brewfile if missing) |
| `sshpass not installed` | `brew install esolitos/ipa/sshpass` (already in brew/Brewfile.10-cli-core probably) |
| Image clone slow | First-time only; subsequent runs are cached |
| SSH never connects | Tart base image changed — try `tart list --source remote` for current image tag |
| Touch ID check FAILS | Re-read Task 7 + 8 — confirm `security.pam.services.sudo_local.touchIdAuth = true` actually wrote to `/etc/pam.d/sudo_local`; check `system.primaryUser` is set in host |
| Dark Mode FAILS | Check Task 7 — `AppleInterfaceStyle = "Dark"` is verbatim |
| Homebrew check FAILS (brew exists) | Foundation should NOT install brew. Investigate which task introduced it. |
| `nix run ...darwin-rebuild` errors out | Read error carefully; may be transient network — retry |

Re-run `just test-nix-foundation` after each fix.

- [ ] **Step 3: Commit the green VM test (handoff message)**

Once green, write a commit that records the SESSION HANDOFF:

```bash
git commit --allow-empty -m "$(cat <<'EOF'
✅ test(nix): VM foundation test green

SESSION HANDOFF — Nix-Darwin Foundation
─────────────────────────────────────────
Last action:          VM test PASSED — all 5 validations green
darwin-rebuild state: switched on vm-test VM (now destroyed); NOT on pikachu yet
Current generation:   n/a on pikachu
Installer mode:       Determinate Systems (--determinate)
Homebrew prefix:      /opt/homebrew (untouched)
Next command:         Task 13 — apply locally on pikachu
EOF
)"
```

---

## Session 4 — Local apply + smoke (Tasks 13-15)

### Task 13: Local apply on `pikachu`

**Files:** none (system state only)

- [ ] **Step 1: Confirm a clean baseline**

Before applying, snapshot the current state for comparison:

```bash
brew list | sort > /tmp/brew-pre-foundation.txt
ls -la $HOME/.config | sort > /tmp/config-pre-foundation.txt
echo "$(brew list | wc -l) brews installed before Foundation"
```

- [ ] **Step 2: Build (sanity check, does not apply)**

```bash
just nix-build
# Equivalent: darwin-rebuild build --flake ./nix#pikachu
```
Expected: builds, produces `./result` symlink. No errors.

- [ ] **Step 3: Switch (applies)**

```bash
just nix-switch
# Equivalent: darwin-rebuild switch --flake ./nix#pikachu
```

Expected: prints activation steps, exits 0. Touch ID prompt may appear (sudo for `/etc/pam.d/sudo_local` write — that's fine, type your password if Touch ID isn't available yet).

If error: do NOT panic. Read the error. The most common at first switch:
- "user not yet in trusted-users" — Determinate handled this; if not, `sudo sh -c 'echo "trusted-users = root nico" >> /etc/nix/nix.conf'` and retry
- "AppleInterfaceStyle write failed" — benign warning, often retries succeed
- "PAM activation failed" — check that `system.primaryUser` matches the actual macOS username

- [ ] **Step 4: Verify generation listed**

```bash
just nix-list
```
Expected: shows at least one generation with a timestamp.

---

### Task 14: Post-apply validation (Stow + Brewfile + daily tools)

**Files:** none (validation only)

- [ ] **Step 1: Validate Foundation activations**

```bash
test -f /etc/pam.d/sudo_local && grep -q pam_tid /etc/pam.d/sudo_local \
    && echo "OK: Touch ID sudo_local" \
    || echo "FAIL: Touch ID sudo_local"

defaults read -g AppleInterfaceStyle
# Expected: Dark
```

- [ ] **Step 2: Test Touch ID interactively**

In a fresh terminal:
```bash
sudo -k && sudo true
```
Expected: Touch ID prompt (not password). If you see a password prompt, the Touch ID activation didn't take effect — re-check `/etc/pam.d/sudo_local` content.

- [ ] **Step 3: Verify Stow is undisturbed**

```bash
cd ~/.dotfiles
stow --no --verbose */ 2>&1 | grep -v 'BUG\|WARNING' | head -10
# Expected: lots of "LINK already exists" — meaning all symlinks are still in place
```

If you see "would link X" — that means a symlink got removed. Re-stow: `stow --restow */`.

- [ ] **Step 4: Verify Homebrew is undisturbed**

```bash
brew list | sort > /tmp/brew-post-foundation.txt
diff /tmp/brew-pre-foundation.txt /tmp/brew-post-foundation.txt
# Expected: empty diff (no brews added or removed)
```

If diff is non-empty: investigate. Foundation should NOT have changed `brew list`. If you see anything missing, restore via `brew bundle install`.

- [ ] **Step 5: Quick daily-tool smoke**

```bash
# Each of these should work as before:
nvim --headless +'echo "ok"' +qa
zsh -c 'echo $SHELL'
git status
lazygit --version
k9s version --short 2>&1 | head -3
```
All should run without errors.

- [ ] **Step 6: Commit a handoff marker**

Capture dynamic values into shell variables first so the commit message contains the literal numbers (not unevaluated `$(...)` strings):

```bash
GEN=$(darwin-rebuild --list-generations | tail -1)
BREW_COUNT=$(brew list | wc -l | tr -d ' ')

git commit --allow-empty -m "$(cat <<EOF
✅ chore(nix): pikachu switched to Nix-Darwin Foundation

SESSION HANDOFF — Nix-Darwin Foundation
─────────────────────────────────────────
Last action:          darwin-rebuild switch applied on pikachu
darwin-rebuild state: switched
Current generation:   ${GEN}
Installer mode:       Determinate Systems (--determinate)
Homebrew prefix:      /opt/homebrew (untouched, ${BREW_COUNT} brews)
Stow:                 all symlinks intact (stow --no --verbose validated)
Next command:         24-48h smoke test, then Task 15 to close out Foundation
EOF
)"
```

Note the un-quoted `<<EOF` (NOT `<<'EOF'`) — that's required for variable expansion of `${GEN}` and `${BREW_COUNT}`.

---

### Task 15: 24-48h smoke + close-out

**Files:**
- Modify: `_planning/TODO.md`

- [ ] **Step 1: Use the machine normally for 24-48 hours**

Watch for:
- `find $HOME -maxdepth 3 -name "*.backup" -newer ~/.dotfiles/nix/flake.nix 2>/dev/null` — any `.backup` files that HM created? Investigate.
- Touch ID prompts continuing to work
- Brew-managed apps continuing to launch
- Zsh starting cleanly in new terminals
- No unexpected behavior

If anything breaks during smoke window: `just nix-rollback`, debug, retry.

- [ ] **Step 2: Tick off Foundation checkboxes in `_planning/TODO.md`**

Edit `_planning/TODO.md` Spec 1 section: change all `- [ ]` to `- [x]` for items completed.

- [ ] **Step 3: Final commit**

```bash
git add _planning/TODO.md
git commit -m "$(cat <<'EOF'
✅ feat(nix): Nix-Darwin Foundation complete (Spec #1 of 3 done)

24-48h smoke test stable on pikachu. Touch ID + Dark Mode declarative via
nix-darwin. Stow + Brewfile + Homebrew remain authoritative for their domains.

Next: Spec #2 (Package Migration) brainstorming.

SESSION HANDOFF — Foundation CLOSED
─────────────────────────────────────────
Spec 1 status:  COMPLETE
Spec 2 status:  PLANNED (Package Migration — start brainstorming)
Spec 3 status:  PLANNED (Home Manager / Config Migration)
EOF
)"
```

- [ ] **Step 4: Push**

```bash
git push
```

---

## Acceptance Criteria (per design spec)

After Task 15:

- [x] `nix/` directory exists with the documented layout
- [x] Determinate Nix installed on `pikachu`
- [x] `nix flake show ./nix` lists `pikachu` and `vm-test` darwinConfigurations
- [x] `darwin-rebuild build` succeeds for both hosts
- [x] VM-test green
- [x] Local switch succeeded on `pikachu`
- [x] Touch ID + Dark Mode active via Nix
- [x] Stow + Brewfile + Homebrew completely undisturbed
- [x] 24-48h smoke stable
- [x] `_planning/TODO.md` Foundation section ticked off
- [x] Commit history contains SESSION HANDOFF markers for each session

---

## Rollback Reference

Quick rollback commands (also in the design spec, repeated here for the agentic worker):

```bash
# Rollback to previous Nix-Darwin generation:
just nix-rollback
# (= darwin-rebuild --rollback)

# Re-stow everything if symlinks disturbed (shouldn't happen, but…):
cd ~/.dotfiles && stow --restow */

# Restore brews if anything's missing (also shouldn't happen):
brew bundle install --file=~/.Brewfile

# Nuclear: remove Nix entirely:
/nix/nix-installer uninstall
# Then remove nix/ from repo, restart shell.
```

---

## Related

- Design spec: [`docs/superpowers/specs/2026-05-27-nix-darwin-foundation-design.md`](../specs/2026-05-27-nix-darwin-foundation-design.md)
- Planning: [`_planning/ideas/roadmap-2026.md`](../../../_planning/ideas/roadmap-2026.md) (Phase 3)
- Parallel feature plan: [`_planning/ideas/unified-formatter.md`](../../../_planning/ideas/unified-formatter.md)
- TODO tracker: [`_planning/TODO.md`](../../../_planning/TODO.md)

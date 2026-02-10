# Dotfiles Roadmap 2026

> Strategische Weiterentwicklung: Cross-Platform, Containerisierung, deklaratives Management, Dokumentation
>
> **Status:** Planning (Research abgeschlossen, bereit zur Umsetzung)
> **Last Updated:** 2026-02-10

## Goal

Die Dotfiles von einem macOS-zentrierten Stow-Setup zu einer cross-platform, deklarativen, containerisierten Entwicklungsumgebung weiterentwickeln — reproduzierbar, testbar, dokumentiert.

## Phasen-Übersicht

```
Phase 0: Bestehender Backlog (Vorarbeiten)
Phase 1: Install Script Refactoring + macOS Settings Cleanup
Phase 2: Docker Images + CI/CD
Phase 3: Nix-Darwin + Home Manager Migration
Phase 4: Dokumentation & Media
```

---

## Phase 0: Bestehender Backlog (Vorarbeiten)

> Unabhängige Items die das Setup stabilisieren. Reihenfolge nach Priorität.

### 0.1 Secret Management [PRIORITY: DO NOW]

**Problem:** `~/.secrets` enthält 7+ API-Keys als Plaintext (OpenAI, Anthropic, Gemini, OpenRouter, Context7, Exa, GitHub). Wird in `.zshrc` Zeile 10 gesourced. Sicherheitsrisiko.

**Empfehlung: 1Password CLI (`op`)** — bereits installiert (`1password-cli` im Brewfile), Touch ID Integration, Cross-Device Sync, CI/CD Support.

**Status: IMPLEMENTIERT** (Commit `1819de42`, `04cd9849`)

**Layered Approach:**
- **Primär:** 1Password CLI (`op inject`) — Secrets nur im RAM, kein Disk-Cache
- **Sekundär (ab Phase 3):** SOPS + age für nix-darwin (`sops-nix` hat `darwinModules.sops`)
- **Legacy-Fallback:** Plaintext `~/.secrets` während Migrationsperiode

**Was umgesetzt wurde:**
1. `zsh/.secrets.tpl` mit `op://Employee/...` Referenzen — **committed** (enthält nur Referenzen, keine Secrets)
2. `.zshrc` Secret-Loading: `eval "$(op inject -i ~/.secrets.tpl)"` — Secrets bleiben nur im RAM
3. `git/.gitconfig` hardcoded `[user]`/`[gpg]` entfernt — kommt jetzt aus secrets.tpl
4. `.secrets.example` mit 1Password Setup-Anleitung aktualisiert
5. 1Password Items erstellt: Git Config, OpenAI/Anthropic/Google/OpenRouter/Context7 API Keys
6. Touch ID Frequenz: op's interne Session (~30 min) reduziert Prompts
7. Für Docker: `op run --env-file=.env.tpl -- docker compose up`
8. Für CI/CD: `1password/load-secrets-action` oder GitHub Secrets direkt

**Zukunft: Bitwarden/Vaultwarden Migration**
> Geplanter Wechsel von 1Password zu Bitwarden/Vaultwarden steht langfristig an (nicht in eigener Hand, Timing offen). Bei der Implementierung darauf achten, dass der Secret-Loading-Code backend-agnostisch bleibt — der SOPS+age Layer funktioniert unabhängig vom Password Manager. `op inject` Aufrufe auf wenige Stellen isolieren, damit ein späterer Wechsel zu `bw`/`bws` minimal-invasiv ist.

**Aufwand:** 1-2 Stunden

### 0.2 Obsidian Second Brain [PRIORITY: DO IN PHASE 0]

**Status:** 90% fertig. PARA-Struktur, 6 Templates, Catppuccin Theme, 6 Plugin-Configs vorhanden.

**Verbleibend:**
1. `_install/obsidian.sh` erstellen (kopiert Config nach iCloud Vault)
2. `backup-obsidian` Zsh-Funktion (rsync Config zurück ins Repo)
3. In `install.sh` verdrahten (Prompt existiert bereits)
4. iCloud Sync testen

**Aufwand:** 1-2 Stunden

### 0.3 CRD Wizard Integration [PRIORITY: DO IN PHASE 0]

**Status:** krew ist installiert, k9s plugins.yaml hat 15+ Plugins.

**Umsetzung:**
1. `kubectl krew install crd-wizard`
2. 3 Plugin-Einträge in k9s `plugins.yaml` (TUI, TUI+AI, Web UI)
3. **Wichtig:** AI Mode nutzt `--ai-provider gemini` (nicht OpenRouter — wird nicht unterstützt)

**Aufwand:** 15-30 Minuten

### 0.4 Skills CLI Integration [PRIORITY: DEFER]

**Begründung:** Ecosystem noch unreif (`@dhruvwill/skills-cli` = 6 Stars, 3 Wochen alt). Offizielle `npx skills` hat 45 offene PRs. Stow kann SKILL.md Dateien nativ verwalten. Kein Pain Point. Revisit Q2/Q3 2026.

---

## Phase 1: Install Script Refactoring + macOS Settings

### 1.1 Install Script — Makefile + bootstrap.sh

**Problem:** Aktuelles `install.sh` nutzt `read -p` Prompts. Nicht automatisierbar für Docker, CI, VMs.

**Empfehlung: Makefile** (pre-installed, dependency graph, GNU Stow fit) + `bootstrap.sh` (curl-pipeable).

**Architektur:**
```
~/.dotfiles/
  Makefile              # Primary entry point
  bootstrap.sh          # curl-pipeable: git clone + make all
  _install/             # Per-tool Skripte für komplexe Installs
```

**Makefile-Targets:**
```makefile
make all               # Full setup: install + link
make install           # Homebrew + Packages
make link              # GNU Stow Symlinks (alle Packages)
make unlink            # Symlinks entfernen
make relink            # Idempotent re-link (stow --restow)
make update            # brew update + upgrade + cleanup
make check             # Validiere installierte Tools
make macos             # macOS System Settings anwenden
make clean             # Symlinks + Caches entfernen

# Per-Package Targets:
make zsh / make nvim / make git / make tmux / make ghostty / ...

# Testing (Phase 2):
make test              # lint + stow dry-run
make test-macos        # Tart macOS VM Test
make test-linux        # Lima Linux VM Test
make test-docker       # Docker Container Test
make lint              # ShellCheck + yamllint + TOML Validation
```

**Package-Listen:**
- `HOME_PACKAGES` (zsh, git) → `stow -t "$HOME"`
- `CONFIG_PACKAGES` (nvim, ghostty, tmux, lazygit, k9s, zed, opencode) → `stow -t "$XDG_CONFIG_HOME"`

**Key Patterns (aus Research):**
- **Platform-Detection:** `$(shell uname -s)` + `$(shell uname -m)`
- **Idempotenz:** `stow --restow`, `command -v` Guards, `brew bundle` (nativ idempotent)
- **CI-Kompatibilität:** `NONINTERACTIVE=1` (Homebrew), `CI=true` zum Überspringen interaktiver Steps
- **Dependency-Chain:** `brew → stow → link`, per-package `ensure-stow` Guard
- **Help System:** `make help` via `grep -E '^[a-zA-Z_-]+:.*?## .*$$'` Pattern

**bootstrap.sh:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/snics/dotfiles/master/bootstrap.sh)"
```
Installiert Xcode CLT, klont Repo, führt `make all` aus.

**Referenz-Repos:** webpro/dotfiles (Makefile + Stow), holman/dotfiles (topic-based), sagebind/dotfiles (.no-stow-folding Pattern)

**Aufwand:** 1-2 Sessions

### 1.2 macOS Settings Cleanup

**Problem:** `macOS/settings.sh` ist eine Kopie von Mathias Bynens' `.macos` (~2014). Viele Settings sind auf Sequoia 15.x kaputt oder veraltet.

**Audit-Ergebnis (verifiziert via `defaults read` auf Live-System):**

#### ENTFERNEN (15 Items):
- Dashboard (seit Catalina entfernt)
- `launchctl unload` Notification Center (SIP blockiert)
- `tmutil disablelocal` (seit Sierra entfernt)
- Safari Java/Plugins (`WebKitJavaEnabled` etc., seit Safari 12 weg)
- iTunes/rcd Media Keys (`launchctl load rcd`, iTunes → Music)
- iCal Debug Menu (iCal → Calendar, BundleID geändert)
- Address Book Debug Menu (→ Contacts, Key existiert nicht mehr)
- Terminal.app Theme AppleScript (wir nutzen Ghostty)
- iTerm2 Theme Installation + Solarized (wir nutzen Ghostty)
- Opera Settings (wir nutzen Chrome/Arc)
- Tweetbot im Kill-List (discontinued)
- GPGMail Settings (nicht installiert)
- Dashboard Hot Corner Value 7 (aus Doku entfernen)

#### AKTUALISIEREN (15 Items):
- "System Preferences" → "System Settings" (quit AppleScript)
- Computer Name konfigurierbar: `COMPUTER_NAME="${COMPUTER_NAME:-Nicos MacBook}"`
- `com.apple.universalaccess`: FDA-Warnung als Kommentar
- `systemsetup` Commands: `2>/dev/null` für Error:-99
- Safari: Sandbox-Container Hinweis
- `spctl --master-disable`: Sequoia-spezifische Anleitung hinzufügen
- Font Smoothing Kommentar (kein Subpixel seit Mojave)
- `ScheduleFrequency`: Hinweis dass evtl. ignoriert
- Kill-List: "Address Book" → "Contacts", "iCal" entfernen
- `expose-group-by-app`: Monitoring-Hinweis (evtl. renamed)
- Bluetooth Bitpool: Relevanz-Hinweis für moderne Codecs
- Screensaver Password: Hinweis auf Lock Screen Migration
- Safari "Top Sites" → Start Page Kommentar
- macOS Version Guard am Anfang (`sw_vers -productVersion`)

#### NEU HINZUFÜGEN (9 Kategorien):
- **Window Manager / Stage Manager** (`com.apple.WindowManager`): Stage Manager deaktivieren, Click-to-show-Desktop, Tiled Window Margins
- **Control Center** (`com.apple.controlcenter`): Bluetooth, Battery %, NowPlaying
- **Apple Intelligence Opt-out** (`com.apple.CloudSubscriptionFeatures.optIn`)
- **Clock Settings** (`com.apple.menuextra.clock`): Seconds, Date, Day of Week
- **Three-finger Drag** (Accessibility)
- **Dark Mode** (`AppleInterfaceStyle`)
- **Reduce Motion** (`com.apple.Accessibility`)
- **Fn Key Behavior** (`com.apple.HIToolbox`)
- **Moderne Safari Developer Keys**

#### NEEDS TESTING (10 Items):
- `NSTextShowsControlCharacters`, `AdminHostInfo`, `.CFUserTextEncoding`
- Safari AutoFill (Sandbox + Passwords App)
- Help Viewer `DevMode`, AirDrop over Ethernet, Messages `SOInputLineSettings`
- Spotlight `orderedItems` (AI-driven Verhalten)
- `lsregister -kill`, `lidwake 0` (Absicht prüfen — 0 = kein Aufwachen bei Lid-Open)

#### Best Practices für Rewrite:
1. macOS Version Guard am Anfang
2. Full Disk Access Warnung als Kommentar
3. Computer Name via Environment Variable
4. `2>/dev/null` auf allen `systemsetup` Commands
5. Aufteilen: `settings.sh` (System), `dock.sh` (Dock, existiert bereits), `apps.sh` (App-spezifisch)
6. `verify_default()` Helper-Funktion für Validierung

**Aufwand:** 1 Session

---

## Phase 2: Docker Images + CI/CD

### 2.1 Image-Architektur: 3-Layer Strategy

**Empfehlung: 3 Images, KEIN Desktop-Variant**

```
alpine:3.21 (8 MB)
    │
    ▼
snics/nvim (400-600 MB)      ← NeoVim + LSPs + Treesitter
    │
    ▼
snics/devenv (800 MB-1.2 GB) ← + Zsh + tmux + TUI Tools
    │
    ▼
snics/devenv-web (+5 MB)     ← + ttyd Binary
```

**Warum Alpine 3.21 statt Wolfi/Chainguard:**
Alpine hat breiteres Package-Ecosystem für 50+ Dev-Tools. Wolfi wäre besser für Produktions-Services, nicht für Dev-Toolboxen.

**Warum KEIN `snics/devenv-desktop` (KasmVNC):**
- +694 MB für `linuxserver/webtop:alpine-openbox` allein
- Kein TUI-Tool braucht einen Window Manager
- ttyd rendert NeoVim, tmux, lazygit, k9s perfekt im Browser
- Revisit nur wenn ein konkreter GUI Use Case entsteht

**Warum KEIN code-server:**
- Andere Zielgruppe und Workflow
- VS Code NeoVim Extension überträgt nur Modal Editing, nicht Plugins
- Separater Config-Aufwand ohne Benefit

### 2.2 `snics/nvim` — Minimal NeoVim Container

**Inhalt:**
- Alpine 3.21 + NeoVim + gcc/g++ (Treesitter Compilation)
- Node.js + Python + Go (Mason LSP Runtime)
- ripgrep, fd (Plugin Dependencies)
- lazy.nvim Plugins (pre-installed via `Lazy! sync`)
- Treesitter Parsers (pre-compiled via `TSInstallSync all`)
- Mason LSP Servers (pre-installed via `MasonToolsInstallSync`)

**Non-root User:** `dev` (UID 1000)
**Entrypoint:** `nvim`

### 2.3 `snics/devenv` — Full CLI + TUI

**Zusätzlich zu snics/nvim:**
- Zsh + Zimfw + Starship + fzf + fzf-tab + Atuin
- tmux + Catppuccin Theme + TPM Plugins
- bat, eza, ripgrep, fd, jq, yq, zoxide, delta
- lazygit, k9s, lazydocker, btop
- Alle conf.d/ Dateien, Aliases, Functions

**GitHub-Release Downloads (multi-arch `TARGETARCH` Pattern):**
lazygit, k9s, lazydocker, starship, zoxide — jeweils mit `amd64/arm64` Mapping

**Wichtig:** tmux.conf hardcoded `/opt/homebrew/bin/zsh` → `sed -i 's|/opt/homebrew/bin/zsh|/bin/zsh|g'` im Dockerfile

**Entrypoint:** `/bin/zsh`

### 2.4 `snics/devenv-web` — Browser-Zugang via ttyd

**Nur eine Ergänzung über devenv:**
```dockerfile
FROM snics/devenv:latest
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/v1.7.7/ttyd.${ARCH}" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd
EXPOSE 7681
ENTRYPOINT ["ttyd", "-W", "-p", "7681", "-t", "titleFixed=snics/devenv-web"]
CMD ["tmux", "new-session", "-A", "-s", "main"]
```

**Features:** Writable Terminal, tmux Session Sharing (mehrere Tabs = selbe Session), Font/Theme konfigurierbar via `-t` Flags, Basic Auth via `-c user:password`

**Usage:**
```bash
docker run -d -p 7681:7681 -v $(pwd):/workspace snics/devenv-web
open http://localhost:7681
```

### 2.5 Multi-Arch Support

Alle Komponenten unterstützen `linux/amd64` + `linux/arm64`:
- Alpine Packages: alle verfügbar
- GitHub-Release Binaries: lazygit, k9s, starship, zoxide, ttyd — alle bieten ARM64
- Mason LSP Servers: npm-basiert (arch-agnostic) + Go/Rust (ARM64 Binaries vorhanden)
- Treesitter: compiliert zur Build-Zeit via `gcc`

Build: `docker buildx build --platform linux/amd64,linux/arm64 --push`

### 2.6 CI/CD — GitHub Actions

**Registry:** Docker Hub (`snics/nvim`, `snics/devenv`, `snics/devenv-web`)

**Tags:** `latest`, `sha-<short>`, `YYYY-MM-DD`

**Workflow: `.github/workflows/smoke.yml`**

| Job | Runner | Trigger | Was wird getestet |
|-----|--------|---------|-------------------|
| `lint` | ubuntu-latest | Push + PR | ShellCheck, yamllint, TOML Validation |
| `test-macos` | macos-latest | Push + PR | Stow dry-run auf echtem macOS M1 |
| `test-linux` | ubuntu-latest | Push + PR | Docker-basiert (Ubuntu + Fedora Matrix) |
| `test-lima` | ubuntu-latest | Weekly + Manual | Lima VM (vollständiger Install-Test) |

**Caching:** Homebrew Downloads + API (`actions/cache` mit `Brewfile` Hash)

**Hinweis:** Tart kann NICHT in GitHub Actions laufen (braucht Apple Silicon + Virtualization.framework). Für CI nutzen wir `macos-latest` Runner direkt. Tart bleibt ein lokales Test-Tool.

### 2.7 Lokale Test-Targets

```
make test              # lint + stow dry-run (lokal, 7 Sekunden)
make test-docker       # Docker Ubuntu + Fedora (30 Sekunden)
make test-macos        # Tart macOS VM (5-10 Minuten, Apple Silicon)
make test-linux        # Lima Ubuntu + Fedora VM (3-5 Minuten)
make vm-clean          # Alle Test-VMs aufräumen
```

**Test-Skripte:**
- `_test/validate-symlinks.sh` — prüft alle Stow Symlinks
- `_test/validate-configs.sh` — TOML/JSON Syntax-Check
- `_test/validate-shell.sh` — Zsh Sourcing + Alias/Function Smoke Test

### 2.8 Dev Container Spec

```
.devcontainer/
  devcontainer.json     # Für Codespaces/DevPod/Coder
```

Referenziert `docker/Dockerfile.devenv`.

---

## Phase 3: Nix-Darwin + Home Manager Migration

### 3.0 Strategie: mkOutOfStoreSymlink + Homebrew NeoVim

**Kernentscheidung:** NeoVim NICHT via Nix installieren. Bei Homebrew lassen.

**Begründung (aus Research):**
- NeoVim 0.10.3 friert auf ARM Macs ein via nixpkgs-unstable
- Treesitter braucht Nix's GCC, scheitert an `/nix/store` Read-Only
- Mason LSP Servers erwarten System-Pfade
- lpeg Library Linking-Probleme auf Darwin
- lazy.nvim hat offiziell keinen Nix-Support

**Stattdessen:** `mkOutOfStoreSymlink` für NeoVim Config (bleibt im Git-Repo, mutable, lazy.nvim-kompatibel). NeoVim Binary kommt weiterhin aus Homebrew.

**Log-Mitigation:**
```nix
home.sessionVariables.NVIM_LOG_FILE = "${config.home.homeDirectory}/.cache/nvim/log";
```
Plus launchd-basierte Log-Rotation und `vim.o.verbose = 0` als Defense in Depth.

**Real-World Referenzen:**
- Parth/dotfiles — sauberstes mkOutOfStoreSymlink Beispiel
- ryan4yin/nix-config — bestes Mason + Nix Koexistenz-Muster
- dustinlyons/nixos-config — Beginner-freundlicher macOS Starter

### 3.1 Test-Setup: VM-basiertes Testing

**Vor** der Migration brauchen wir reproduzierbare Test-Environments:

| Tool | Zweck | Plattform |
|------|-------|-----------|
| **Tart** | macOS VMs (Virtualization.framework) | Lokal, Apple Silicon |
| **Lima** | Linux VMs (Virtualization.framework) | Lokal, bereits im Brewfile |
| **GitHub Actions** | CI Smoke Tests | macos-latest + Docker Linux |

**Tart Workflow:**
```bash
tart clone ghcr.io/cirruslabs/macos-sequoia-base:latest test-dotfiles
tart run --no-graphics --dir=dotfiles:~/.dotfiles test-dotfiles &
ssh admin@$(tart ip test-dotfiles)  # default: admin/admin
# ... install + validate ...
tart delete test-dotfiles
```

**Lima Workflow:**
```bash
limactl start --name=test-dotfiles --cpus=2 --memory=4 --vm-type=vz template://ubuntu
limactl shell test-dotfiles -- bash -c 'cd ~/dotfiles && make install'
limactl delete -f test-dotfiles
```

### 3.2 Nix Installieren (Determinate Systems)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

- Überlebt macOS Updates ("Nix Survival Mode")
- Erstellt APFS Volume für `/nix/store`
- Homebrew, Stow, Zimfw bleiben vorerst unberührt

### 3.3 Flake-Struktur

```
~/.dotfiles/nix/
  flake.nix                  # Entry point (nix-darwin + home-manager + nix-homebrew)
  flake.lock                 # Auto-generated
  hosts/
    darwin.nix               # System config, keyboard, fonts, Touch ID sudo
  home/
    default.nix              # Home Manager Entry (imports alle Module)
    neovim.nix               # mkOutOfStoreSymlink für nvim config
    git.nix                  # Symlink für git config
    shell.nix                # Zsh: Phase 1 = Symlink, Phase 2 = native HM Module
    terminals.nix            # ghostty + tmux Symlinks
    editors.nix              # zed, cursor, opencode Symlinks
    tools.nix                # k9s, lazygit, claude, bat, btop, fzf, yazi, atuin
  modules/
    homebrew.nix             # Casks + verbleibende Brews
    macos-defaults.nix       # system.defaults (ersetzt macOS/settings.sh)
```

### 3.4 Homebrew Casks deklarativ via nix-darwin

```nix
homebrew = {
  enable = true;
  onActivation.cleanup = "none";  # Phase 1: "none", Phase 2: "uninstall", Phase 3: "zap"
  casks = [ "1password" "arc" "ghostty" "gitbutler" "obsidian" "raycast" "slack" ... ];
  brews = [ "neovim" "mas" "stow" "swift" ];  # Tools die bei Homebrew bleiben müssen
  masApps = { "Final Cut Pro" = 424389933; "Xcode" = 497799835; ... };
};
```

**Was bei Homebrew bleibt:**
- GUI Apps (Casks) — Nix GUI Apps auf macOS sind second-class
- Mac App Store Apps (nur `mas` kann das)
- NeoVim (ARM Mac Build Issues)
- Apple Toolchains (swift, xcode-cli)
- Hardware-spezifische Tools (qmk)

**Was zu Nix wandert:**
- Standard CLI Tools (ripgrep, fd, bat, eza, jq, yq, curl, wget, ...)
- Dev-Language Toolchains (go, rustup, deno, nodejs)
- Formatters/Linters (shellcheck, stylua, nixfmt)
- K8s Tools (kubectl, kubectx, k9s, helm, lazygit, lazydocker)

### 3.5 Migration Ordering (Risk-Ordered)

**Tier 1: Easy Wins (zuerst):**
```
programs.git → programs.starship → programs.fzf → programs.zoxide
→ programs.bat → programs.eza → programs.direnv
```
Mechanical Port, single-binary Tools mit gut getesteten HM-Modulen.

**Tier 2: Medium Complexity:**
```
programs.atuin → xdg.configFile (k9s, lazygit, ghostty)
→ tmux via mkOutOfStoreSymlink (TPM weiter nutzen)
```

**Tier 3: Complex, mkOutOfStoreSymlink:**
```
NeoVim Config → Zed Config → Claude Config
```
Aktiv editierte Configs mit externen Plugin-Managern.

**Tier 4: Letztes (höchstes Risiko):**
```
Zsh Shell Config → Stow entfernen
```
Zsh Phase 1: Zimfw behalten, `programs.zsh.enable = true`, Symlinks für .zshrc/.zshenv/.zprofile
Zsh Phase 2 (optional): Zimfw durch native HM Plugin-Management ersetzen

### 3.6 PATH Priority

nix-darwin setzt PATH in `/etc/zshenv`:
```
/run/current-system/sw/bin          # Nix system packages (höchste Priorität)
/etc/profiles/per-user/nico/bin     # Home Manager packages
/opt/homebrew/bin                   # Homebrew (niedrigere Priorität)
/usr/local/bin → /usr/bin → /bin
```

Nix Binaries haben Vorrang. NeoVim bleibt bei `/opt/homebrew/bin/nvim` weil es nicht in Nix ist.

### 3.7 Rollback-Strategie

**Vor jedem Tier:**
```bash
git checkout -b nix-migration-tier-N
brew bundle dump --file=~/brew-snapshot-$(date +%Y%m%d).Brewfile
ls -la ~/.config/ > ~/symlink-snapshot-$(date +%Y%m%d).txt
```

**Rollback:**
- Re-stow: `cd ~/.dotfiles && stow <package>`
- Brew restore: `brew bundle install --file=~/brew-snapshot-YYYYMMDD.Brewfile`
- Home Manager Backups: `backupFileExtension = "backup"` → `find ~ -name "*.backup"`
- Nuclear: `home-manager uninstall` → `stow */`
- nix-darwin: `darwin-rebuild switch --rollback`

### 3.8 nix-darwin für macOS System Settings

```nix
system.defaults = {
  dock = { tilesize = 48; autohide = true; show-recents = false; mru-spaces = false; };
  trackpad = { Clicking = true; TrackpadThreeFingerDrag = true; };
  NSGlobalDomain = { AppleShowAllExtensions = true; KeyRepeat = 1; InitialKeyRepeat = 10; };
  finder = { AppleShowAllExtensions = true; FXEnableExtensionChangeWarning = false; };
  CustomUserPreferences = { /* Escape-Hatch für nicht-exponierte Settings */ };
};
```

**Ersetzt** `macOS/settings.sh` vollständig (nach Cleanup in Phase 1.2).

---

## Phase 4: Dokumentation & Media

### 4.1 README.md Überarbeitung
- Neue Architektur widerspiegeln (Nix + Docker)
- Container-Nutzung dokumentieren
- Quick Start für verschiedene Szenarien (frisches macOS, Linux, Container, DevPod)

### 4.2 Screenshots & GIFs
- Terminal Setup (Ghostty + tmux + Starship)
- NeoVim in Action
- TUI Tools (lazygit, k9s, jjui, btop)
- Docker Container Demo

### 4.3 Video Walkthrough
- Setup-Prozess von Null (macOS)
- Key Features Tour
- Container-Demo

### 4.4 Docker Demo GIFs
- `docker run -it snics/nvim` Live-Demo
- `docker run -it snics/devenv` mit tmux Split
- Web-GUI via ttyd

---

## Zeitliche Einordnung

| Phase | Geschätzter Aufwand | Abhängigkeiten |
|-------|-------------------|----------------|
| Phase 0.1 (Secrets) | 1-2 Stunden | Keine |
| Phase 0.2 (Obsidian) | 1-2 Stunden | Keine |
| Phase 0.3 (CRD Wizard) | 15-30 Min | 0.1 (GEMINI_API_KEY) |
| Phase 1.1 (Makefile) | 1-2 Sessions | Keine |
| Phase 1.2 (macOS Settings) | 1 Session | Keine |
| Phase 2.1-2.5 (Docker) | 2-3 Sessions | 1.1 (non-interactive install) |
| Phase 2.6-2.8 (CI/CD) | 1-2 Sessions | 2.1-2.5 |
| Phase 3.1 (VM Testing) | 1 Session | 1.2 (macOS Settings Cleanup) |
| Phase 3.2-3.4 (Nix Bootstrap) | 2-3 Sessions | 3.1 |
| Phase 3.5-3.8 (Migration) | 3-5 Sessions | 3.4 |
| Phase 4 (Docs) | 1-2 Sessions | 2 + 3 abgeschlossen |

---

## Dependencies

- Nix (Determinate Systems Installer)
- nix-darwin + Home Manager
- Tart (macOS VMs, `brew install cirruslabs/cli/tart`)
- Lima (Linux VMs, bereits im Brewfile)
- Docker + GitHub Actions
- ttyd (Terminal im Browser, nur als Docker Binary)

## Related

- [nix-darwin Manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Tart VM](https://tart.run/)
- [ttyd](https://tsl0922.github.io/ttyd/)
- [Dev Containers Spec](https://containers.dev/)

## Research Files

- [Install Script Patterns Research](install-script-research.md) — Makefile vs justfile vs Shell, konkrete Templates
- macOS Settings Audit — in Memory (#4006, #4035, #4038, #4045, #4047)
- Docker Architecture Decision — in Memory (#4003, #4029-4031)
- NeoVim + Nix Migration Strategy — in Memory (#4041)
- VM Testing Infrastructure — in Memory (#4024, #4036-4037, #4048)

---

**Created:** 2026-02-10
**Status:** Planning (Research Complete)
**Priority:** High

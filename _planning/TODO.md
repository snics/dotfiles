# Dotfiles TODO — Pre-Nix Cleanup

> Alles was erledigt sein muss bevor Phase 3 (Nix-Darwin + Home Manager) beginnt.
> Erstellt: 2026-04-13 | Basiert auf: Codex Audit, CloudMem Review, Code-Scan

## Priority: HIGH — Bugs & Broken Things

### Docker Images Rebuild (nach NeoVim 0.12 Migration)
- [x] `_images/nvim/Dockerfile` — nvim-treesitter wechselte von `master` → `main` Branch, braucht jetzt `tree-sitter-cli` zum Kompilieren
- [x] `_images/devenv/Dockerfile` — gleicher Treesitter-Impact + neue Plugins (kustomize.nvim, kubeconform source)
- [x] `_images/devenv-web-terminal/Dockerfile` — basiert auf devenv, Rebuild nötig
- [x] Docker Builds sind nicht fail-closed: Homebrew-Fehler werden gesammelt aber nicht abgebrochen (nvim Dockerfile Zeile 114: `TSUpdate || true`, Mason best-effort)
- [x] Smoke Tests nach Rebuild verifizieren

### Justfile/Makefile Sync
- [x] `help` Target fehlt im Justfile (Makefile hat es, verletzt CLAUDE.md Sync-Regel)

### Lint Coverage
- [x] `just lint` / `make lint` prüfen `_test/*.sh` nicht — ShellCheck Findings werden nie exercised

### macOS VM Test
- [x] `_test/vm-test-macos.sh` Zeile 143-144: fehlgeschlagene Homebrew-Installs werden maskiert

## Priority: MEDIUM — Code Quality & Warnings

### ShellCheck Findings
- [x] `_install/claude.sh:10` — `BASH_SOURCE` sollte `[0]` verwenden
- [x] `_macOS/dock-apps.sh:48,68` — Arrays sehen aus ShellCheck-Sicht unused aus
- [x] `_macOS/project-folder-structure.sh:31` — `read` ohne `-r` Flag
- [x] `_test/vm-test-macos.sh:98` — `SSH_OPTS` sollte ein Array sein

### bootstrap.sh
- [x] `git pull --ff-only` Fehler werden unterdrückt (Zeile 46) — bei divergiertem Repo bleibt stale Checkout

### Deprecated Brew Packages
- [x] `qmk-toolbox` Cask ist upstream deprecated — evaluieren ob noch nötig oder entfernen

## Priority: LOW — Incomplete Features & TODOs

### Phase 0.4: Obsidian (90% fertig)
- [ ] `_install/obsidian.sh` erstellen (kopiert Config nach iCloud Vault)
- [ ] `backup-obsidian` Zsh-Funktion (rsync Config zurück ins Repo)
- [ ] In install.sh / justfile verdrahten
- [ ] iCloud Sync testen

### NeoVim TODOs
- [x] `tofu-ls` — eingebaut mit manueller Server-Config (nvim-lspconfig hat noch kein Default)
- [ ] `pkl-ls` — wartet auf nvim-lspconfig Mapping (Mason hat das Paket, aber kein lspconfig Support)
- [x] `codecompanion.lua:1` — OpenRouter Adapter — plugin updated, test pending
- [x] `codecompanion.lua:2` — claude-code-acp Auth — claudecode.nvim added (reuses CLI OAuth), ACP needs setup-token
- [x] `codecompanion.lua:3` — codex-acp Auth — needs `codex` interactive login (documented)

### Docker TODOs
- [ ] `_images/devenv-web-terminal` — ghostty-web Migration wenn Ghostty v1.0 mit libghostty-vt WASM kommt

### Zsh TODOs
- [ ] `zsh/functions/update.zsh:5` — ZeroBrew evaluieren (https://github.com/lucasgelfond/zerobrew)

## Priority: FUTURE — Phase 3 (Nix-Darwin + Home Manager)

> Erst starten wenn alle obigen Items erledigt oder bewusst deferred sind.
> Plan refined 2026-05-27: 3 sequentielle Specs statt tier-based.

### Spec 1 — Foundation [DESIGN COMPLETE — Codex-reviewed]
Spec: `docs/superpowers/specs/2026-05-27-nix-darwin-foundation-design.md`
- [ ] Nix installieren (Determinate Systems Installer, `--determinate` flag)
- [ ] `nix/` Skelett: `flake.nix`, `lib/mkDarwin.nix`, `hosts/{pikachu,vm-test}.nix`, `users/nico.nix`
- [ ] `modules/darwin/{touchid,system-defaults}.nix` (homebrew DEFERRED zu Spec 2)
- [ ] `modules/home/symlinks.nix` + tier-stubs (alle leer)
- [ ] `modules/shared/.gitkeep` (Cross-OS Vorbereitung)
- [ ] `formatter.aarch64-darwin` = nixfmt-rfc-style
- [ ] Host setzt `nix.enable = false` (Determinate ownt nix.conf)
- [ ] `just nix-{build,switch,rollback,list}` Targets in Justfile + Makefile
- [ ] `_install/nix.sh` thin wrapper für Determinate-Installer
- [ ] VM-Test (Tart) gegen `#vm-test` Host (headless-safe Touch-ID-Check)
- [ ] Lokales Apply auf `#pikachu`
- [ ] Post-Checks: Stow + Brewfile + Homebrew unangetastet
- [ ] 24-48h Smoke-Test

### Spec 2 — Package Migration [PLANNED]
- [ ] Inventur-Skript: jedes Brew gegen `nix search` prüfen
- [ ] Nix-first Policy: nixpkgs → `home.packages`, Rest → `homebrew.{brews,casks,masApps}`
- [ ] `brew/Brewfile.*` löschen, `zsh/conf.d/15-brew.zsh` Generator löschen
- [ ] `homebrew.onActivation.cleanup` schrittweise eskalieren ("none" → "uninstall" → "zap")
- [ ] VM-Test + lokales Apply

### Spec 3 — Home Manager / Config Migration [PLANNED]
- [ ] Configs tool-by-tool: `programs.*` wo nativ, `mkOutOfStoreSymlink` für Repo-Configs
- [ ] macOS Settings → `system.defaults` Vollmigration (`_macOS/settings.sh` ablösen)
- [ ] Stow am Ende: `stow -D */` + Stow-Package aus Brewfile (bzw. Nix nach Spec 2)
- [ ] VM-Test zwischen jeder Tool-Migration

### Parallel (unabhängiges Timing)
Spec: `_planning/ideas/unified-formatter.md`
- [ ] Phase A: Standalone treefmt (vor Nix-Migration möglich)
- [ ] Phase B: treefmt-nix Integration (nach Spec 1)
- [ ] Phase C: git-hooks.nix (optional, nach Spec 2/3)

## Priority: FUTURE — Phase 4 (Dokumentation)

- [ ] README.md Überarbeitung (neue Architektur)
- [ ] Screenshots & GIFs
- [ ] Video Walkthrough
- [ ] Docker Demo GIFs

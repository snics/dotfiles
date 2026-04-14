# Dotfiles TODO — Pre-Nix Cleanup

> Alles was erledigt sein muss bevor Phase 3 (Nix-Darwin + Home Manager) beginnt.
> Erstellt: 2026-04-13 | Basiert auf: Codex Audit, CloudMem Review, Code-Scan

## Priority: HIGH — Bugs & Broken Things

### Docker Images Rebuild (nach NeoVim 0.12 Migration)
- [x] `_images/nvim/Dockerfile` — nvim-treesitter wechselte von `master` → `main` Branch, braucht jetzt `tree-sitter-cli` zum Kompilieren
- [x] `_images/devenv/Dockerfile` — gleicher Treesitter-Impact + neue Plugins (kustomize.nvim, kubeconform source)
- [x] `_images/devenv-web-terminal/Dockerfile` — basiert auf devenv, Rebuild nötig
- [x] Docker Builds sind nicht fail-closed: Homebrew-Fehler werden gesammelt aber nicht abgebrochen (nvim Dockerfile Zeile 114: `TSUpdate || true`, Mason best-effort)
- [ ] Smoke Tests nach Rebuild verifizieren

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
- [ ] `mason.lua:55` — `pkl-ls` und `tofu-ls` hinzufügen wenn mason-lspconfig die unterstützt
- [ ] `codecompanion.lua:1` — OpenRouter Adapter "adapter not found" Bug (Inline/Cmd Strategy)
- [ ] `codecompanion.lua:2` — claude-code-acp Auth Error 401 (braucht ANTHROPIC_API_KEY, kein OAuth)
- [ ] `codecompanion.lua:3` — codex-acp Auth Error (braucht OPENAI_API_KEY)

### Docker TODOs
- [ ] `_images/devenv-web-terminal` — ghostty-web Migration wenn Ghostty v1.0 mit libghostty-vt WASM kommt

### Zsh TODOs
- [ ] `zsh/functions/update.zsh:5` — ZeroBrew evaluieren (https://github.com/lucasgelfond/zerobrew)

## Priority: FUTURE — Phase 3 (Nix-Darwin + Home Manager)

> Erst starten wenn alle obigen Items erledigt oder bewusst deferred sind.

- [ ] Nix installieren (Determinate Systems Installer)
- [ ] Flake-Struktur aufsetzen (`nix/flake.nix`, `hosts/darwin.nix`, `home/`)
- [ ] Tier 1 Migration: git, starship, fzf, zoxide, bat, eza, direnv
- [ ] Tier 2 Migration: atuin, k9s, lazygit, ghostty, tmux
- [ ] Tier 3 Migration: NeoVim (mkOutOfStoreSymlink), Zed, Claude
- [ ] Tier 4 Migration: Zsh Shell Config, Stow entfernen
- [ ] macOS Settings → `system.defaults` migrieren
- [ ] Homebrew Casks deklarativ via nix-darwin
- [ ] VM-Tests für Nix-Migration (Rollback verifizieren)

## Priority: FUTURE — Phase 4 (Dokumentation)

- [ ] README.md Überarbeitung (neue Architektur)
- [ ] Screenshots & GIFs
- [ ] Video Walkthrough
- [ ] Docker Demo GIFs

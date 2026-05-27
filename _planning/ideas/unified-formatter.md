# Unified Formatter with treefmt

> One command (`treefmt` / `nix fmt`), one config, one cache — formats all languages in the dotfiles repo consistently. Replaces the per-tool dispatcher in `git/hooks/format-staged` with a real multiplexer.

## 🎯 Goal

Heute existiert ein **Format-Dispatcher** (`git/hooks/format-staged`, commit `c8a3196f`) der opt-in pro Tool läuft: `oxfmt`, `dprint`, `oxlint`, `stylua`, `yamllint`. Jeder Formatter braucht eigene Config, eigene Installation, eigene Editor-Integration in NeoVim und Zed. Ergebnis: Inkonsistente Formatierung über Dateitypen, jeder Editor formatiert anders, CI/Pre-Commit-Hook driftet vom Save-Behavior weg.

**Lösung:** `treefmt` (Numtide Go-Binary) als Multiplexer. Eine `treefmt.toml`, eine Quelle der Wahrheit für **alle** Editoren, **alle** Hooks, **alle** CI-Jobs. NeoVim + Zed + pre-commit + GitHub Actions delegieren alle an `treefmt`.

**Value:**
- **Konsistenz:** Save in NeoVim = Save in Zed = Pre-commit-Hook = CI-Gate. Keine Drift.
- **Reproduzierbarkeit:** Formatter-Versionen über Nix gepinnt (via `treefmt-nix`).
- **Skalierbarkeit:** Neue Sprache hinzufügen = 3 Zeilen in `treefmt.toml`, kein 5-Tool-Update-Aufwand.
- **Cache:** `treefmt` cached per Content-Hash, format-on-save bleibt schnell.

## 📋 Requirements

- **Single source of truth:** `treefmt.toml` (root des Dotfiles-Repos) definiert pro Sprache welcher Formatter mit welchen Optionen läuft
- **Editor parity:** NeoVim (conform.nvim) und Zed (`formatter.external`) delegieren beide an `treefmt --stdin {file}`
- **Hook integration:** Pre-commit-Hook ruft `treefmt --ci` auf staged files
- **CI gate:** GitHub Actions führt `treefmt --ci` als eigenen Step aus
- **Nix-Integration:** Via `treefmt-nix` als Flake-Modul → `nix fmt` exponiert die gleiche Pipeline; integriert in `nix flake check`
- **yamllint coexistence:** treefmt = Formatierer, yamllint = Linter (Style-Rules in yamllint disablen, Lint-Rules behalten)
- **Migration-friendly:** Bestehender Dispatcher kann phase-out, ein Tool nach dem anderen
- **Per-repo Override:** Wenn ein anderes Projekt eine eigene `treefmt.toml` hat, gewinnt diese — keine globale Konflikte

## 💡 Implementation Ideas

### Approach

Drei-Phasen-Rollout, der mit der Nix-Migration verzahnt ist:

**Phase A — Standalone treefmt (vor Nix-Migration):**
- `treefmt` Binary über Brewfile pinnen
- `treefmt.toml` im Repo-Root mit allen Formattern
- Dispatcher → treefmt im pre-commit Hook
- Editor-Integration

**Phase B — treefmt-nix in Foundation einziehen:**
- Sobald Nix-Foundation steht: `treefmt-nix` als Flake-Modul wiren
- `nix fmt` Pipeline ersetzt direkten `treefmt`-Aufruf
- Formatter-Binaries werden über Nix gepinnt (kein "works on my machine")
- `nix flake check` validiert Formatierung als CI-Gate

**Phase C — Pre-commit-Hook via `git-hooks.nix`:**
- Lefthook als Intermediate (YAML, kein Python-Overhead)
- Später: `git-hooks.nix` Flake-Modul → komplett deklarativ
- `nix flake check` führt Hooks lokal aus

### Formatter-Auswahl pro Sprache (2026 Consensus)

| Sprache | Formatter | Begründung |
|---------|-----------|------------|
| **Nix** | `nixfmt` (RFC-166) | Official seit RFC 166, in nixpkgs CI enforced, v1.2.0 (Jan 2026), Community-maintained |
| **Lua** | `stylua` | Unchallenged consensus, schon im Repo (`.stylua.toml`) |
| **Shell** (.sh, .zsh) | `shfmt` | mvdan/sh, Go-Binary, POSIX+Bash+mksh |
| **YAML** | `yamlfmt` (Google) | Comment-preserving, Go, mehr konfigurierbar als Prettier |
| **JSON** | `prettier` oder `dprint json` | dprint 10-100× schneller, Prettier breiter erprobt |
| **TOML** | `taplo` | Standard, kein Konkurrent in Sicht |
| **Markdown** | `prettier` | Beste Tabellen + Link-Refs Behandlung |
| **Dockerfile** | — (kein Formatter) | hadolint nur Linter; `RUN`-Blocks könnten via shfmt |
| **Justfile** | `just --fmt --unstable` | Noch unstable (touches mtimes, strips Kommentare); vorerst skippen |
| **Makefile** | — | Kein reifer Formatter |

### Files to Modify

**Phase A (Standalone):**
- `brew/Brewfile.20-dev-tools` — `treefmt`, `shfmt`, `yamlfmt`, `taplo`, `dprint`, `nixfmt-rfc-style` (vorbereitend) ergänzen
- `treefmt.toml` — neu, Root des Repos, alle Sprachen mappen
- `git/hooks/format-staged` — Dispatcher delegiert auf `treefmt` für unterstützte Sprachen, behält Spezial-Logik (z.B. yamllint als Linter)
- `nvim/.config/nvim/lua/plugins/conform.lua` (oder wo conform konfiguriert ist) — `treefmt` als Custom-Formatter, `["_"]` als Fallback
- `zed/.config/zed/settings.json` — `formatter.external` global auf `treefmt --stdin {buffer_path}`, per-language Overrides für Rust/Dockerfile auf `language_server`
- `_docs/keybindings.md` — keine Änderung (treefmt hat kein Keymap)
- `.github/workflows/smoke.yml` — neuer Step `treefmt --ci`
- `_docs/formatter.md` — neu, dokumentiert Setup für neue Contributor

**Phase B (Nix-Integration):**
- `nix/modules/dev/treefmt.nix` — `programs.nixfmt.enable = true; programs.stylua.enable = true; ...`
- `nix/flake.nix` — `treefmt-nix` als Input, `formatter.aarch64-darwin` exponiert
- `brew/Brewfile.20-dev-tools` — Formatter-Brews wieder rausnehmen (kommen jetzt aus Nix)

**Phase C (Hooks via Nix):**
- `nix/modules/dev/git-hooks.nix` — pre-commit Konfiguration deklarativ
- `git/hooks/format-staged` — kann ersetzt werden durch git-hooks.nix-generierten Hook

### Steps

**Phase A — Standalone treefmt (3-5h):**

1. `treefmt` + Formatter-Binaries zu `brew/Brewfile.20-dev-tools` hinzufügen
2. `treefmt.toml` schreiben (basierend auf [home-manager](https://github.com/nix-community/home-manager/blob/master/treefmt.toml) und [Frost-Phoenix](https://github.com/Frost-Phoenix/nixos-config/blob/main/treefmt.toml) als Vorlage)
3. Repo einmalig komplett formatieren (`treefmt`) → Diff reviewen, ggf. Excludes ergänzen
4. NeoVim conform.nvim auf `treefmt` als `["_"]`-Fallback umstellen
5. Zed `formatter.external` global auf `treefmt --stdin {buffer_path}`
6. `git/hooks/format-staged` Dispatcher um treefmt-Branch ergänzen
7. GitHub Actions Step `treefmt --ci` hinzufügen
8. `.gitattributes` mit `* text=auto eol=lf` (verhindert CRLF/LF-Diff-Explosionen)
9. VM-Tests rerun (`just test-linux`, `just test-macos`) → bestätigen dass Setup auf frischem System funktioniert
10. Dokumentation in `_docs/formatter.md`

**Phase B — treefmt-nix in Nix-Foundation (1-2h, nach Nix-Migration):**

1. `treefmt-nix` als Input in `nix/flake.nix`
2. `nix/modules/dev/treefmt.nix` mit allen Formattern, equivalent zu `treefmt.toml`
3. `flake.formatter` exponieren → `nix fmt` läuft die Pipeline
4. `nix flake check` als CI-Gate → ersetzt direkten `treefmt --ci` Step
5. Brewfile bereinigt (Formatter kommen jetzt aus Nix)
6. `treefmt.toml` bleibt für non-Nix-Tooling-Konsumenten (Editor, Pre-commit) — wird aus Nix-Modul generiert oder hand-synchronisiert

**Phase C — Hooks via git-hooks.nix (1h, optional):**

1. `lefthook` als Intermediate (yaml config, fast, kein Python)
2. Später: `git-hooks.nix` Flake-Modul → `pre-commit-check.treefmt.enable = true`
3. `git/hooks/format-staged` Dispatcher kann komplett raus

## 📦 Dependencies

**Phase A — Brewfile additions:**
- `treefmt` — Multiplexer
- `shfmt` — Shell
- `yamlfmt` — YAML (Google's tool)
- `taplo` — TOML
- `dprint` — JSON (optional, sonst prettier)
- `prettier` (via node) — Markdown, JSON fallback
- `nixfmt-rfc-style` — bereits jetzt für Nix-Files (auch ohne Nix installiert)

**Phase B additions (in Nix):**
- `treefmt-nix` Flake-Input
- Formatter-Module über `programs.*.enable`

**Phase C additions:**
- `git-hooks.nix` (cachix/git-hooks.nix) Flake-Input
- ggf. `lefthook` als Brewfile-Übergangslösung

## 🔗 Related

**Backlog/Existing:**
- `git/hooks/format-staged` (commit `c8a3196f`) — bestehender Dispatcher
- `nvim/.config/nvim/.stylua.toml` — bestehende Stylua-Config (wird treefmt.toml-Einträge)
- Phase 3 Nix-Migration ([roadmap-2026.md](roadmap-2026.md)) — Phase B/C koppelt direkt daran

**External docs:**
- [treefmt.com](https://treefmt.com/) — Official docs
- [numtide/treefmt-nix](https://github.com/numtide/treefmt-nix) — Nix-Wrapper + 100+ Formatter-Module
- [RFC 166](https://github.com/NixOS/rfcs/pull/166) — Nix-Format-Standard
- [home-manager treefmt.toml](https://github.com/nix-community/home-manager/blob/master/treefmt.toml) — Real-world example
- [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config/blob/main/treefmt.toml) — Real-world example
- [cachix/git-hooks.nix](https://github.com/cachix/git-hooks.nix) — Phase C Hook-Integration
- [Leveraging external formatters in Zed (adamhl.dev)](https://adamhl.dev/blog/zed-external-formatters)
- [conform.nvim #701](https://github.com/stevearc/conform.nvim/issues/701) — treefmt-as-formatter Pattern

## 📝 Notes

**Reihenfolge:** Phase A ist **unabhängig** von Nix-Migration und kann jederzeit gemacht werden. Phase B/C sind **nach** Nix-Foundation.

**Nix-Foundation-Vorgriff:** In der Nix-Foundation-Spec (separat) wird **nur** `nixfmt-rfc-style` als Formatter für `.nix`-Dateien wired — über `nix fmt` direkt oder als Mini-treefmt-nix Setup. Das volle treefmt-Setup über alle Sprachen ist diese Feature-Spec.

**yamllint:** Bleibt parallel zu treefmt. yamllint = Linter, treefmt = Formatter. yamllint Style-Rules (`indentation`, `line-length`, `trailing-spaces`) deaktivieren, Logik-Rules behalten (`document-start`, `truthy`, `empty-values`, `key-duplicates`). yamllint läuft als zweiter pre-commit hook nach treefmt.

**Dispatcher-Migration:** Der bestehende `format-staged` Dispatcher hat einen Wert (Opt-in via Config-Existenz, sauber pro Tool). Übergang: Dispatcher behält `yamllint` (Linter-Rolle) und `oxlint` (anderes Tool), aber Formatierung-Branches (`oxfmt`, `dprint`, `stylua`) delegieren an `treefmt`.

**Justfile:** `just --fmt --unstable` ist noch unreif (touched mtimes, strippt Kommentare). Vorerst NICHT in treefmt aufnehmen, manuell behandeln oder warten bis stable.

**Global vs per-project:** treefmt sucht aufwärts nach `treefmt.toml` von cwd. Lösung: `TREEFMT_CONFIG=$HOME/.dotfiles/treefmt.toml` in `zsh/conf.d/` als Fallback für non-dotfiles-Projekte. Per-Projekt-`treefmt.toml` gewinnt automatisch (näher an cwd).

**Performance:** Treefmt cached per Content-Hash in `$XDG_CACHE_HOME/treefmt`. Editor-Save (mit Cache) → ~30-50ms. CI mit `--ci` (no-cache) → einmaliger Repo-Format-Run ist <5s.

**Was treefmt NICHT formatiert:**
- Dockerfiles (kein reifer Formatter)
- Justfile/Makefile (noch nicht stabil)
- Images, Binaries, Git pack files, .pen-Files

## ✅ Done Criteria

**Phase A:**
- [ ] `treefmt.toml` im Root, alle relevanten Sprachen mapped
- [ ] Repo einmal komplett formatiert, Diff committed
- [ ] NeoVim formatiert via treefmt on save
- [ ] Zed formatiert via treefmt on save
- [ ] Pre-commit-Hook delegiert an treefmt
- [ ] CI gated on `treefmt --ci`
- [ ] VM-Tests grün
- [ ] Dokumentation in `_docs/formatter.md`

**Phase B (nach Nix-Foundation):**
- [ ] `nix fmt` exponiert treefmt-Pipeline
- [ ] Formatter-Binaries kommen aus Nix (Brewfile reduziert)
- [ ] `nix flake check` enthält Format-Gate

**Phase C (optional):**
- [ ] Pre-commit-Hook via `git-hooks.nix` (oder lefthook als Übergang)
- [ ] Dispatcher abgelöst

---

**Created:** 2026-05-27
**Status:** Planning (Research Complete)
**Priority:** Medium (Phase A standalone möglich, Phase B/C nach Nix-Migration)

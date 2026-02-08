# Secret Management for Dotfiles

> Zentrales, sicheres Laden von API-Keys und Secrets in Shell-Umgebungsvariablen - ohne Klartext im Dateisystem.

## Goal

Aktuell liegen Secrets in `~/.secrets` als Plaintext-Datei. Ziel ist ein sicherer, reproduzierbarer Ansatz, bei dem Secrets aus einem verschluesselten Store geladen werden und trotzdem in allen Tools (Claude Code, Cursor, Terminal, etc.) als Umgebungsvariablen verfuegbar sind.

## Betroffene Keys

| Service | Variable | Genutzt von |
|---------|----------|-------------|
| OpenAI | `OPENAI_API_KEY`, `OPENAI_ORG_ID` | Cursor, Claude Code, diverse Tools |
| Anthropic | `ANTHROPIC_API_KEY` | Claude Code (nur bei API-Nutzung) |
| Google Gemini | `GEMINI_API_KEY` | Cursor, AI-Tools |
| OpenRouter | `OPENROUTER_API_KEY` | Cursor, CRD Wizard, AI-Tools |
| Context7 | `CONTEXT7_API_KEY` | Claude Code MCP, Cursor MCP |
| Exa Search | `EXA_API_KEY` | Cursor MCP |
| GitHub | `GITHUB_TOKEN` | gh CLI, Git |

## Optionen (Research)

### Option A: macOS Keychain (nativ)

```bash
# Speichern
security add-generic-password -s 'openai' -a 'api_key' -w 'sk-...'

# Laden in ~/.secrets
export OPENAI_API_KEY=$(security find-generic-password -w -s 'openai' -a 'api_key' 2>/dev/null)
```

**Pro:** Kein Extra-Tool, nativ verschluesselt, kostenlos, keine Dependencies
**Contra:** macOS-only, kein Sync zwischen Geraeten, Keychain-Prompt beim ersten Zugriff

### Option B: 1Password CLI (`op`)

```bash
# Laden via op read
export OPENAI_API_KEY=$(op read "op://Private/OpenAI/api_key")

# Oder via op inject (Template-basiert)
# ~/.secrets.tpl:
# export OPENAI_API_KEY="{{ op://Private/OpenAI/api_key }}"
op inject --in-file ~/.secrets.tpl --out-file ~/.secrets
```

**Pro:** Sync ueber Geraete, Team-Sharing moeglich, exzellente UX, biometrische Auth
**Contra:** Kostenpflichtig (Abo), Abhaengigkeit von 1Password

### Option C: Bitwarden CLI (`bws`)

```bash
# Via Secrets Manager CLI
export BWS_ACCESS_TOKEN="..."
bws run -- zsh  # Injiziert alle Secrets als Env-Vars
```

**Pro:** Open Source (Server self-hostable), guenstiger als 1Password, Secrets Manager
**Contra:** Setup komplexer, weniger poliert als 1Password

### Option D: `pass` (Unix Password Store)

```bash
# GPG-verschluesselt, git-synced
pass insert api-keys/openai
export OPENAI_API_KEY=$(pass show api-keys/openai)
```

**Pro:** Unix-Philosophie, GPG-basiert, Git-Sync, keine Cloud, kostenlos
**Contra:** GPG-Setup noetig, Passphrase-Eingabe, weniger komfortabel

### Option E: Doppler

```bash
# Cloud-basierter Secret Manager
doppler run -- zsh
```

**Pro:** Cloud-Sync, Team-Features, Audit-Log, einfaches Setup
**Contra:** Cloud-Abhaengigkeit, Free-Tier limitiert

## Bewertungskriterien

- [ ] **Sicherheit** - Keine Secrets im Klartext auf Disk
- [ ] **Komfort** - Einfaches Laden beim Shell-Start ohne manuelle Eingabe
- [ ] **Portabilitaet** - Funktioniert auf neuen Maschinen schnell
- [ ] **Kosten** - Kostenlos oder vertretbar
- [ ] **Sync** - Optional: Secrets zwischen Geraeten synchronisieren
- [ ] **Kompatibilitaet** - Funktioniert mit allen Tools (Claude Code, Cursor, Terminal-Apps)
- [ ] **Offline** - Funktioniert auch ohne Internet

## Files to Modify

- `~/.secrets` - Von Plaintext auf Store-basiertes Laden umstellen
- `.secrets.example` - Dokumentation der gewaehlten Methode
- `_install/claude.sh` - MCP-Server brauchen Env-Vars
- `zsh/settings/aliases.zsh` - Helper-Aliases fuer Secret-Management
- `README.md` - Dokumentation aktualisieren

## Done Criteria

- [ ] Research abgeschlossen - Methode gewaehlt
- [ ] `~/.secrets` laedt Keys aus verschluesseltem Store
- [ ] Alle AI-API-Keys funktionieren in Claude Code, Cursor, Terminal
- [ ] `.secrets.example` dokumentiert Setup-Schritte
- [ ] Getestet auf frischem System
- [ ] README aktualisiert

---

**Created:** 2026-02-08
**Status:** Planning
**Priority:** Medium

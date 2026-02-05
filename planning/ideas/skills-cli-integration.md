# Skills CLI Integration

> Agent Skills für Cursor, Claude Code und andere AI-Tools in den Dotfiles verwalten

## 🎯 Goal

Eine deklarative Verwaltung von AI Agent Skills (von skills.sh) in den Dotfiles ermöglichen, sodass Skills zentral definiert und auf alle AI-Tools (Cursor, Claude Code, etc.) synchronisiert werden können.

## 📋 Requirements

- Deklarative Konfiguration (ähnlich Brewfile)
- Zentrale Verwaltung eigener/custom Skills
- Synchronisation zu mehreren AI-Tools (Cursor, Claude, Gemini, etc.)
- Integration in bestehendes Dotfiles-Setup mit Stow

## 💡 Implementation Ideas

### Option A: `@dhruvwill/skills-cli` (empfohlen)

Nutzt eine `~/.skills/config.json` als deklarative Konfiguration:

```json
{
  "sources": [
    { "type": "remote", "url": "https://github.com/vercel-labs/agent-skills/...", "name": "frontend-design" },
    { "type": "local", "path": "~/.dotfiles/skills/custom", "name": "my-skills" }
  ],
  "targets": [
    { "name": "cursor", "path": "~/.cursor/skills" },
    { "name": "claude", "path": "~/.claude/skills" }
  ]
}
```

**Vorteile:**
- Echte deklarative Config (`config.json`)
- Multi-Source (GitHub, GitLab, Local)
- Multi-Target Sync
- `skills sync` / `skills update` Befehle

**Nachteile:**
- Braucht Bun Runtime (nicht Node/npx)
- Relativ neues Projekt (6 Stars)

### Option B: Offizielle `npx skills` CLI

Direkte Befehle im Installationsskript:

```bash
npx skills add vercel-labs/agent-skills --skill frontend-design -g -y
npx skills add ./custom -g --all -y
```

**Vorteile:**
- Offizielle CLI von Vercel Labs
- Kein zusätzliches Tool nötig

**Nachteile:**
- Kein deklaratives Config-Format
- Befehle müssen im Script stehen

### Vorgeschlagene Struktur

```
skills/
  .skills/
    config.json           # Deklarative Konfiguration (Option A)
    store/                # Zentraler Store für eigene Skills
      my-custom-skill/
        SKILL.md
  README.md

_install/
  skills.sh               # Installation + Sync
```

### Offene Fragen

- [ ] Ist `@dhruvwill/skills-cli` stabil genug für Production?
- [ ] Bun als Dependency akzeptabel? (könnte ins Brewfile)
- [ ] Wie verhält sich das mit bestehenden `~/.cursor/skills-cursor/` (built-in)?
- [ ] Symlink vs Copy - was macht die CLI genau?

## 📦 Dependencies

- **Option A:** Bun Runtime (`brew install oven-sh/bun/bun`)
- **Option B:** Node.js (bereits vorhanden)
- Git (für Remote Sources)

## 🔗 Related

- https://skills.sh/ - Agent Skills Directory
- https://github.com/vercel-labs/skills - Offizielle CLI
- https://github.com/dhruvwill/skills-cli - Alternative CLI mit config.json
- https://dhruvwill.github.io/skills-cli/ - Dokumentation

### Unterstützte AI-Tools

| Tool | Global Path |
|------|-------------|
| Cursor | `~/.cursor/skills/` |
| Claude Code | `~/.claude/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
| GitHub Copilot | `~/.copilot/skills/` |

## 📝 Notes

- Skills sind wiederverwendbare Fähigkeiten für AI Agents (SKILL.md Dateien)
- Die offizielle CLI unterstützt Symlink-basierte Installation (empfohlen)
- Eigene Skills können lokal erstellt und dann synchronisiert werden
- `~/.cursor/skills-cursor/` ist reserviert für Cursor's built-in Skills (nicht anfassen!)

## ✅ Done Criteria

- [ ] CLI-Tool evaluiert und entschieden
- [ ] Dotfiles-Struktur angelegt (`skills/`)
- [ ] Config-Datei erstellt (je nach gewähltem Ansatz)
- [ ] Installationsskript `_install/skills.sh` erstellt
- [ ] In `install.sh` integriert
- [ ] README.md für Skills-Modul geschrieben
- [ ] Getestet auf frischem System

---

**Created:** 2026-02-05  
**Status:** Planning  
**Priority:** Medium

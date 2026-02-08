# Claude CLI Config

Zentrale Claude CLI-Konfiguration für die Dotfiles.

## Struktur

```
claude/
  .claude/
    settings.json    # Plugins (symlinked via stow)
  mcp-servers.json   # MCP-Server-Config (gemergt via jq)
```

## Konfigurationsorte

Claude Code nutzt zwei Config-Dateien:

| Datei | Inhalt | Management |
|-------|--------|------------|
| `~/.claude/settings.json` | Plugins | Symlink via `stow claude` |
| `~/.claude.json` | MCP-Server, Theme, Editor-Mode + Runtime-State | MCP-Server werden via `jq` gemergt |

> **Warum kein Symlink für `~/.claude.json`?** Die Datei enthält Runtime-State
> (Session-Stats, OAuth, Caches), der sich bei jedem Start ändert und nicht ins Repo gehört.

## Installation

- Über `install.sh`: Bei der Frage „Do you want to use Claude CLI config?" mit `y` antworten.
- Manuell: `stow claude && source _install/claude.sh` aus `~/.dotfiles` ausführen.

## Plugins

Die `settings.json` aktiviert Plugins aus dem Claude-Marketplace:

- `clangd-lsp` — C/C++ Language Server
- `typescript-lsp` — TypeScript/JavaScript Language Server
- `ralph-loop` — Autonomer AI-Entwicklungs-Loop
- `claude-mem` — Persistenter Cross-Session-Speicher

## MCP-Server

Die `mcp-servers.json` definiert globale MCP-Server, die beim Install in `~/.claude.json` gemergt werden:

- **serena** — Semantische Code-Analyse via LSP (stdio/uvx)
- **grep** — Code-Suche via [grep.app](https://grep.app) (http)
- **context7** — Aktuelle Library-Dokumentation (http, benötigt `CONTEXT7_API_KEY`)

## Secrets

**Wichtig:** API-Keys und andere Secrets sollten **nicht** direkt in `settings.json` gespeichert werden.

- API-Keys über Umgebungsvariable `ANTHROPIC_API_KEY` setzen
- In `~/.secrets` exportieren: `export ANTHROPIC_API_KEY="dein-key"`
- `~/.zshrc` lädt `~/.secrets` automatisch

Siehe auch `.secrets.example` für weitere Informationen.

## Bestehende Config übernehmen

Falls bereits eine `~/.claude/settings.json` existiert, diese in die Dotfiles kopieren:

```bash
cp ~/.claude/settings.json ~/.dotfiles/claude/.claude/settings.json
```

Dann `stow claude` ausführen, um die Verlinkung zu erstellen.

---

## Wispr Flow Integration

**Wispr Flow** ist eine Voice-to-Text-Anwendung, die mit Claude Code verwendet werden kann, um Prompts per Spracheingabe zu erstellen.

### Verfügbarkeit

- **Kein Plugin**: Es gibt aktuell kein direktes Plugin für Claude Code, das Wispr Flow integriert.
- **Separate App**: Wispr Flow läuft als separate Anwendung (Mac, Windows, iOS).
- **Workflow**: Text in Wispr Flow diktieren → in Claude Code einfügen.

### Installation

1. Wispr Flow von [wisprflow.ai](https://wisprflow.ai) herunterladen
2. App installieren und starten
3. Text diktieren und dann in Claude Code einfügen

**Hinweis**: Es gibt aktuell keine Slash-Command-Integration, um den Editor direkt aus Claude Code heraus zu öffnen.

---

## Catppuccin Theme (Web UI)

Das **Catppuccin Theme** für Claude Code ist ein Browser-Userstyle für die Web-UI von Claude.

### Installation

1. **Stylus Extension installieren**:
   - Chrome: [Stylus für Chrome](https://chrome.google.com/webstore/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne)
   - Firefox: [Stylus für Firefox](https://addons.mozilla.org/en-US/firefox/addon/styl-us/)

2. **Catppuccin Userstyles importieren**:
   - Gehe zu [Catppuccin Userstyles](https://userstyles.catppuccin.com/)
   - Oder lade die `import.json` von den [Releases](https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json) herunter
   - In Stylus: **Manage** → **Backup** → **Import** → Datei auswählen

3. **Claude Theme aktivieren**:
   - Öffne die Claude Web-UI (z.B. [code.claude.com](https://code.claude.com))
   - Das Catppuccin Theme sollte automatisch angewendet werden
   - In Stylus kannst du zwischen verschiedenen Catppuccin-Flavors (Latte, Frappe, Macchiato, Mocha) wählen

### Anpassung

- **Customizer**: Nutze den [Catppuccin Userstyles Customizer](https://catppuccin-userstyles-customizer.uncenter.dev/) für individuelle Anpassungen
- **Accent Color**: Wähle deine bevorzugte Akzentfarbe
- **Flavor**: Wähle zwischen Light (Latte) und Dark (Frappe, Macchiato, Mocha)

**Hinweis**: Das Theme funktioniert nur in der **Web-UI** von Claude, nicht in der CLI. Die CLI nutzt die Terminal-Farben deines Terminals.

---

## Ralph - Autonomer AI-Entwicklungs-Loop

**Ralph** ist ein autonomer AI-Entwicklungs-Loop für Claude Code, der kontinuierlich dein Projekt verbessert, bis es fertig ist. Er bietet intelligente Exit-Erkennung, Rate-Limiting und Circuit-Breaker-Funktionalität.

**GitHub**: [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)

### Systemanforderungen

**Erforderlich:**
- **Bash 4.0+** - Für Script-Ausführung
- **Claude Code CLI** - `npm install -g @anthropic-ai/claude-code`
- **tmux** - Terminal-Multiplexer für integriertes Monitoring (empfohlen)
- **jq** - JSON-Verarbeitung für Status-Tracking
- **Git** - Versionskontrolle
- **GNU coreutils** - Für den `timeout` Befehl (auf macOS: `brew install coreutils`)

**Optional:**
- Node.js 18+ (für Claude Code CLI)

### Installation (Einmalig)

Ralph wird **einmalig global** installiert und ist dann in jedem Verzeichnis verfügbar:

```bash
# Repository klonen
git clone https://github.com/frankbria/ralph-claude-code.git
cd ralph-claude-code

# Global installieren
./install.sh
```

Dies fügt folgende Befehle zu deinem PATH hinzu:
- `ralph` - Haupt-Loop-Befehl
- `ralph-monitor` - Live-Monitoring-Dashboard
- `ralph-setup` - Neues Projekt erstellen
- `ralph-import` - Bestehende PRD/Specs importieren
- `ralph-migrate` - Projekt zur neuen `.ralph/` Struktur migrieren

**Hinweis**: Nach der Installation kannst du das geklonte Repository löschen, wenn du möchtest.

### Projekt-Setup (Pro Projekt)

Für jedes neue Projekt, an dem Ralph arbeiten soll:

#### Option A: Bestehende PRD/Specs importieren

```bash
# Bestehende Requirements in Ralph-Format konvertieren
ralph-import my-requirements.md my-project
cd my-project

# Generierte Dateien anpassen:
# - .ralph/PROMPT.md (Ralph-Anweisungen)
# - .ralph/@fix_plan.md (Aufgaben-Prioritäten)
# - .ralph/specs/requirements.md (Technische Specs)

# Autonome Entwicklung starten
ralph --monitor
```

#### Option B: Manuelles Projekt-Setup

```bash
# Neues Ralph-Projekt erstellen
ralph-setup my-awesome-project
cd my-awesome-project

# Projektanforderungen manuell konfigurieren
# Bearbeite .ralph/PROMPT.md mit deinen Projektzielen
# Bearbeite .ralph/specs/ mit detaillierten Spezifikationen
# Bearbeite .ralph/@fix_plan.md mit initialen Prioritäten

# Autonome Entwicklung starten
ralph --monitor
```

### Verwendung

Nach der Installation und dem Projekt-Setup:

```bash
# Mit integriertem Monitoring (empfohlen)
ralph --monitor

# Oder in separaten Terminals:
ralph              # Terminal 1: Ralph Loop
ralph-monitor      # Terminal 2: Live Monitor Dashboard

# Status prüfen
ralph --status

# Mit benutzerdefinierten Optionen
ralph --monitor --calls 50 --timeout 30 --verbose
```

### Unterstützte Import-Formate

Ralph kann verschiedene Formate importieren:
- **Markdown** (.md) - Product Requirements, technische Specs
- **Text** (.txt) - Plain-Text-Requirements
- **JSON** (.json) - Strukturierte Requirement-Daten
- **Word** (.docx) - Business-Requirements
- **PDF** (.pdf) - Design-Dokumente, Spezifikationen

### Projekt-Struktur

Ralph erstellt eine standardisierte Struktur mit einem `.ralph/` Unterordner:

```
my-project/
├── .ralph/                 # Ralph-Konfiguration und State
│   ├── PROMPT.md           # Haupt-Entwicklungsanweisungen
│   ├── @fix_plan.md        # Priorisierte Aufgabenliste
│   ├── @AGENT.md           # Build- und Run-Anweisungen
│   ├── specs/              # Projekt-Spezifikationen
│   ├── examples/           # Verwendungsbeispiele
│   ├── logs/               # Ralph-Ausführungs-Logs
│   └── docs/generated/     # Auto-generierte Dokumentation
└── src/                    # Source-Code (im Projekt-Root)
```

### Wichtige Features

- **Autonomer Entwicklungs-Loop** - Kontinuierliche Ausführung von Claude Code
- **Intelligente Exit-Erkennung** - Dual-Condition-Check (Completion-Indikatoren + EXIT_SIGNAL)
- **Session-Kontinuität** - Erhält Kontext über Loop-Iterationen hinweg
- **Rate-Limiting** - Eingebaute API-Call-Verwaltung (Standard: 100 Calls/Stunde)
- **Circuit-Breaker** - Erweiterte Fehlererkennung mit automatischer Wiederherstellung
- **Live-Monitoring** - Echtzeit-Dashboard mit Loop-Status und Fortschritt
- **5-Stunden-API-Limit-Handling** - Erkennt Claude's 5-Stunden-Limit und bietet Warte-/Exit-Optionen

### Deinstallation

```bash
# Im Ralph-Repository-Verzeichnis
./uninstall.sh

# Oder wenn Repository gelöscht wurde:
curl -sL https://raw.githubusercontent.com/frankbria/ralph-claude-code/main/uninstall.sh | bash
```

### Weitere Informationen

- **Dokumentation**: Siehe [GitHub Repository](https://github.com/frankbria/ralph-claude-code) für vollständige Dokumentation
- **Version**: Aktuell v0.10.1 (Active Development)
- **Lizenz**: MIT

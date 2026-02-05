# Zed Config

Zentrale Zed-Editor-Konfiguration für die Dotfiles.

## Struktur

```
zed/
  .config/zed/
    settings.json     # Einstellungen (mit $schema)
    keymap.json       # Tastaturkürzel
    tasks.json        # Globale Tasks
    snippets/         # Code Snippets
      snippets.json   # Globale Snippets
```

## Installation

```bash
# Über install.sh oder manuell:
cd ~/.dotfiles && stow zed
```

## Dateien öffnen in Zed

| Datei | Shortcut | Command Palette |
|-------|----------|-----------------|
| settings.json | `Cmd+,` | `zed: open settings` |
| keymap.json | `Cmd+K Cmd+S` | `zed: open keymap` |
| tasks.json | - | `zed: open tasks` |
| snippets/ | - | `snippets: open folder` |

---

## settings.json

Schema: `https://zed.dev/schema/settings.json`

Alle Einstellungen: https://zed.dev/docs/reference/all-settings

---

## keymap.json

Dokumentation: https://zed.dev/docs/key-bindings

### Struktur

```json
[
  {
    "context": "Editor",
    "bindings": {
      "cmd-shift-d": "editor::DuplicateLine"
    }
  }
]
```

### Contexts

| Context | Beschreibung |
|---------|--------------|
| `Editor` | Im Text-Editor |
| `Workspace` | Allgemein |
| `Terminal` | Im Terminal |
| `ProjectPanel` | Datei-Baum |
| `Pane` | Editor Pane |

### Key Syntax

- Modifiers: `cmd`, `ctrl`, `alt`, `shift`
- Kombinieren: `cmd-shift-p`
- Sequenzen: `cmd-k cmd-s`

### Beispiele

```json
[
  {
    "context": "Editor",
    "bindings": {
      "cmd-shift-d": "editor::DuplicateLine",
      "cmd-shift-k": "editor::DeleteLine",
      "cmd-shift-l": "editor::SelectAllMatches"
    }
  },
  {
    "context": "Terminal",
    "bindings": {
      "cmd-k": "terminal::Clear"
    }
  }
]
```

---

## tasks.json

Dokumentation: https://zed.dev/docs/tasks

### Struktur

```json
[
  {
    "label": "Task Name",
    "command": "command to run",
    "cwd": "$ZED_WORKTREE_ROOT",
    "reveal": "always"
  }
]
```

### Properties

| Property | Beschreibung |
|----------|--------------|
| `label` | Anzeigename (required) |
| `command` | Shell-Befehl (required) |
| `args` | Argument-Array |
| `cwd` | Arbeitsverzeichnis |
| `env` | Environment-Variablen |
| `reveal` | `always` / `never` |
| `hide` | `always` / `never` / `on_success` |

### Variablen

| Variable | Beschreibung |
|----------|--------------|
| `$ZED_WORKTREE_ROOT` | Projekt-Root |
| `$ZED_FILE` | Aktuelle Datei |
| `$ZED_FILENAME` | Dateiname |
| `$ZED_DIRNAME` | Verzeichnis |
| `$ZED_STEM` | Dateiname ohne Extension |
| `$ZED_SELECTED_TEXT` | Markierter Text |

### Beispiele

```json
[
  {
    "label": "npm install",
    "command": "npm install",
    "cwd": "$ZED_WORKTREE_ROOT"
  },
  {
    "label": "go run",
    "command": "go run $ZED_FILE"
  },
  {
    "label": "cargo build",
    "command": "cargo build",
    "cwd": "$ZED_WORKTREE_ROOT"
  },
  {
    "label": "docker compose up",
    "command": "docker compose up -d",
    "hide": "on_success"
  }
]
```

---

## snippets/

Dokumentation: https://zed.dev/docs/snippets

### Struktur

Erstelle sprachspezifische Dateien:
- `snippets.json` - Global (alle Sprachen)
- `javascript.json`, `typescript.json`
- `python.json`, `rust.json`, `go.json`
- `html.json`, `css.json`, `markdown.json`

### Format

```json
{
  "Snippet Name": {
    "prefix": "trigger",
    "body": "expanded text",
    "description": "Beschreibung"
  }
}
```

### Placeholders

| Syntax | Beschreibung |
|--------|--------------|
| `$1`, `$2` | Tab-Stops |
| `${1:default}` | Mit Default-Wert |
| `${1\|a,b,c\|}` | Mit Auswahl |
| `$0` | Finale Cursor-Position |
| `$TM_FILENAME` | Dateiname |
| `$CLIPBOARD` | Clipboard-Inhalt |
| `$CURRENT_YEAR` | Aktuelles Jahr |

### Beispiele

```json
{
  "Console Log": {
    "prefix": "cl",
    "body": "console.log('$1:', $1);$0",
    "description": "Console log mit Label"
  },
  "TODO": {
    "prefix": "todo",
    "body": "// TODO: $1$0",
    "description": "TODO Kommentar"
  },
  "Insert Date": {
    "prefix": "date",
    "body": "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE",
    "description": "Aktuelles Datum"
  }
}
```

---

## Extensions

Extensions werden in `~/Library/Application Support/Zed/extensions/` gespeichert.

Auto-Install in settings.json:

```json
{
  "auto_install_extensions": {
    "catppuccin": true,
    "docker-compose": true
  }
}
```

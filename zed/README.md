# Zed Config

Central Zed editor configuration for the dotfiles.

## Structure

```
zed/
  .config/zed/
    settings.json     # Settings (with $schema)
    keymap.json       # Keyboard shortcuts
    tasks.json        # Global tasks
    snippets/         # Code snippets
      snippets.json   # Global snippets
```

## Installation

```bash
# Via install.sh or manually:
cd ~/.dotfiles && stow zed
```

## Opening Files in Zed

| File | Shortcut | Command Palette |
|------|----------|-----------------|
| settings.json | `Cmd+,` | `zed: open settings` |
| keymap.json | `Cmd+K Cmd+S` | `zed: open keymap` |
| tasks.json | - | `zed: open tasks` |
| snippets/ | - | `snippets: open folder` |

---

## settings.json

Schema: `https://zed.dev/schema/settings.json`

All settings: https://zed.dev/docs/reference/all-settings

---

## keymap.json

Documentation: https://zed.dev/docs/key-bindings

### Structure

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

| Context | Description |
|---------|-------------|
| `Editor` | In text editor |
| `Workspace` | General |
| `Terminal` | In terminal |
| `ProjectPanel` | File tree |
| `Pane` | Editor pane |

### Key Syntax

- Modifiers: `cmd`, `ctrl`, `alt`, `shift`
- Combining: `cmd-shift-p`
- Sequences: `cmd-k cmd-s`

### Examples

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

Documentation: https://zed.dev/docs/tasks

### Structure

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

| Property | Description |
|----------|-------------|
| `label` | Display name (required) |
| `command` | Shell command (required) |
| `args` | Argument array |
| `cwd` | Working directory |
| `env` | Environment variables |
| `reveal` | `always` / `never` |
| `hide` | `always` / `never` / `on_success` |

### Variables

| Variable | Description |
|----------|-------------|
| `$ZED_WORKTREE_ROOT` | Project root |
| `$ZED_FILE` | Current file |
| `$ZED_FILENAME` | Filename |
| `$ZED_DIRNAME` | Directory |
| `$ZED_STEM` | Filename without extension |
| `$ZED_SELECTED_TEXT` | Selected text |

### Examples

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

Documentation: https://zed.dev/docs/snippets

### Structure

Create language-specific files:
- `snippets.json` - Global (all languages)
- `javascript.json`, `typescript.json`
- `python.json`, `rust.json`, `go.json`
- `html.json`, `css.json`, `markdown.json`

### Format

```json
{
  "Snippet Name": {
    "prefix": "trigger",
    "body": "expanded text",
    "description": "Description"
  }
}
```

### Placeholders

| Syntax | Description |
|--------|-------------|
| `$1`, `$2` | Tab stops |
| `${1:default}` | With default value |
| `${1\|a,b,c\|}` | With choices |
| `$0` | Final cursor position |
| `$TM_FILENAME` | Filename |
| `$CLIPBOARD` | Clipboard content |
| `$CURRENT_YEAR` | Current year |

### Examples

```json
{
  "Console Log": {
    "prefix": "cl",
    "body": "console.log('$1:', $1);$0",
    "description": "Console log with label"
  },
  "TODO": {
    "prefix": "todo",
    "body": "// TODO: $1$0",
    "description": "TODO comment"
  },
  "Insert Date": {
    "prefix": "date",
    "body": "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE",
    "description": "Current date"
  }
}
```

---

## Extensions

Extensions are stored in `~/Library/Application Support/Zed/extensions/`.

Auto-install in settings.json:

```json
{
  "auto_install_extensions": {
    "catppuccin": true,
    "docker-compose": true
  }
}
```

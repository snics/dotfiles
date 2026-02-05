# Cursor Config

Zentrale Cursor-IDE-Konfiguration für die Dotfiles.

## Struktur

```
cursor/
  Library/Application Support/Cursor/User/   # macOS
    settings.json     # Cursor-Einstellungen (JSON-Objekt)
    keybindings.json  # Tastaturkürzel (JSON-Array)
  .cursor/
    mcp.json          # MCP-Server (Secrets nur via ${env:VAR_NAME})
    cli-config.json   # Cursor-CLI-Konfiguration
```

**Hinweis:** Cursor auf macOS nutzt `~/Library/Application Support/Cursor/User/`. Unter Linux ist es `~/.config/cursor/user/` — ggf. manuell verlinken oder anpassen.

## Installation

- Über `install.sh`: Bei der Frage „Do you want to use Cursor config?“ mit `y` antworten.
- Manuell: `stow cursor` aus `~/.dotfiles` ausführen.

## MCP & Secrets

- In `mcp.json` **keine** echten API-Keys oder Tokens eintragen.
- Stattdessen: `${env:VAR_NAME}` verwenden (z.B. `"Authorization": "Bearer ${env:CONTEXT7_API_KEY}"`).
- Die Variablen in `~/.secrets` exportieren; `~/.zshrc` lädt `~/.secrets`.
- Siehe `docs/opencode-cursor-mcp.md` und `.secrets.example`.

## Bestehende Config übernehmen

Die aktuellen Configs (Settings, Keybindings, MCP) sind bereits aus Cursor übernommen. Bei `stow cursor` werden u.a. verlinkt:

- `~/Library/Application Support/Cursor/User/settings.json`
- `~/Library/Application Support/Cursor/User/keybindings.json`
- `~/.cursor/mcp.json`, `~/.cursor/cli-config.json`

**Context7 in mcp.json:** Der API-Key steht als `${env:CONTEXT7_API_KEY}`. Bitte in `~/.secrets` eintragen:  
`export CONTEXT7_API_KEY="dein-key"`

---

## MCP-Server (Hinweise)

| Server | Typ | Hinweis |
|--------|-----|---------|
| **linear** | Remote via mcp-remote | OAuth/Token-Flow kann beim ersten Aufruf aufpoppen. |
| **exa** | Lokal (npx) | `EXA_API_KEY` in `~/.secrets`. |
| **grep_app** | Remote (HTTP) | Kein Auth. |
| **context7** (remote) | Remote | `CONTEXT7_API_KEY` in `~/.secrets`. |
| **serena** | Lokal (uvx) | Braucht `uv`/`uvx` (z. B. `pip install uv` oder Installer von astral.sh). |
| **playwright** | Lokal (npx) | Ggf. `npx playwright install` für Browsers. |
| **screencap** | Lokal (uv) | `SCREENCAP_PATH` = absoluter Pfad zum screencap-Projekt (inkl. `.venv`). |
| **git** | Lokal (npx) | Kein Secret. |

---

## Checkliste: Secrets & Tools

### Secrets (in `~/.secrets` eintragen)

- [ ] `EXA_API_KEY` — Exa / exa-mcp-server
- [ ] `CONTEXT7_API_KEY` — Context7 (remote)
- [ ] `SCREENCAP_PATH` — Absoluter Pfad zum screencap-Projekt (nur bei Nutzung von screencap)

### Tools (vor Nutzung der jeweiligen MCP-Server)

- [ ] **Node/npx** — Für linear, exa, playwright, git. (z. B. über asdf, nvm, Homebrew.)
- [ ] **uv / uvx** — Für serena (`uvx`), screencap (`uv`). Z. B. `curl -LsSf https://astral.sh/uv/install.sh | sh` oder `pip install uv`.
- [ ] **git** — Für git-MCP (üblicherweise schon installiert).
- [ ] **playwright** — Ggf. nach Erststart: `npx playwright install` (Browser-Binaries).
- [ ] **screencap** — Repo klonen, `uv sync` o. Ä., dann `SCREENCAP_PATH` auf dieses Verzeichnis setzen.

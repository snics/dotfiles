# OpenCode, Cursor & MCP — Konfiguration in Dotfiles

Zentraler Leitfaden: Wo Konfiguration und Secrets liegen, wie du sie in den Dotfiles ablegst, und **Best Practices für MCP-Server inkl. Secrets**.

---

## 1. OpenCode

### Konfigurationsorte (Priorität: niedrig → hoch)

| Priorität | Quelle | Pfad / Umgebung |
|-----------|--------|------------------|
| 1 | Remote (Org) | `.well-known/opencode` (z.B. über HTTP) |
| 2 | **Global (Dotfiles)** | `~/.config/opencode/opencode.json` |
| 3 | Custom | `OPENCODE_CONFIG` → Pfad zu JSON |
| 4 | Projekt | `opencode.json` / `opencode.jsonc` im Projektroot |
| 5 | Projekt | `.opencode/` (Agents, Commands, Plugins) |
| 6 | Inline | `OPENCODE_CONFIG_CONTENT` (Runtime-Override) |

### Was in die Dotfiles gehört

- **Ja:** `~/.config/opencode/opencode.json` (Theme, Modelle, MCP-Basis, Permissions, TUI, …)
- **Ja:** `~/.config/opencode/themes/*.json` (eigene Themes)
- **Nein:** `~/.local/share/opencode/` — enthält:
  - `auth.json` (API Keys, Tokens)
  - `mcp-auth.json` (OAuth-Tokens für MCP)
  - `log/`, `project/` (Session-Daten, Logs)

### MCP in OpenCode (`opencode.json`)

Secrets **niemals** direkt in die Config schreiben. Stattdessen:

- **Syntax:** `{env:VAR_NAME}` (z.B. `{env:SENTRY_CLIENT_ID}`)
- Env-Variablen in `~/.secrets` setzen; `~/.zshrc` lädt `~/.secrets` vor allem anderen.

**Beispiel lokaler MCP-Server (mit Secret über Env):**

```jsonc
{
  "mcp": {
    "my-local-server": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-fetch"],
      "enabled": true,
      "environment": {
        "API_KEY": "{env:MY_MCP_API_KEY}"
      },
      "timeout": 10000
    }
  }
}
```

**Beispiel Remote-MCP (Header mit Secret):**

```jsonc
"mcp": {
  "context7": {
    "type": "remote",
    "url": "https://mcp.context7.com/mcp",
    "headers": {
      "Authorization": "Bearer {env:CONTEXT7_API_KEY}"
    },
    "enabled": true
  }
}
```

### Dotfiles-Struktur

```
opencode/
  .config/opencode/
    opencode.json
    themes/
      catppuccin-*.json
```

Installation: `stow opencode` (über `_install/opencode.sh`).

---

## 2. Cursor

### Konfigurationsorte

| Zweck | macOS | Linux | Windows |
|-------|-------|-------|---------|
| Einstellungen | `~/Library/Application Support/Cursor/User/settings.json` | `~/.config/cursor/user/settings.json` | `%APPDATA%\Cursor\User\` |
| Tastatur | (ebenda `keybindings.json`) | (ebenda) | (ebenda) |
| CLI | `~/.cursor/cli-config.json` | (gleich) | `%USERPROFILE%\.cursor\` |
| **MCP (global)** | `~/.cursor/mcp.json` | (gleich) | `%USERPROFILE%\.cursor\mcp.json` |
| MCP (pro Projekt) | `.cursor/mcp.json` im Projektroot | (gleich) | (gleich) |
| Rules | `.cursor/rules/` im Projekt | (gleich) | (gleich) |

### Was in die Dotfiles gehört

- **Ja:** `~/.config/cursor/user/settings.json`, `keybindings.json`
- **Ja:** `~/.cursor/mcp.json` (mit `${env:…}` für Secrets)
- **Ja:** `~/.cursor/cli-config.json`, falls Cursor-CLI genutzt wird
- **Nein:** Cache, Logs, Extensions

### MCP in Cursor (`mcp.json`)

- **Syntax für Env:** `${env:VAR_NAME}` (z.B. `${env:ANTHROPIC_API_KEY}`)
- Platzhalter: `${workspaceFolder}`, `${userHome}`, `${workspaceFolderBasename}`, `${pathSeparator}`, `${/}`

**Beispiel stdio-Server mit Secret:**

```json
{
  "mcpServers": {
    "fetch": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {
        "API_KEY": "${env:FETCH_MCP_API_KEY}"
      }
    }
  }
}
```

**Beispiel Remote-Server mit Auth-Header:**

```json
{
  "mcpServers": {
    "remote": {
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${env:MY_MCP_SERVICE_TOKEN}"
      }
    }
  }
}
```

### Dotfiles-Struktur

**macOS** (Cursor liest aus `~/Library/Application Support/Cursor/User/`):

```
cursor/
  Library/Application Support/Cursor/User/
    settings.json
    keybindings.json
  .cursor/
    mcp.json
    cli-config.json
```

**Linux:** Cursor nutzt `~/.config/cursor/user/` — ggf. dieselben Dateien dorthin verlinken oder eine zweite Stow-Struktur anlegen.

Installation: `stow cursor` (über `_install/cursor.sh`).

---

## 3. MCP-Server: Umgang mit Secrets (Best Practices)

### 3.1 Nie in Repo / Dotfiles

- Keine API-Keys, Tokens, Passwörter in `opencode.json`, `mcp.json`, `cli-config.json`.
- Nur Env-Referenzen: `{env:…}` (OpenCode) und `${env:…}` (Cursor).

### 3.2 Zentrale Stelle: `~/.secrets`

- MCP-relevante Env-Variablen in `~/.secrets` exportieren.
- `~/.zshrc` lädt `~/.secrets`; in der Shell sind sie verfügbar.

**Beispiel `~/.secrets` (Ausschnitt):**

```bash
# MCP / Cursor / OpenCode
export CONTEXT7_API_KEY="…"
export SENTRY_CLIENT_ID="…"
export SENTRY_CLIENT_SECRET="…"
export MY_MCP_SERVICE_TOKEN="…"
export FETCH_MCP_API_KEY="…"
```

`.secrets.example` listet nur die **Namen** (ohne Werte) als Reminder.

### 3.3 Cursor aus GUI (Dock, Spotlight)

- Cursor erbt **keine** Shell-Env → kein `~/.secrets`.
- **Optionen:** Cursor aus dem Terminal starten (`cursor .`), oder `launchctl setenv`, oder 1Password/CLI / Wrapper.

### 3.4 MCP-Sicherheit

- **Least Privilege:** API-Keys nur mit nötigen Scopes.
- **Lokal bevorzugen:** stdio/lokal statt Remote.
- **TLS:** Remote-MCP nur HTTPS.
- **Kein Logging von Secrets.**
- **Rotation:** Keys regelmäßig rotieren.

### 3.5 Global vs. Projekt

- **Global:** `~/.cursor/mcp.json`, `~/.config/opencode/opencode.json` — gemeinsame Server.
- **Projekt:** `.cursor/mcp.json`, `opencode.json` — projektspezifische Server.
- Secrets nur über Env; Projekt-Config enthält nur `{env:…}` / `${env:…}`.

---

## 4. Kurz-Checkliste

- [ ] `stow opencode` (opencode-Config in Dotfiles verlinkt)
- [ ] `stow cursor` (Cursor-Config in Dotfiles verlinkt)
- [ ] In MCP-Configs nur `{env:…}` (OpenCode) und `${env:…}` (Cursor)
- [ ] Env-Variablen in `~/.secrets`; `.secrets` von Shell geladen
- [ ] `~/.local/share/opencode/` **nicht** in Dotfiles
- [ ] `.secrets` in `.gitignore`; nur `.secrets.example` im Repo

---

## 5. Referenzen

- [OpenCode Config](https://opencode.ai/docs/config/)
- [OpenCode MCP-Server](https://opencode.ai/docs/mcp-servers/)
- [Cursor MCP / Context](https://docs.cursor.com/context/mcp)
- [Cursor CLI Config](https://docs.cursor.com/cli/reference/configuration)
- [MCP-Spec](https://modelcontextprotocol.io/)
- [MCP Security Best Practices](https://modelcontextprotocol.io/specification/draft/basic/security_best_practices)

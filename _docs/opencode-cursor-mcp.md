# OpenCode, Cursor & MCP — Configuration in Dotfiles

Central guide: Where configuration and secrets are located, how to store them in the dotfiles, and **best practices for MCP servers including secrets**.

---

## 1. OpenCode

### Configuration Locations (Priority: low → high)

| Priority | Source | Path / Environment |
|----------|--------|-------------------|
| 1 | Remote (Org) | `.well-known/opencode` (e.g., via HTTP) |
| 2 | **Global (Dotfiles)** | `~/.config/opencode/opencode.json` |
| 3 | Custom | `OPENCODE_CONFIG` → path to JSON |
| 4 | Project | `opencode.json` / `opencode.jsonc` in project root |
| 5 | Project | `.opencode/` (Agents, Commands, Plugins) |
| 6 | Inline | `OPENCODE_CONFIG_CONTENT` (runtime override) |

### What Belongs in the Dotfiles

- **Yes:** `~/.config/opencode/opencode.json` (theme, models, MCP base, permissions, TUI, …)
- **Yes:** `~/.config/opencode/themes/*.json` (custom themes)
- **No:** `~/.local/share/opencode/` — contains:
  - `auth.json` (API keys, tokens)
  - `mcp-auth.json` (OAuth tokens for MCP)
  - `log/`, `project/` (session data, logs)

### MCP in OpenCode (`opencode.json`)

**Never** write secrets directly in the config. Instead:

- **Syntax:** `{env:VAR_NAME}` (e.g., `{env:SENTRY_CLIENT_ID}`)
- Set env variables in `~/.secrets`; `~/.zshrc` loads `~/.secrets` before anything else.

**Example local MCP server (with secret via env):**

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

**Example remote MCP (header with secret):**

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

### Dotfiles Structure

```
opencode/
  .config/opencode/
    opencode.json
    themes/
      catppuccin-*.json
```

Installation: `stow opencode` (via `_install/opencode.sh`).

---

## 2. Cursor

### Configuration Locations

| Purpose | macOS | Linux | Windows |
|---------|-------|-------|---------|
| Settings | `~/Library/Application Support/Cursor/User/settings.json` | `~/.config/cursor/user/settings.json` | `%APPDATA%\Cursor\User\` |
| Keybindings | (same location `keybindings.json`) | (same) | (same) |
| CLI | `~/.cursor/cli-config.json` | (same) | `%USERPROFILE%\.cursor\` |
| **MCP (global)** | `~/.cursor/mcp.json` | (same) | `%USERPROFILE%\.cursor\mcp.json` |
| MCP (per project) | `.cursor/mcp.json` in project root | (same) | (same) |
| Rules | `.cursor/rules/` in project | (same) | (same) |

### What Belongs in the Dotfiles

- **Yes:** `~/.config/cursor/user/settings.json`, `keybindings.json`
- **Yes:** `~/.cursor/mcp.json` (with `${env:…}` for secrets)
- **Yes:** `~/.cursor/cli-config.json`, if using Cursor CLI
- **No:** Cache, logs, extensions

### MCP in Cursor (`mcp.json`)

- **Env syntax:** `${env:VAR_NAME}` (e.g., `${env:ANTHROPIC_API_KEY}`)
- Placeholders: `${workspaceFolder}`, `${userHome}`, `${workspaceFolderBasename}`, `${pathSeparator}`, `${/}`

**Example stdio server with secret:**

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

**Example remote server with auth header:**

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

### Dotfiles Structure

**macOS** (Cursor reads from `~/Library/Application Support/Cursor/User/`):

```
cursor/
  Library/Application Support/Cursor/User/
    settings.json
    keybindings.json
  .cursor/
    mcp.json
    cli-config.json
```

**Linux:** Cursor uses `~/.config/cursor/user/` — either symlink the same files there or create a second Stow structure.

Installation: `stow cursor` (via `_install/cursor.sh`).

---

## 3. MCP Servers: Handling Secrets (Best Practices)

### 3.1 Never in Repo / Dotfiles

- No API keys, tokens, passwords in `opencode.json`, `mcp.json`, `cli-config.json`.
- Only env references: `{env:…}` (OpenCode) and `${env:…}` (Cursor).

### 3.2 Central Location: `~/.secrets`

- Export MCP-relevant env variables in `~/.secrets`.
- `~/.zshrc` loads `~/.secrets`; they're available in the shell.

**Example `~/.secrets` (excerpt):**

```bash
# MCP / Cursor / OpenCode
export CONTEXT7_API_KEY="…"
export SENTRY_CLIENT_ID="…"
export SENTRY_CLIENT_SECRET="…"
export MY_MCP_SERVICE_TOKEN="…"
export FETCH_MCP_API_KEY="…"
```

`.secrets.example` lists only the **names** (without values) as a reminder.

### 3.3 Cursor from GUI (Dock, Spotlight)

- Cursor does **not** inherit shell env → no `~/.secrets`.
- **Options:** Start Cursor from terminal (`cursor .`), or use `launchctl setenv`, or 1Password/CLI / wrapper.

### 3.4 MCP Security

- **Least privilege:** API keys only with necessary scopes.
- **Prefer local:** stdio/local over remote.
- **TLS:** Remote MCP only via HTTPS.
- **No logging of secrets.**
- **Rotation:** Rotate keys regularly.

### 3.5 Global vs. Project

- **Global:** `~/.cursor/mcp.json`, `~/.config/opencode/opencode.json` — shared servers.
- **Project:** `.cursor/mcp.json`, `opencode.json` — project-specific servers.
- Secrets only via env; project config contains only `{env:…}` / `${env:…}`.

---

## 4. Quick Checklist

- [ ] `stow opencode` (opencode config linked in dotfiles)
- [ ] `stow cursor` (Cursor config linked in dotfiles)
- [ ] In MCP configs only `{env:…}` (OpenCode) and `${env:…}` (Cursor)
- [ ] Env variables in `~/.secrets`; `.secrets` loaded by shell
- [ ] `~/.local/share/opencode/` **not** in dotfiles
- [ ] `.secrets` in `.gitignore`; only `.secrets.example` in repo

---

## 5. References

- [OpenCode Config](https://opencode.ai/docs/config/)
- [OpenCode MCP Servers](https://opencode.ai/docs/mcp-servers/)
- [Cursor MCP / Context](https://docs.cursor.com/context/mcp)
- [Cursor CLI Config](https://docs.cursor.com/cli/reference/configuration)
- [MCP Spec](https://modelcontextprotocol.io/)
- [MCP Security Best Practices](https://modelcontextprotocol.io/specification/draft/basic/security_best_practices)

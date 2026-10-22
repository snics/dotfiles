# Cursor & MCP — Configuration in Dotfiles

Central guide: Where configuration and secrets are located, how to store them in the dotfiles, and **best practices for MCP servers including secrets**.

---

## 1. Cursor

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

Installation: `just cursor` or `stow cursor`.

---

## 2. MCP Servers: Handling Secrets (Best Practices)

### 2.1 Never in Repo / Dotfiles

- No API keys, tokens, passwords in `mcp.json`, `cli-config.json`.
- Only env references: `${env:…}`.

### 2.2 Central Location: `~/.secrets`

- Export MCP-relevant env variables in `~/.secrets`.
- `~/.zshrc` loads `~/.secrets`; they're available in the shell.

**Example `~/.secrets` (excerpt):**

```bash
# MCP / Cursor
export CONTEXT7_API_KEY="…"
export SENTRY_CLIENT_ID="…"
export SENTRY_CLIENT_SECRET="…"
export MY_MCP_SERVICE_TOKEN="…"
export FETCH_MCP_API_KEY="…"
```

`.secrets.example` lists only the **names** (without values) as a reminder.

### 2.3 Cursor from GUI (Dock, Spotlight)

- Cursor does **not** inherit shell env → no `~/.secrets`.
- **Options:** Start Cursor from terminal (`cursor .`), or use `launchctl setenv`, or 1Password/CLI / wrapper.

### 2.4 MCP Security

- **Least privilege:** API keys only with necessary scopes.
- **Prefer local:** stdio/local over remote.
- **TLS:** Remote MCP only via HTTPS.
- **No logging of secrets.**
- **Rotation:** Rotate keys regularly.

### 2.5 Global vs. Project

- **Global:** `~/.cursor/mcp.json` — shared servers.
- **Project:** `.cursor/mcp.json` — project-specific servers.
- Secrets only via env; project config contains only `${env:…}`.

---

## 3. Quick Checklist

- [ ] `stow cursor` (Cursor config linked in dotfiles)
- [ ] In MCP configs only `${env:…}`
- [ ] Env variables in `~/.secrets`; `.secrets` loaded by shell
- [ ] `.secrets` in `.gitignore`; only `.secrets.example` in repo

---

## 4. References

- [Cursor MCP / Context](https://docs.cursor.com/context/mcp)
- [Cursor CLI Config](https://docs.cursor.com/cli/reference/configuration)
- [MCP Spec](https://modelcontextprotocol.io/)
- [MCP Security Best Practices](https://modelcontextprotocol.io/specification/draft/basic/security_best_practices)

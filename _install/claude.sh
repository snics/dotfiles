#!/usr/bin/env bash

echo -e "Install Claude CLI config...."

# Symlink claude config (mcp-servers.json etc.)
stow claude

# settings.json is intentionally NOT symlinked: Claude Code rewrites it in place
# (atomic rename) on every config change, which destroys the stow symlink and
# leaves the repo copy stale. Bootstrap-copy the template if none exists yet;
# afterwards sync the live file back into the repo with `just claude-sync`.
SETTINGS_SRC="$(dirname "${BASH_SOURCE[0]}")/../claude/.claude/settings.json"
SETTINGS_DST="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
if [ ! -e "$SETTINGS_DST" ]; then
    cp "$SETTINGS_SRC" "$SETTINGS_DST"
    echo -e "  settings.json copied to ~/.claude/"
else
    echo -e "  settings.json already exists — left untouched (use 'just claude-sync' to update the repo)"
fi

# Merge MCP servers into ~/.claude.json
CLAUDE_JSON="$HOME/.claude.json"
MCP_CONFIG="$(dirname "${BASH_SOURCE[0]}")/../claude/mcp-servers.json"

if command -v jq &>/dev/null; then
    if [ -f "$CLAUDE_JSON" ]; then
        # Merge MCP servers into existing config
        jq --argjson mcp "$(cat "$MCP_CONFIG")" '.mcpServers = ($mcp * (.mcpServers // {}))' "$CLAUDE_JSON" > "${CLAUDE_JSON}.tmp" \
            && mv "${CLAUDE_JSON}.tmp" "$CLAUDE_JSON"
        echo -e "  MCP servers merged into ~/.claude.json"
    else
        # Create new file with just MCP servers
        jq -n --argjson mcp "$(cat "$MCP_CONFIG")" '{ mcpServers: $mcp }' > "$CLAUDE_JSON"
        echo -e "  ~/.claude.json created with MCP servers"
    fi
else
    echo -e "  WARNING: jq not found — skipping MCP server setup"
    echo -e "  Install jq and re-run, or manually add MCP servers to ~/.claude.json"
fi

echo -e "Install Claude CLI config done!"

#!/usr/bin/env bash

echo -e "Install Claude CLI config...."

# Symlink settings.json (plugins)
stow claude

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

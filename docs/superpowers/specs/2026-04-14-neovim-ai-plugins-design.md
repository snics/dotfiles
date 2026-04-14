# NeoVim AI Plugin Setup Design

Restructure NeoVim AI plugins into three non-overlapping layers: code completion,
multi-agent chat, and passive IDE context bridging.

## Current State

- `codecompanion.nvim` — ACP chat (Claude/Codex/Gemini/OpenCode) + OpenRouter HTTP inline
- `windsurf.nvim` — Codeium code completion (ghost text)
- Auth issues: claude-code-acp 401, codex-acp auth error, OpenRouter inline "adapter not found"

## Architecture: 3 Layers

```
Layer 1: Code Completion (Ghost Text)
  └─ windsurf.nvim (Codeium) — unchanged

Layer 2: AI Chat (Multi-Agent)
  └─ codecompanion.nvim
     ├─ ACP Chat: Claude Code, Codex, Gemini CLI, OpenCode
     ├─ HTTP Inline: OpenRouter (for inline editing / cmd strategy)
     └─ HTTP Chat Fallback: Anthropic / OpenRouter

Layer 3: IDE Context Bridge (passive, no UI)
  └─ claudecode.nvim (NEW)
     └─ WebSocket MCP Server auto-starts with NeoVim
     └─ Claude Code CLI connects automatically when running
     └─ Provides: buffer list, selections, diagnostics, file tree
     └─ Receives: diff proposals → accept/reject in NeoVim
```

No two layers overlap in functionality. Each has a single responsibility.

## Plugin 1: `claudecode.nvim` (NEW — coder/claudecode.nvim)

**Role:** Passive context provider. No chat UI, no keybindings needed for daily use.
Makes NeoVim a first-class Claude Code IDE (same protocol as VS Code extension).

**How it works:**
1. Plugin starts a WebSocket MCP server on a random port
2. Writes lock file to `~/.claude/ide/[port].lock` (contains port + auth token)
3. Claude Code CLI discovers the lock file and connects (use `claude --ide` if manual)
4. NeoVim sends real-time context: open buffers, cursor position, selections, LSP diagnostics
5. When Claude proposes file changes, NeoVim shows native diff views

**Auth:** Reuses existing `claude` CLI OAuth automatically. No API key needed.

**Dependencies:** `folke/snacks.nvim` (already installed — used as terminal provider)

**Configuration:**
```lua
{
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
        terminal = {
            provider = "snacks",
            snacks_win_opts = {
                position = "float",
            },
        },
    },
    keys = {
        { "<leader>aC", "<cmd>ClaudeCode<CR>", desc = "Claude Code Terminal" },
    },
}
```

**Single keybinding:** `<leader>aC` opens/toggles Claude Code CLI in a floating
terminal inside NeoVim. This is optional — Claude Code can also run in an external
terminal and still connects via the WebSocket bridge.

## Plugin 2: `codecompanion.nvim` (UPDATE)

**Changes from current config:**

### Auth Fix

The ACP agents need one-time CLI authentication:
```bash
# Claude Code ACP: creates OAuth token, then set env var
claude setup-token
# Copy the output token and add to shell env:
# export CLAUDE_CODE_OAUTH_TOKEN="<token>"

# Codex: run codex CLI, select "Sign in with ChatGPT" interactively
codex

# Gemini: run gemini CLI, follow "Sign in with Google" prompt
gemini
```

Note: `claude setup-token` output must be manually set as `CLAUDE_CODE_OAUTH_TOKEN`
in the shell environment (e.g., via `zsh/.secrets.tpl`). Codex and Gemini store
their tokens automatically after interactive login.

### Keybinding Alignment with Zed

Current `<leader>a` keybindings are restructured to match Zed's AI shortcuts:

| Key | Action | Zed Equivalent |
|-----|--------|---------------|
| `<leader>aa` | CodeCompanion Chat Toggle | `space a a` (Agent Panel) |
| `<leader>aA` | New Chat | `space a shift-a` (New Thread) |
| `<leader>ai` | Inline Edit (normal) | `space a i` (Inline Assist) |
| `<leader>ai` | Inline Edit (visual) | `space a i` (Inline Assist) |
| `<leader>ac` | Chat with Claude Code (ACP) | `space a c` (Claude ACP) |
| `<leader>ag` | Chat with Gemini (ACP) | `space a g` (Gemini ACP) |
| `<leader>ax` | Chat with Codex (ACP) | `space a x` (Codex ACP) |
| `<leader>ao` | Chat with OpenCode (ACP) | `space a o` (OpenCode ACP) |
| `<leader>ap` | Action Palette | `space a p` (Profile Selector) |
| `<leader>aC` | Claude Code Terminal (claudecode.nvim) | — (NeoVim exclusive) |
| `<leader>aw` | Toggle Windsurf Virtual Text | — (NeoVim exclusive) |
| `<leader>ae` | Explain Code (visual) | — |
| `<leader>af` | Fix Code (visual) | — |
| `<leader>at` | Generate Tests (visual) | — |
| `<leader>ar` | Review Code (visual) | — |
| `<leader>ad` | Document Code (normal) | — |

**Removed:** `<leader>aV` (Windsurf ON) and `<leader>ax` (Windsurf OFF) — replaced
by `<leader>aw` toggle and `<leader>ax` now maps to Codex (Zed consistency).

### Adapter Config Update

The codecompanion adapter config stays mostly the same. Key changes:
- Remove the `acp_setup` auto-install helpers (agents should be pre-installed)
- Verify OpenRouter inline strategy works after plugin update to latest
- If OpenRouter inline still fails, fallback inline strategy to `"anthropic"`

### Strategy Config

```lua
strategies = {
    chat = { adapter = "claude_code" },    -- ACP (default chat agent)
    inline = { adapter = "openrouter" },   -- HTTP (for inline edits)
    cmd = { adapter = "openrouter" },      -- HTTP (for /cmd)
},
```

## Plugin 3: `windsurf.nvim` (MINIMAL CHANGE)

Only keybinding changes:
- `<leader>av` → `<leader>aw` (Toggle Windsurf Virtual Text) — frees `<leader>av` prefix
- Remove `<leader>aV` (ON) and `<leader>ax` (OFF) — `<leader>ax` is now Codex
- Keep `<C-l>` accept, `<C-Right>` accept word, `<C-Down>` accept line (unchanged)

## which-key Updates

Update the AI group description and add agent-specific icons if desired:
```lua
{ "<leader>a", group = "AI", icon = "󰚩" },
```

No subgroup needed — the keybindings are flat under `<leader>a`.

## Files Changed

| File | Action | Changes |
|------|--------|---------|
| `nvim/.config/nvim/lua/plugins/claudecode.lua` | Create | New plugin config for coder/claudecode.nvim |
| `nvim/.config/nvim/lua/plugins/codecompanion.lua` | Modify | Restructure keybindings, remove auto-install helpers |
| `nvim/.config/nvim/lua/plugins/windsurf.lua` | Modify | Change toggle keybinding from `<leader>av` to `<leader>aw` |
| `nvim/.config/nvim/lua/plugins/which-key.lua` | Modify | No structural changes needed (AI group already exists) |
| `_docs/keybindings.md` | Modify | Update AI keybindings section |

## Testing

1. Open NeoVim — verify all 3 plugins load without errors
2. Run `:ClaudeCode` — verify Claude Code terminal opens
3. Open a second terminal, run `claude` — verify it discovers NeoVim WebSocket
4. `<leader>aa` — verify CodeCompanion chat opens
5. `<leader>ac` — verify Claude Code ACP chat starts (requires `CLAUDE_CODE_OAUTH_TOKEN`)
6. `<leader>ag` — verify Gemini chat starts (requires `gemini` login)
7. `<leader>ax` — verify Codex chat starts (requires Codex CLI sign-in)
8. Select code, `<leader>ai` — verify inline edit works via OpenRouter
9. `<leader>aw` — verify Windsurf virtual text toggles
10. Verify `<C-l>` still accepts Windsurf completions

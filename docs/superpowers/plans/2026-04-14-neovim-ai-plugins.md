# NeoVim AI Plugin Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `claudecode.nvim` as passive IDE bridge, restructure `codecompanion.nvim` keybindings for Zed consistency, and adjust `windsurf.nvim` keybindings to avoid conflicts.

**Architecture:** Three non-overlapping layers: windsurf (completion), codecompanion (multi-agent chat), claudecode (IDE context bridge). Each plugin has a single responsibility. Keybindings under `<leader>a` aligned with Zed's `space a` group.

**Tech Stack:** NeoVim 0.12.1, Lua, lazy.nvim, ACP protocol, WebSocket MCP

**Design Spec:** `docs/superpowers/specs/2026-04-14-neovim-ai-plugins-design.md`

---

## Verification Command

Run after every task:
```bash
nvim --headless -c 'lua local errors = {}; local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/**/*.lua", false, true); for _, f in ipairs(files) do local ok, err = loadfile(f); if not ok then table.insert(errors, f .. ": " .. err) end end; if #errors > 0 then for _, e in ipairs(errors) do print("ERROR: " .. e) end; os.exit(1) else print("OK: All " .. #files .. " Lua files parse successfully") end; os.exit(0)'
```

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `nvim/.config/nvim/lua/plugins/claudecode.lua` | Create | claudecode.nvim plugin config |
| `nvim/.config/nvim/lua/plugins/codecompanion.lua` | Modify | Restructure keybindings, remove auto-install |
| `nvim/.config/nvim/lua/plugins/windsurf.lua` | Modify | Change toggle keybinding |
| `_docs/keybindings.md` | Modify | Update AI keybindings section |

---

### Task 1: Add `claudecode.nvim` Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/claudecode.lua`

- [ ] **Step 1: Create the plugin config**

Create `nvim/.config/nvim/lua/plugins/claudecode.lua`:

```lua
-- claudecode.nvim — Passive IDE context bridge for Claude Code CLI.
-- Starts a WebSocket MCP server so Claude Code sees NeoVim buffers,
-- selections, and diagnostics (same protocol as VS Code extension).
-- No chat UI — use codecompanion.nvim for chat, this is the context layer.
return {
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

- [ ] **Step 2: Run verification**

```bash
nvim --headless -c 'lua local ok, err = loadfile(vim.fn.stdpath("config") .. "/lua/plugins/claudecode.lua"); if ok then print("OK: claudecode.lua parses") else print("ERROR: " .. err) end; os.exit(ok and 0 or 1)'
```
Expected: `OK: claudecode.lua parses`

- [ ] **Step 3: Commit**

```bash
git add nvim/.config/nvim/lua/plugins/claudecode.lua
git commit -m "✨ feat(nvim): add claudecode.nvim for Claude Code IDE integration"
```

---

### Task 2: Restructure `codecompanion.nvim` Keybindings

**Files:**
- Modify: `nvim/.config/nvim/lua/plugins/codecompanion.lua`

- [ ] **Step 1: Replace the `keys` table**

In `nvim/.config/nvim/lua/plugins/codecompanion.lua`, replace the entire `keys = { ... }` block (lines 18-39) with:

```lua
    keys = {
        -- Chat
        { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>",   desc = "Toggle AI chat",           mode = "n" },
        { "<leader>aA", "<cmd>CodeCompanionChat<cr>",          desc = "New AI chat",              mode = "n" },

        -- ACP Agent Shortcuts (consistent with Zed: space a c/g/x/o)
        { "<leader>ac", "<cmd>CodeCompanionChat claude_code<cr>", desc = "Chat with Claude (ACP)", mode = "n" },
        { "<leader>ag", "<cmd>CodeCompanionChat gemini_cli<cr>",  desc = "Chat with Gemini (ACP)", mode = "n" },
        { "<leader>ax", "<cmd>CodeCompanionChat codex<cr>",       desc = "Chat with Codex (ACP)",  mode = "n" },
        { "<leader>ao", "<cmd>CodeCompanionChat opencode<cr>",    desc = "Chat with OpenCode (ACP)", mode = "n" },

        -- Action palette
        { "<leader>ap", "<cmd>CodeCompanionActions<cr>",       desc = "AI action palette",        mode = { "n", "v" } },

        -- Inline edit
        { "<leader>ai", "<cmd>CodeCompanion<cr>",              desc = "AI inline edit",           mode = "n" },
        { "<leader>ai", ":'<,'>CodeCompanion<cr>",             desc = "AI inline edit selection", mode = "v" },

        -- Quick prompts (visual mode)
        { "<leader>ae", ":'<,'>CodeCompanion /explain<cr>",    desc = "AI explain code",          mode = "v" },
        { "<leader>af", ":'<,'>CodeCompanion /fix<cr>",        desc = "AI fix code",              mode = "v" },
        { "<leader>at", ":'<,'>CodeCompanion /tests<cr>",      desc = "AI generate tests",        mode = "v" },
        { "<leader>ar", ":'<,'>CodeCompanion Review this code for potential improvements<cr>", desc = "AI review code", mode = "v" },

        -- Quick prompts (normal mode)
        { "<leader>ad", "<cmd>CodeCompanion Add documentation for the function under the cursor<cr>", desc = "AI document code", mode = "n" },
    },
```

- [ ] **Step 2: Remove `acp_setup` helper functions**

In the same file, find the `ensure_npm` function (lines 41-55) and the `acp_setup` function (lines 57-66). Remove both functions entirely.

Then in the adapters section, simplify the `claude_code` and `codex` adapters by removing the `handlers = { setup = acp_setup(...) }` calls.

Replace the `claude_code` adapter (around line 71-74):
```lua
                claude_code = function()
                    return require("codecompanion.adapters").resolve("claude_code")
                end,
```

Replace the `codex` adapter (around line 83-85):
```lua
                codex = function()
                    return require("codecompanion.adapters").resolve("codex")
                end,
```

- [ ] **Step 3: Remove the `/commit` keybinding**

Find and remove this line (it was `<leader>ac` before, now `<leader>ac` is Claude ACP):
```lua
        { "<leader>ac", "<cmd>CodeCompanion /commit<cr>",                                             desc = "AI commit message",        mode = "n" },
```

The `/commit` action is still available via the action palette (`<leader>ap`).

- [ ] **Step 4: Run verification**

```bash
nvim --headless -c 'lua local ok, err = loadfile(vim.fn.stdpath("config") .. "/lua/plugins/codecompanion.lua"); if ok then print("OK") else print("ERROR: " .. err) end; os.exit(ok and 0 or 1)'
```
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add nvim/.config/nvim/lua/plugins/codecompanion.lua
git commit -m "🔄 refactor(nvim): restructure codecompanion keybindings for Zed consistency"
```

---

### Task 3: Adjust `windsurf.nvim` Keybindings

**Files:**
- Modify: `nvim/.config/nvim/lua/plugins/windsurf.lua`

- [ ] **Step 1: Change keybindings**

In `nvim/.config/nvim/lua/plugins/windsurf.lua`, find the keymaps section (around line 89-92):

Old:
```lua
        vim.keymap.set("n", "<leader>av", "<cmd>WindsurfVirtualTextToggle<CR>",
            { desc = "Toggle virtual text" })
        vim.keymap.set("n", "<leader>aV", "<cmd>WindsurfVirtualTextOn<CR>", { desc = "Virtual text ON" })
        vim.keymap.set("n", "<leader>ax", "<cmd>WindsurfVirtualTextOff<CR>", { desc = "Virtual text OFF" })
```

New:
```lua
        vim.keymap.set("n", "<leader>aw", "<cmd>WindsurfVirtualTextToggle<CR>",
            { desc = "Toggle Windsurf virtual text" })
```

(Remove `<leader>aV` and `<leader>ax` — `<leader>ax` is now Codex ACP, and a single toggle is sufficient.)

- [ ] **Step 2: Run verification**

```bash
nvim --headless -c 'lua local ok, err = loadfile(vim.fn.stdpath("config") .. "/lua/plugins/windsurf.lua"); if ok then print("OK") else print("ERROR: " .. err) end; os.exit(ok and 0 or 1)'
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add nvim/.config/nvim/lua/plugins/windsurf.lua
git commit -m "🔧 chore(nvim): remap windsurf toggle to <leader>aw, free <leader>ax for Codex"
```

---

### Task 4: Update Keybindings Cheatsheet

**Files:**
- Modify: `_docs/keybindings.md`

- [ ] **Step 1: Update AI section**

Read `_docs/keybindings.md` and find the AI keybindings section. Replace/update to reflect:

New keybindings:
- `<leader>aC` — Claude Code Terminal (claudecode.nvim, floating window)
- `<leader>ac` — Chat with Claude Code (ACP, via codecompanion)
- `<leader>ag` — Chat with Gemini (ACP, via codecompanion)
- `<leader>ax` — Chat with Codex (ACP, via codecompanion)
- `<leader>ao` — Chat with OpenCode (ACP, via codecompanion)
- `<leader>aw` — Toggle Windsurf Virtual Text

Changed keybindings:
- `<leader>av` (old Windsurf toggle) → `<leader>aw`
- `<leader>ax` (old Windsurf OFF) → now Codex ACP chat
- `<leader>ac` (old AI commit) → now Claude Code ACP chat (commit via `<leader>ap` palette)

Removed:
- `<leader>aV` (Windsurf ON) — use `<leader>aw` toggle
- `<leader>ax` (Windsurf OFF) — use `<leader>aw` toggle

Follow the existing format/style of the document.

- [ ] **Step 2: Commit**

```bash
git add _docs/keybindings.md
git commit -m "📝 docs(nvim): update AI keybindings in cheatsheet"
```

---

### Task 5: Full Verification

- [ ] **Step 1: Run full Lua syntax + plugin load check**

```bash
nvim --headless -c 'lua local errors = {}; local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/**/*.lua", false, true); for _, f in ipairs(files) do local ok, err = loadfile(f); if not ok then table.insert(errors, f .. ": " .. err) end end; if #errors > 0 then for _, e in ipairs(errors) do print("ERROR: " .. e) end; os.exit(1) else print("OK: All " .. #files .. " Lua files parse successfully") end; os.exit(0)' && nvim --headless -c 'lua vim.defer_fn(function() local errors = {}; for name, plugin in pairs(require("lazy.core.config").plugins) do if plugin._.has_errors then table.insert(errors, name .. ": load error") end end; if #errors > 0 then for _, e in ipairs(errors) do print("ERROR: " .. e) end; os.exit(1) else print("OK: All plugins loaded without errors") end; os.exit(0) end, 3000)'
```
Expected: Both `OK`

- [ ] **Step 2: Verify no keybinding conflicts**

```bash
nvim --headless -c 'lua vim.defer_fn(function() local maps = vim.api.nvim_get_keymap("n"); local ai = {}; for _, m in ipairs(maps) do if m.lhs:match("^%sa") then table.insert(ai, m.lhs .. " -> " .. (m.desc or m.rhs or "?")) end end; for _, m in ipairs(ai) do print(m) end; os.exit(0) end, 3000)' 2>&1 | sort
```
Expected: Each `<leader>a*` key appears exactly once (no duplicates).

- [ ] **Step 3: Commit lazy-lock if updated**

```bash
git diff --name-only | grep lazy-lock && git add nvim/.config/nvim/lazy-lock.json && git commit -m "🔄 chore(nvim): update lazy-lock with claudecode.nvim" || echo "No lazy-lock changes"
```

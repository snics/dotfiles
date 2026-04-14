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

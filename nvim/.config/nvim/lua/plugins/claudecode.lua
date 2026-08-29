-- claudecode.nvim — Passive IDE context bridge for Claude Code CLI.
-- Starts a WebSocket MCP server so Claude Code sees NeoVim buffers,
-- selections, and diagnostics (same protocol as VS Code extension).
-- terminal.provider = "external": the claude agent runs in a herdr pane
-- (not an editor float) and connects to this bridge via /ide — subscription
-- auth works because it is the real claude CLI. Diff review still happens
-- in NeoVim. No chat UI — use codecompanion.nvim for chat.
return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
        terminal = {
            provider = "external",
        },
    },
    keys = {
        { "<leader>aC", "<cmd>ClaudeCodeStatus<CR>", desc = "Claude Code bridge status" },
        { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude Code" },
        { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept Claude Code diff" },
        { "<leader>an", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Deny Claude Code diff" },
    },
}

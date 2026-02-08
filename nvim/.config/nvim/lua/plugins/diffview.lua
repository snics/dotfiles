-- Note: unmaintained since June 2024, but still works well.
return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
        { "<leader>gv", "<cmd>DiffviewOpen<CR>",          desc = "Git diff view" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Git file history" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<CR>",   desc = "Git branch history" },
        { "<leader>gx", "<cmd>DiffviewClose<CR>",         desc = "Close diff view" },
    },
    opts = {
        enhanced_diff_hl = true,                     -- default: false — better word-level diff highlighting
        show_help_hints = false,                     -- default: true — hide hint bar at bottom
        view = {
            merge_tool = { layout = "diff3_mixed" }, -- default: "diff3_horizontal" — 2 top + 1 bottom
        },
    },
}

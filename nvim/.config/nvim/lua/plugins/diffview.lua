-- Note: unmaintained since June 2024, but still works well.
return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
        { "<leader>gvv", "<cmd>DiffviewOpen<CR>",          desc = "Open diffview" },
        { "<leader>gvh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
        { "<leader>gvH", "<cmd>DiffviewFileHistory<CR>",   desc = "Branch history" },
        { "<leader>gvx", "<cmd>DiffviewClose<CR>",         desc = "Close diffview" },
    },
    opts = {
        enhanced_diff_hl = true,                     -- default: false — better word-level diff highlighting
        show_help_hints = false,                     -- default: true — hide hint bar at bottom
        view = {
            merge_tool = { layout = "diff3_mixed" }, -- default: "diff3_horizontal" — 2 top + 1 bottom
        },
    },
}

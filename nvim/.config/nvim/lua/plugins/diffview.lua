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
        enhanced_diff_hl = true,
        view = {
            default = { layout = "diff2_horizontal" },
            merge_tool = { layout = "diff3_mixed" },
        },
    },
}

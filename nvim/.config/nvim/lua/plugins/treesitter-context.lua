return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        max_lines = 3,
        trim_scope = "outer",
    },
    keys = {
        { "<leader>ux", function() require("treesitter-context").toggle() end,                    desc = "Toggle Treesitter Context" },
        { "[x",         function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Jump to context" },
    },
}

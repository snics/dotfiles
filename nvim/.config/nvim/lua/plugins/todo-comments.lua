-- todo-comments.nvim — highlight and search TODO/FIX/HACK/etc. comments
--
-- Keywords (all defaults): FIX, TODO, HACK, WARN, PERF, NOTE, TEST
-- Colors below are Catppuccin Mocha overrides (defaults are generic hex values)
return {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "]t",         function() require("todo-comments").jump_next() end,                                   desc = "Next todo comment" },
        { "[t",         function() require("todo-comments").jump_prev() end,                                   desc = "Previous todo comment" },
        { "<leader>st", function() Snacks.picker.todo_comments() end,                                          desc = "Todo" },
        { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
    opts = {
        -- Catppuccin Mocha color overrides (defaults: generic hex like #DC2626, #FBBF24, etc.)
        colors = {
            error = { "DiagnosticError", "ErrorMsg", "#f38ba8" },
            warning = { "DiagnosticWarn", "WarningMsg", "#f9e2af" },
            info = { "DiagnosticInfo", "#74c7ec" },
            hint = { "DiagnosticHint", "#a6e3a1" },
            default = { "Identifier", "#cba6f7" },
            test = { "Identifier", "#f5c2e7" },
        },
    },
}

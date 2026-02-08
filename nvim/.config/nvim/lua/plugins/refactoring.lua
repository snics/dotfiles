return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        { "<leader>rr",  function() require("refactoring").select_refactor() end,                    desc = "Select refactor",          mode = { "n", "x" } },
        { "<leader>re",  function() require("refactoring").refactor("Extract Function") end,         desc = "Extract Function",         mode = "x" },
        { "<leader>rf",  function() require("refactoring").refactor("Extract Function To File") end, desc = "Extract Function To File", mode = "x" },
        { "<leader>rv",  function() require("refactoring").refactor("Extract Variable") end,         desc = "Extract Variable",         mode = "x" },
        { "<leader>ri",  function() require("refactoring").refactor("Inline Variable") end,          desc = "Inline Variable",          mode = { "n", "x" } },
        { "<leader>rI",  function() require("refactoring").refactor("Inline Function") end,          desc = "Inline Function",          mode = { "n", "x" } },
        { "<leader>rb",  function() require("refactoring").refactor("Extract Block") end,            desc = "Extract Block" },
        { "<leader>rbf", function() require("refactoring").refactor("Extract Block To File") end,    desc = "Extract Block To File" },
        { "<leader>rp",  function() require("refactoring").debug.print_var() end,                    desc = "Debug Print Variable",     mode = { "n", "x" } },
        { "<leader>rP",  function() require("refactoring").debug.printf() end,                       desc = "Debug Printf" },
        { "<leader>rc",  function() require("refactoring").debug.cleanup() end,                      desc = "Debug Cleanup" },
    },
    opts = {},
}

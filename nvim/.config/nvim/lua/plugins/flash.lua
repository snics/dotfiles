return {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
        -- 52 label chars (default: 26 lowercase only)
        labels = "asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM",

        label = {
            after = { 0, 0 }, -- default: true — place labels directly on match position
        },

        search = {
            incremental = true, -- default: false — update results as you type
        },

        remote_op = {
            restore = true, -- default: false — restore window/cursor after remote op
            motion = true, -- default: false — allow new motion in remote window
        },

        modes = {
            search = {
                enabled = true, -- default: false — enable flash during / and ? search
                search = {
                    mode = "fuzzy", -- default: inherits "exact" — fuzzy matching for search
                },
            },
            char = {
                jump_labels = true, -- default: false — show labels on f/F/t/T matches
            },
        },
    },
    -- stylua: ignore
    keys = {
        -- Core navigation
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
        { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

        -- Enhanced f/F/t/T — custom jump() calls that bypass modes.char for max_length=1 behavior
        {
            "f",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump({
                    search = { mode = "search", max_length = 1 },
                    label = { after = { 0, 0 } },
                })
            end,
            desc = "Flash f"
        },
        {
            "F",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump({
                    search = { mode = "search", max_length = 1, forward = false },
                    label = { after = { 0, 0 } },
                })
            end,
            desc = "Flash F"
        },
        {
            "t",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump({
                    search = { mode = "search", max_length = 1 },
                    jump = { offset = 1 },
                })
            end,
            desc = "Flash t"
        },
        {
            "T",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump({
                    search = { mode = "search", max_length = 1, forward = false },
                    jump = { offset = -1 },
                })
            end,
            desc = "Flash T"
        },

        -- Operator mode
        { "r",     mode = { "o" },      function() require("flash").remote() end,            desc = "Remote Flash" },
        { "R",     mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },

        -- Toggle flash during command-line search
        { "<c-s>", mode = { "c" },      function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
}

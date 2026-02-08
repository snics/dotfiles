return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",

        -- Language adapters
        "fredrikaverpil/neotest-golang", -- Go (table tests, testify, monorepo)
        "marilari88/neotest-vitest",     -- TypeScript/JS (Vitest)
        "nvim-neotest/neotest-jest",     -- TypeScript/JS (Jest)
        "arthur944/neotest-bun",         -- Bun test runner
        "mrcjkb/rustaceanvim",           -- Rust (built-in neotest adapter)
    },
    keys = {
        { "<leader>tt", function() require("neotest").run.run() end,                        desc = "Run nearest test" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,      desc = "Run file tests" },
        { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end,            desc = "Run all tests" },
        { "<leader>ts", function() pcall(require("neotest").summary.toggle) end,            desc = "Toggle test summary" },
        { "<leader>to", function() require("neotest").output.open({ enter = true }) end,    desc = "Show test output" },
        { "<leader>tp", function() pcall(require("neotest").output_panel.toggle) end,       desc = "Toggle output panel" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,    desc = "Debug nearest test" },
        { "<leader>tS", function() require("neotest").run.stop() end,                       desc = "Stop running tests" },
        { "<leader>tl", function() require("neotest").run.run_last() end,                   desc = "Re-run last test" },
        { "]T",         function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
        { "[T",         function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-golang"),
                require("rustaceanvim.neotest"),
                require("neotest-vitest"),
                require("neotest-jest"),
                require("neotest-bun"),
            },
            -- Custom icons (defaults: ✓, ✘, ◐, ⊘, ?)
            icons = {
                failed = "✖",
                passed = "✔",
                running = "⟳",
                skipped = "○",
                unknown = "?", -- default
            },
            status = {
                virtual_text = true, -- default: false — show test results as virtual text
                -- enabled = true,              -- default
                -- signs = true,                -- default
            },
            output = {
                open_on_run = false, -- default: "short" — don't auto-open output window
                -- enabled = true,              -- default
            },
            -- summary: animated and expand_errors are defaults, no overrides needed
        })
    end,
}

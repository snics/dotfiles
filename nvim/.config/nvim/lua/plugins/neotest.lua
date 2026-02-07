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
        { "<leader>Tt", function() require("neotest").run.run() end,                        desc = "Run nearest test" },
        { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end,      desc = "Run file tests" },
        { "<leader>Ta", function() require("neotest").run.run(vim.uv.cwd()) end,            desc = "Run all tests" },
        { "<leader>Ts", function() pcall(require("neotest").summary.toggle) end,            desc = "Toggle test summary" },
        { "<leader>To", function() require("neotest").output.open({ enter = true }) end,    desc = "Show test output" },
        { "<leader>Tp", function() pcall(require("neotest").output_panel.toggle) end,       desc = "Toggle output panel" },
        { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end,    desc = "Debug nearest test" },
        { "<leader>TS", function() require("neotest").run.stop() end,                       desc = "Stop running tests" },
        { "<leader>Tl", function() require("neotest").run.run_last() end,                   desc = "Re-run last test" },
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
            -- Status signs in the sign column
            icons = {
                failed = "✖",
                passed = "✔",
                running = "⟳",
                skipped = "○",
                unknown = "?",
            },
            -- Show test status in diagnostics
            status = {
                enabled = true,
                virtual_text = true,
                signs = true,
            },
            -- Floating output window settings
            output = {
                enabled = true,
                open_on_run = false,
            },
            -- Summary panel settings
            summary = {
                animated = true,
                expand_errors = true,
            },
        })
    end,
}

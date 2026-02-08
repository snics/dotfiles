-- Go development tools: struct tags, test generation, interface impl, if-err, go mod
-- Available config: log_level, timeout, commands (go/gomodifytags/gotests/impl/iferr),
--   gotests (template/template_dir/named), gotag (transform/default_tag), iferr (message)
-- All defaults are fine — only override if needed.
return {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    keys = {
        -- Struct Tags
        { "<leader>gtj", "<cmd>GoTagAdd json<cr>", desc = "Add json tags",              ft = "go" },
        { "<leader>gty", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml tags",              ft = "go" },
        { "<leader>gtx", "<cmd>GoTagAdd xml<cr>",  desc = "Add xml tags",               ft = "go" },
        { "<leader>gtr", "<cmd>GoTagRm<cr>",       desc = "Remove tags",                ft = "go" },

        -- Test Generation
        { "<leader>gta", "<cmd>GoTestAdd<cr>",     desc = "Generate test for function", ft = "go" },
        { "<leader>gtA", "<cmd>GoTestsAll<cr>",    desc = "Generate all tests",         ft = "go" },
        { "<leader>gte", "<cmd>GoTestsExp<cr>",    desc = "Generate exported tests",    ft = "go" },

        -- Go Modules
        { "<leader>gmt", "<cmd>GoMod tidy<cr>",    desc = "go mod tidy",                ft = "go" },
        {
            "<leader>gmi",
            function()
                vim.ui.input({ prompt = "Module name: " }, function(input)
                    if input then vim.cmd("GoMod init " .. input) end
                end)
            end,
            desc = "go mod init",
            ft = "go"
        },
        {
            "<leader>gmg",
            function()
                vim.ui.input({ prompt = "Package to get: " }, function(input)
                    if input then vim.cmd("GoGet " .. input) end
                end)
            end,
            desc = "go get",
            ft = "go"
        },

        -- Interface Implementation
        {
            "<leader>gii",
            function()
                vim.ui.input({ prompt = "Interface to implement: " }, function(input)
                    if input then vim.cmd("GoImpl " .. input) end
                end)
            end,
            desc = "Implement interface",
            ft = "go"
        },

        -- Error Handling & Code Gen
        { "<leader>gie", "<cmd>GoIfErr<cr>",      desc = "Generate if err != nil", ft = "go" },
        { "<leader>gc",  "<cmd>GoCmt<cr>",        desc = "Generate doc comment",   ft = "go" },
        { "<leader>gg",  "<cmd>GoGenerate<cr>",   desc = "go generate",            ft = "go" },
        { "<leader>gG",  "<cmd>GoGenerate %<cr>", desc = "go generate (file)",     ft = "go" },
    },
}

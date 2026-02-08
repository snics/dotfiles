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
        { "<leader>Gtj", "<cmd>GoTagAdd json<cr>", desc = "Add json tags",              ft = "go" },
        { "<leader>Gty", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml tags",              ft = "go" },
        { "<leader>Gtx", "<cmd>GoTagAdd xml<cr>",  desc = "Add xml tags",               ft = "go" },
        { "<leader>Gtr", "<cmd>GoTagRm<cr>",       desc = "Remove tags",                ft = "go" },

        -- Test Generation
        { "<leader>Gta", "<cmd>GoTestAdd<cr>",     desc = "Generate test for function", ft = "go" },
        { "<leader>GtA", "<cmd>GoTestsAll<cr>",    desc = "Generate all tests",         ft = "go" },
        { "<leader>Gte", "<cmd>GoTestsExp<cr>",    desc = "Generate exported tests",    ft = "go" },

        -- Go Modules
        { "<leader>Gmt", "<cmd>GoMod tidy<cr>",    desc = "go mod tidy",                ft = "go" },
        {
            "<leader>Gmi",
            function()
                vim.ui.input({ prompt = "Module name: " }, function(input)
                    if input then vim.cmd("GoMod init " .. input) end
                end)
            end,
            desc = "go mod init",
            ft = "go"
        },
        {
            "<leader>Gmg",
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
            "<leader>Gii",
            function()
                vim.ui.input({ prompt = "Interface to implement: " }, function(input)
                    if input then vim.cmd("GoImpl " .. input) end
                end)
            end,
            desc = "Implement interface",
            ft = "go"
        },

        -- Error Handling & Code Gen
        { "<leader>Gie", "<cmd>GoIfErr<cr>",      desc = "Generate if err != nil", ft = "go" },
        { "<leader>Gc",  "<cmd>GoCmt<cr>",        desc = "Generate doc comment",   ft = "go" },
        { "<leader>Gg",  "<cmd>GoGenerate<cr>",   desc = "go generate",            ft = "go" },
        { "<leader>GG",  "<cmd>GoGenerate %<cr>", desc = "go generate (file)",     ft = "go" },
    },
}

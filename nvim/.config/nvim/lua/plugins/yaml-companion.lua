return {
    "mosheavni/yaml-companion.nvim",
    ft = { "yaml", "yml" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "b0o/schemastore.nvim",
    },
    keys = {
        -- Schema management
        {
            "<leader>ys",
            function() require("yaml-companion").open_ui_select() end,
            desc = "Select YAML schema",
            ft = "yaml",
        },
        {
            "<leader>yS",
            function()
                local schema = require("yaml-companion").get_buf_schema(0)
                if schema.result[1].name == "none" then
                    vim.notify("No schema active", vim.log.levels.INFO)
                else
                    vim.notify("Schema: " .. schema.result[1].name, vim.log.levels.INFO)
                end
            end,
            desc = "Show current YAML schema",
            ft = "yaml",
        },
        -- CRD features
        { "<leader>yd", "<cmd>YamlBrowseDatreeSchemas<cr>", desc = "Browse Datree CRD schemas",  ft = "yaml" },
        { "<leader>yc", "<cmd>YamlBrowseClusterCRDs<cr>",   desc = "Browse cluster CRD schemas", ft = "yaml" },
        { "<leader>ym", "<cmd>YamlAddCRDModelines<cr>",     desc = "Add CRD schema modelines",   ft = "yaml" },
        -- Key navigation
        { "<leader>yQ", "<cmd>YamlKeys<cr>",                desc = "YAML keys to quickfix",      ft = "yaml" },
    },
    config = function()
        local yamlls_config = require("config.lsp.servers.yamlls").config
        local capabilities = require("config.lsp").capabilities

        local cfg = require("yaml-companion").setup({
            builtin_matchers = {
                kubernetes = { enabled = true },
                cloud_init = { enabled = true },
            },

            keys = { enabled = true },

            cluster_crds = {
                enabled = true,
                fallback = true, -- auto-fallback to cluster when Datree unavailable
            },

            modeline = {
                validate_urls = true, -- required when fallback = true
                notify = true,
            },

            lspconfig = vim.tbl_deep_extend("force", yamlls_config, {
                capabilities = capabilities,
            }),
        })

        vim.lsp.config("yamlls", cfg)
        vim.lsp.enable("yamlls")
    end,
}

return {
    "mosheavni/yaml-companion.nvim",
    ft = { "yaml", "yml" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "b0o/schemastore.nvim",
    },
    keys = {
        { "<leader>ys", "<cmd>YamlBrowseDatreeSchemas<cr>", desc = "Browse YAML schemas (Datree)", ft = "yaml" },
        { "<leader>yc", "<cmd>YamlBrowseClusterCRDs<cr>",   desc = "Browse cluster CRD schemas",   ft = "yaml" },
        { "<leader>ym", "<cmd>YamlAddCRDModelines<cr>",     desc = "Add CRD schema modelines",     ft = "yaml" },
        { "<leader>yK", "<cmd>YamlKeys<cr>",                desc = "YAML keys to quickfix",        ft = "yaml" },
    },
    config = function()
        -- Load existing yamlls server configuration
        local yamlls_config = require("config.lsp.servers.yamlls").config
        local capabilities = require("config.lsp").capabilities

        local cfg = require("yaml-companion").setup({
            -- Built-in matchers for auto-detection
            builtin_matchers = {
                kubernetes = { enabled = true },
                cloud_init = { enabled = true },
            },

            -- YAML key navigation via :YamlKeys
            keys = { enabled = true },

            -- Cluster CRD browsing via :YamlBrowseClusterCRDs / :YamlFetchClusterCRD
            cluster_crds = { enabled = true },

            -- Merge our existing yamlls settings
            lspconfig = vim.tbl_deep_extend("force", yamlls_config, {
                capabilities = capabilities,
            }),
        })

        -- Apply config and enable yamlls (managed here instead of config.lsp.init)
        vim.lsp.config("yamlls", cfg)
        vim.lsp.enable("yamlls")
    end,
}

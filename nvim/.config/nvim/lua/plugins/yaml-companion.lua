return {
    "mosheavni/yaml-companion.nvim",
    ft = { "yaml", "yml" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "b0o/schemastore.nvim",
    },
    keys = {
        { "<leader>ys", "<cmd>YAMLSchemaSelect<cr>", desc = "Select YAML schema",       ft = "yaml" },
        { "<leader>yS", "<cmd>YAMLSchemaView<cr>",   desc = "View current YAML schema", ft = "yaml" },
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

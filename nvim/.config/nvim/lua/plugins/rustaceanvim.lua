return {
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false, -- plugin is already lazy
    ft = { "rust" },
    init = function()
        vim.g.rustaceanvim = {
            -- LSP settings (rust-analyzer managed by rustaceanvim, not mason-lspconfig)
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = true,
                        check = {
                            command = "clippy",
                        },
                        cargo = {
                            allFeatures = true,
                        },
                        procMacro = {
                            enable = true,
                        },
                    },
                },
            },
            -- DAP integration (uses codelldb if available via mason)
            dap = {},
            -- Enable neotest adapter
            tools = {
                test_executor = "neotest",
            },
        }
    end,
}

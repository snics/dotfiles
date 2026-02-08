-- Rust development plugin (manages rust-analyzer, DAP, and tools).
-- Uses vim.g.rustaceanvim for configuration (no setup() call needed).
--
-- Available options:
--   server.default_settings  — rust-analyzer settings (checkOnSave, cargo, procMacro, etc.)
--   server.on_attach          — callback for Rust-specific keymaps
--   server.standalone         — default: false — standalone file support
--   server.auto_attach        — default: true if rust-analyzer found
--   server.cmd                — default: auto-detect rust-analyzer
--   server.capabilities       — LSP capabilities (e.g. from cmp_nvim_lsp)
--   tools.test_executor       — default: "termopen" — test runner backend
--   tools.crate_test_executor — default: "termopen" — crate-level test runner
--   tools.float_win_config    — default: {} — floating window options
--   dap.adapter               — default: auto-detect codelldb from mason
--   dap.configuration         — default: auto-detect
--   dap.autoload_configurations — default: true
return {
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false, -- plugin is already lazy (ftplugin)
    -- Note: Do NOT add ft = { "rust" } here — rustaceanvim is a filetype plugin
    -- and manages its own lazy-loading. Adding ft causes double-loading issues.
    init = function()
        vim.g.rustaceanvim = {
            -- LSP settings (rust-analyzer managed by rustaceanvim, not mason-lspconfig)
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = true,     -- default: true
                        check = {
                            command = "clippy", -- default: "check" — use clippy for better lints
                        },
                        cargo = {
                            allFeatures = true, -- default: false — enable all features for analysis
                        },
                        procMacro = {
                            enable = true, -- default: true
                        },
                    },
                },
                on_attach = function(_, bufnr)
                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { desc = desc, buffer = bufnr, silent = true })
                    end
                    -- Rust-specific keymaps (via :RustLsp command)
                    map("n", "<leader>re", function() vim.cmd.RustLsp("expandMacro") end, "Expand macro")
                    map("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo") end, "Open Cargo.toml")
                    map("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "Parent module")
                    map("n", "<leader>rd", function() vim.cmd.RustLsp("renderDiagnostic") end, "Render diagnostic")
                    map("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Runnables")
                    map("n", "<leader>rD", function() vim.cmd.RustLsp("debuggables") end, "Debuggables")
                    map("n", "<leader>rj", function() vim.cmd.RustLsp("joinLines") end, "Join lines")
                    map("n", "<leader>ra", function() vim.cmd.RustLsp("codeAction") end, "Rust code action")
                end,
            },
            -- DAP integration (auto-detects codelldb from mason if available)
            -- dap.adapter, dap.configuration: auto-detected
            -- dap.autoload_configurations = true (default)
            tools = {
                test_executor = "neotest",       -- default: "termopen" — route to neotest
                crate_test_executor = "neotest", -- default: "termopen" — route crate tests too
            },
        }
    end,
}

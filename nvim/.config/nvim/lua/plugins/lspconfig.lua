-- LSP configuration: keymaps on attach + diagnostic display settings.
-- Server setup is handled in config/lsp.lua (called from mason.lua).
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        { "folke/lazydev.nvim", opts = {} },
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { desc = desc, buffer = ev.buf, silent = true })
                end

                map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
                map("n", "K", vim.lsp.buf.hover, "Hover documentation")
                map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
                map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
                map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
                map("n", "<leader>ls", "<cmd>LspRestart<CR>", "Restart LSP")

                -- IncRename integration (expr keymap)
                vim.keymap.set("n", "<leader>cr", function()
                    return ":IncRename " .. vim.fn.expand("<cword>")
                end, { desc = "Smart rename", buffer = ev.buf, silent = true, expr = true })
            end,
        })

        -- ========================================================================
        -- DIAGNOSTIC CONFIGURATION (Single Source of Truth)
        -- All diagnostic display settings are centralized here.
        -- Do NOT add vim.diagnostic.config() calls in other plugin files.
        -- Referenced by: tiny-inline-diagnostic.lua, none-ls.lua
        -- ========================================================================
        vim.diagnostic.config({
            virtual_text = false, -- default: true — disabled, tiny-inline-diagnostic handles this
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "󰅚 ",
                    [vim.diagnostic.severity.WARN] = "󰀪 ",
                    [vim.diagnostic.severity.HINT] = "󰌶 ",
                    [vim.diagnostic.severity.INFO] = "󰋽 ",
                },
            },
            update_in_insert = false, -- default: false
            underline = true,         -- default: true
            severity_sort = true,     -- default: false — show errors above warnings
        })
    end,
}

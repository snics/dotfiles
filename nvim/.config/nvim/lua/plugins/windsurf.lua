return {
    "Exafunction/windsurf.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("codeium").setup({
            virtual_text = {
                enabled = true,                   -- default: false — enable virtual text infrastructure
                default_filetype_enabled = false, -- default: true — we control via toggle commands below
                key_bindings = {
                    accept = "<C-l>",             -- default: <Tab>
                    accept_word = "<C-Right>",    -- default: false (not bound)
                    accept_line = "<C-Down>",     -- default: false (not bound)
                    clear = "<M-c>",              -- default: false (not bound)
                    -- next = "<M-]>",              -- default: <M-]> (same)
                    -- prev = "<M-[>",              -- default: <M-[> (same)
                },
                filetypes = {}, -- start empty (controlled by toggle commands)
            },
            workspace_root = {
                paths = {
                    ".git", ".hg", ".svn", ".bzr", "_FOSSIL_",
                    "package.json",
                    "Cargo.toml",       -- added (not in defaults)
                    "go.mod",           -- added (not in defaults)
                    "pyproject.toml",   -- added (not in defaults)
                    "requirements.txt", -- added (not in defaults)
                },
            },
        })

        -- Session-scoped virtual text toggle (default OFF)
        vim.g.windsurf_virtual_text_enabled = false

        -- Get access to the codeium config to modify filetypes dynamically
        local codeium_config = require('codeium.config')

        local function _windsurf_apply_vt_autocmds()
            if vim.g.windsurf_virtual_text_enabled then
                -- Enable virtual text by setting filetypes
                codeium_config.options.virtual_text.filetypes = {
                    lua = true,
                    javascript = true,
                    typescript = true,
                    python = true,
                    go = true,
                    rust = true,
                    html = true,
                    css = true,
                    yaml = true,
                    markdown = true,
                }
                codeium_config.options.virtual_text.default_filetype_enabled = true
            else
                -- Disable virtual text by clearing filetypes
                codeium_config.options.virtual_text.filetypes = {}
                codeium_config.options.virtual_text.default_filetype_enabled = false
                -- Clear any existing virtual text
                local ok, vt = pcall(require, "codeium.virtual_text")
                if ok and vt then
                    pcall(function()
                        vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace('codeium'), 0, -1)
                    end)
                end
            end
        end

        vim.api.nvim_create_user_command("WindsurfVirtualTextToggle", function()
            vim.g.windsurf_virtual_text_enabled = not vim.g.windsurf_virtual_text_enabled
            _windsurf_apply_vt_autocmds()
            vim.notify("Windsurf virtual text: " .. (vim.g.windsurf_virtual_text_enabled and "ON" or "OFF"))
        end, {})

        vim.api.nvim_create_user_command("WindsurfVirtualTextOn", function()
            vim.g.windsurf_virtual_text_enabled = true
            _windsurf_apply_vt_autocmds()
            vim.notify("Windsurf virtual text: ON")
        end, {})

        vim.api.nvim_create_user_command("WindsurfVirtualTextOff", function()
            vim.g.windsurf_virtual_text_enabled = false
            _windsurf_apply_vt_autocmds()
            vim.notify("Windsurf virtual text: OFF")
        end, {})

        -- Keymaps
        vim.keymap.set("n", "<leader>aw", "<cmd>WindsurfVirtualTextToggle<CR>",
            { desc = "Toggle Windsurf virtual text" })

        -- Initialize OFF
        _windsurf_apply_vt_autocmds()
    end,
    event = "BufEnter", -- Load when entering a buffer
}

return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    event = "VeryLazy",
    keys = {
        { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    },
    opts = {
        options = {
            mode = "tabs",                  -- default: "buffers" — show tabs instead of buffers
            separator_style = "thick",      -- default: "thin"
            always_show_bufferline = false, -- default: true — only show when multiple tabs exist
            diagnostics = "nvim_lsp",       -- default: false — show LSP diagnostic indicators
        },
    },
    config = function(_, opts)
        require("bufferline").setup(opts)

        -- Centralized tabline auto-hide for special views
        local hide_filetypes = {
            "DiffviewFiles",
            "DiffviewFileHistory",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dap-repl",
            "dapui_console",
            "lazygit",
            "snacks_terminal",
            "snacks_explorer",
        }

        local saved_showtabline = vim.o.showtabline

        local function should_hide()
            local ft = vim.bo.filetype
            local bt = vim.bo.buftype
            for _, v in ipairs(hide_filetypes) do
                if ft == v then return true end
            end
            return bt == "terminal"
        end

        local augroup = vim.api.nvim_create_augroup("BufferlineAutoHide", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermOpen" }, {
            group = augroup,
            callback = function()
                if should_hide() then
                    saved_showtabline = vim.o.showtabline
                    vim.o.showtabline = 0
                end
            end,
        })

        vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "TermClose" }, {
            group = augroup,
            callback = function()
                vim.defer_fn(function()
                    if not should_hide() then
                        vim.o.showtabline = saved_showtabline ~= 0 and saved_showtabline or 2
                    end
                end, 50)
            end,
        })
    end,
}

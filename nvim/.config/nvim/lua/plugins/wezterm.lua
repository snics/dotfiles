return {
    'willothy/wezterm.nvim',
    opts = {
        create_commands = false
    },
    event = { "VimEnter", "VimLeavePre" },
    priority = 1000,
    config = function()
        local wezterm = require('wezterm')

        -- Create a function to set the window padding
        local function set_window_padding(padding)
            wezterm.set_config({
                window_padding = padding
            })
        end

        -- Set the window padding on VimEnter
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                set_window_padding({
                    left = 10,
                    right = 10,
                    top = 10,
                    bottom = 10
                })
                -- Neovim redraw to fix the window padding
                vim.cmd("redraw")
            end,
            once = true -- Only run once
        })

        -- Set the window padding when leaving vim
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                set_window_padding({
                    left = 10,
                    right = 10,
                    top = 0,
                    bottom = 10
                })
            end,
        })
    end
}

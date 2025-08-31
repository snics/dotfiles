return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require('catppuccin').setup({
            flavour = "mocha", -- set the theme to be `mocha`
            transparent_background = true, -- enable the theme's transparent background
        })

        vim.cmd.colorscheme 'catppuccin' -- Set the colorscheme
        -- Set transparent background
        vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
        
        -- Enhanced line number colors for better visibility
        vim.api.nvim_set_hl(0, 'LineNr', { 
            fg = '#6c7086', -- Catppuccin overlay0 - more subtle and less white
            bold = false 
        })
        vim.api.nvim_set_hl(0, 'CursorLineNr', { 
            fg = '#fab387', -- Catppuccin peach - warm and friendly
            bold = true 
        })
    end
}

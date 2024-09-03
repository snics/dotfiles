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
    end
}

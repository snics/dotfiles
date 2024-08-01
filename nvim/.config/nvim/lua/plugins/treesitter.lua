return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = function()
            local options = require("configs.treesitter")
            return options
        end
    },
    -- Add support for https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}

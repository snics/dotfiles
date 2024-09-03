return {
    {
        "lukas-reineke/indent-blankline.nvim",
        dependencies = {
            "TheGLander/indent-rainbowline.nvim"
        },
        event = { "BufReadPre", "BufNewFile" },
        main = "ibl",
        opts = function(_, opts)
            -- Ensure opts is initialized as a table if it's nil
            opts = opts or {}

            -- Initialize indent as a table if it's nil
            opts.indent = opts.indent or {}

            -- Set the indent character
            opts.indent.char = "┊"

            -- Define rainbowline options
            local rainbowline_opts = {
                color_transparency = 0.23,
                colors = { 0xf9e2af, 0xa6e3a1, 0xcba6f7, 0x89dceb, },
            }

            -- Merge the options with indent-rainbowline options
            return require("indent-rainbowline").make_opts(opts, rainbowline_opts)
        end,
    },
}

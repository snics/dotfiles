-- Note: Comment.nvim is unmaintained since June 2024, but still works.
-- Neovim 0.10+ has built-in gc/gcc, but lacks block comments (gb/gbc)
-- and extra mappings (gco/gcO/gcA). Keeping this until Neovim adds those.
return {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
        local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

        -- All options below are defaults except pre_hook.
        -- Kept explicitly to document available settings.
        require("Comment").setup({
            padding = true, -- default: true — space between comment char and text
            sticky = true, -- default: true — cursor stays at position
            ignore = nil, -- default: nil — pattern to ignore lines (e.g. "^$" for blank)

            toggler = { -- defaults: gcc, gbc
                line = "gcc", -- toggle line comment
                block = "gbc", -- toggle block comment — not available in Neovim built-in
            },
            opleader = { -- defaults: gc, gb
                line = "gc", -- line comment operator
                block = "gb", -- block comment operator — not available in Neovim built-in
            },
            extra = {  -- defaults: gcO, gco, gcA — not available in Neovim built-in
                above = "gcO", -- add comment line above
                below = "gco", -- add comment line below
                eol = "gcA", -- add comment at end of line
            },
            mappings = { -- defaults: both true
                basic = true, -- gc, gcc, gb, gbc
                extra = true, -- gco, gcO, gcA
            },

            -- JSX/TSX/HTML: use treesitter to determine correct commentstring
            pre_hook = ts_context_commentstring.create_pre_hook(),
            post_hook = nil, -- default: nil
        })
    end,
}

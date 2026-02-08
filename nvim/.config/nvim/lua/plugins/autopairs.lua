return {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true,
            ts_config = {
                lua = { "string", "source", "string_content" },
                javascript = { "string", "template_string" },
            },
            disable_filetype = { "TelescopePrompt", "snacks_picker_input" },
            disable_in_macro = true,
            disable_in_replace_mode = true,
            enable_moveright = true,
            enable_check_bracket_line = true,
            map_cr = true,
            map_bs = true,
            map_c_w = true, -- Ctrl+W in insert mode also removes the pair: (|) → Ctrl+W → |
            fast_wrap = {
                map = "<M-e>", -- Alt+E to wrap: cursor before hello → Alt+E → select → (hello)
                chars = { "{", "[", "(", '"', "'" },
                end_key = "$",
                before_key = "h",
                after_key = "l",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                highlight = "Search",
                highlight_grey = "Comment",
            },
        })

        -- nvim-cmp integration: auto-insert () after completing a function/method
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
}

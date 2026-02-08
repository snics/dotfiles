-- nvim-colorizer.lua — highlight color codes inline
--
-- css = true enables: names, RGB, RGBA, RRGGBB, RRGGBBAA, hsl_fn, rgb_fn, oklch_fn, css_fn
-- tailwind = "both" shows both inline color AND Tailwind class name highlighting
-- mode options: "background" (default), "foreground", "virtualtext"
return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        user_default_options = {
            css = true,              -- default: false — enable all CSS color features
            tailwind = "both",       -- default: false — Tailwind color classes + LSP custom colors
            tailwind_opts = {
                update_names = true, -- default: false — sync color names from Tailwind LSP
            },
        },

        filetypes = {
            "*",
            cmp_docs = { always_update = true },
            html = {
                user_default_options = {
                    mode = "foreground", -- override: show color as text color instead of background
                },
            },
        },
    },
}

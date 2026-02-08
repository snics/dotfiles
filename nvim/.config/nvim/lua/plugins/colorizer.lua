return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        user_default_options = {
            -- Tailwind color classes + LSP custom colors
            tailwind = "both", -- "both" | "lsp" | "normal" | false (default: false)
            tailwind_opts = {
                update_names = true, -- Sync color names from Tailwind LSP (default: false)
            },

            -- css = true enables: names, RGB, RGBA, RRGGBB, RRGGBBAA, hsl_fn, rgb_fn, oklch_fn
            css = true, -- Enable all CSS color features (default: false)
            css_fn = true, -- Redundant when css = true, kept for explicitness
            RGB = true, -- #RGB — default: true, also covered by css = true
            RRGGBB = true, -- #RRGGBB — default: true, also covered by css = true
            names = true, -- "Blue", "red" etc. — default: true, also covered by css = true
            RRGGBBAA = true, -- #RRGGBBAA — default: false, but covered by css = true
            rgb_fn = true, -- rgb()/rgba() — default: false, but covered by css = true
            hsl_fn = true, -- hsl()/hsla() — default: false, but covered by css = true

            -- Display
            mode = "background", -- default: "background" | "foreground" | "virtualtext"
            virtualtext = "■", -- default: "■" — character for virtualtext mode
            always_update = false, -- default: false — update colors in unfocused buffers
        },

        filetypes = {
            "*",
            -- CMP docs: always refresh colors (e.g. for color picker previews)
            cmp_docs = { always_update = true },

            -- Per-filetype overrides below repeat global defaults for explicitness.
            -- Only html.mode = "foreground" is a real override — the rest match user_default_options.
            css = {
                user_default_options = {
                    css = true, -- same as global
                    css_fn = true, -- same as global
                    tailwind = "both", -- same as global
                },
            },
            html = {
                user_default_options = {
                    mode = "foreground", -- override: show color as text color, not background
                    tailwind = "both", -- same as global
                },
            },
            javascript = {
                user_default_options = {
                    tailwind = "both", -- same as global
                    css = true, -- same as global
                },
            },
            typescript = {
                user_default_options = {
                    tailwind = "both", -- same as global
                    css = true, -- same as global
                },
            },
            javascriptreact = {
                user_default_options = {
                    tailwind = "both", -- same as global
                    css = true, -- same as global
                },
            },
            typescriptreact = {
                user_default_options = {
                    tailwind = "both", -- same as global
                    css = true, -- same as global
                },
            },
        },
    },
}

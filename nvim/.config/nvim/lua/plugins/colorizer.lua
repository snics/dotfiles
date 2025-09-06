return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    user_default_options = {
      -- Tailwind-Klassen einfärben + Custom Colors aus dem LSP übernehmen
      tailwind = "both",            -- "both" | "lsp" | "normal" | false
      tailwind_opts = { 
        update_names = true,        -- Update color names from LSP
      },

      -- Allgemeine CSS-Farben aktivieren
      css = true,                   -- Enable all CSS features
      css_fn = true,                -- CSS functions like rgb(), hsl()
      
      -- Standard Farbformate
      RGB = true,                   -- #RGB hex codes
      RRGGBB = true,                -- #RRGGBB hex codes
      names = true,                 -- "Name" codes like Blue or Red
      RRGGBBAA = true,              -- #RRGGBBAA hex codes
      rgb_fn = true,                -- CSS rgb() and rgba() functions
      hsl_fn = true,                -- CSS hsl() and hsla() functions
      
      -- Display Mode
      mode = "background",          -- "background" | "foreground" | "virtualtext"
      
      -- Additional options
      virtualtext = "■",            -- Character for virtualtext mode
      always_update = false,        -- Update color values even if buffer not focused
    },
    
    -- Filetypes mit spezieller Konfiguration
    filetypes = { 
      "*",                          -- Enable for all files
      -- CMP documentation window mit immer aktuellen Farben
      cmp_docs = { 
        always_update = true 
      },
      -- File-specific overrides (optional)
      css = {
        user_default_options = {
          css = true,
          css_fn = true,
          tailwind = "both",
        }
      },
      html = {
        user_default_options = {
          mode = "foreground",
          tailwind = "both",
        }
      },
      javascript = {
        user_default_options = {
          tailwind = "both",
          css = true,
        }
      },
      typescript = {
        user_default_options = {
          tailwind = "both", 
          css = true,
        }
      },
      javascriptreact = {
        user_default_options = {
          tailwind = "both",
          css = true,
        }
      },
      typescriptreact = {
        user_default_options = {
          tailwind = "both",
          css = true,
        }
      },
    },
  },
}

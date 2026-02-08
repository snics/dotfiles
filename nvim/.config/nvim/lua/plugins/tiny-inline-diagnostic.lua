-- tiny-inline-diagnostic.nvim — inline diagnostic messages with virtual text
-- Replaces Neovim's built-in virtual_text diagnostics (disabled in lspconfig.lua)
--
-- Available presets: "modern", "classic", "minimal", "powerline", "ghost", "simple", "nonerdfont", "amongus"
-- Available overflow modes: "wrap", "none", "oneline"
return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
        preset = "modern", -- default: "modern"
        options = {
            show_source = {
                enabled = true, -- default: false — display which LSP/tool produced the diagnostic
            },
        },
    },
}

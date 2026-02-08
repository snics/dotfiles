-- catppuccin/nvim — Catppuccin Mocha color scheme
--
-- Available flavours: "latte", "frappe", "macchiato", "mocha"
-- transparent_background sets Normal/NormalNC bg to NONE
-- float.transparent must be set separately for floating windows
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = true,
            float = { transparent = true }, -- NormalFloat bg = NONE (separate from transparent_background)
        })

        vim.cmd.colorscheme("catppuccin")

        -- Line number colors (Catppuccin Mocha palette overrides)
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#6c7086" })                    -- overlay0 — subtle
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#fab387", bold = true }) -- peach — warm
    end,
}

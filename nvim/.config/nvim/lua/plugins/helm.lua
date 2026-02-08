-- Helm template support: conceal templates with values, indent hints, action highlight.
-- Available config: conceal_templates.enabled, indent_hints.enabled/.only_for_current_line,
--   action_highlight.enabled — all default to true.
return {
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {}, -- all defaults are fine
}

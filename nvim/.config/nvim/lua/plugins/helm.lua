return {
  "qvalentin/helm-ls.nvim",
  ft = "helm",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    conceal_templates = {
      -- Enable replacement of templates with virtual text of their current values
      enabled = true,
    },
    indent_hints = {
      -- Enable hints for indent and nindent functions
      enabled = true,
      -- Show hints only for the line the cursor is on
      only_for_current_line = true,
    },
  },
  config = function(_, opts)
    require("helm-ls").setup(opts)
  end,
}
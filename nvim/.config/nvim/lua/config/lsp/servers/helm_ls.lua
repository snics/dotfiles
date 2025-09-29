-- Helm Language Server Configuration

local M = {}

-- Export configuration table (for vim.lsp.config)
M.config = {
  settings = {
    ['helm-ls'] = {
      yamlls = {
        path = "yaml-language-server",
      },
    },
  },
  filetypes = { "helm" },
  root_dir = vim.fs.root(0, {"Chart.yaml", "Chart.yml"}),
}

return M
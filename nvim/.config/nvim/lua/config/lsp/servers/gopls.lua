-- Go Language Server Configuration

local M = {}

-- Export configuration table (for vim.lsp.config)
M.config = {
  cmd = {"gopls"},
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = vim.fs.root(0, {"go.work", "go.mod", ".git"}),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = { unusedparams = true },
    },
  },
}

return M
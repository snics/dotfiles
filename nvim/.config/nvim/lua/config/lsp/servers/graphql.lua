-- GraphQL Language Server Configuration

local M = {}

-- Export configuration table (for vim.lsp.config)
M.config = {
  filetypes = { "graphql", "svelte", "typescriptreact", "javascriptreact" },
}

return M

-- Lua Language Server Configuration

local M = {}

-- Export configuration table (for vim.lsp.config)
M.config = {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      completion = { callSnippet = "Replace" },
    },
  },
}

return M
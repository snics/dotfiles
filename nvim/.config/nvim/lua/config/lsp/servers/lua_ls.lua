-- Lua Language Server Configuration

local M = {}

function M.setup(lspconfig, capabilities)
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        completion = { callSnippet = "Replace" },
      },
    },
  })
end

return M
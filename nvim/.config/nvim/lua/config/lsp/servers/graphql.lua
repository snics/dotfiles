-- GraphQL Language Server Configuration

local M = {}

function M.setup(lspconfig, capabilities)
  lspconfig.graphql.setup({
    capabilities = capabilities,
    filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
  })
end

return M
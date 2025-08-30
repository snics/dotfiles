-- Go Language Server Configuration

local M = {}

function M.setup(lspconfig, capabilities)
  lspconfig.gopls.setup({
    capabilities = capabilities,
    cmd = {"gopls"},
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = { unusedparams = true },
      },
    },
  })
end

return M
-- Helm Language Server Configuration

local M = {}

function M.setup(lspconfig, capabilities)
  lspconfig.helm_ls.setup({
    capabilities = capabilities,
    settings = {
      ['helm-ls'] = {
        yamlls = {
          path = "yaml-language-server",
        },
      },
    },
    filetypes = { "helm" },
    root_dir = require("lspconfig/util").root_pattern("Chart.yaml", "Chart.yml"),
  })
end

return M
-- NvChad LSP Configs
local base = require "nvchad.configs.lspconfig"
local on_attach = base.on_attach
local capabilities = base.capabilities

-- Utils and lspconfig
local lspconfig = require "lspconfig"

local servers = {
  -- LSP servers
  "ansiblels", -- Ansible Language Server: "ansible-language-server"
  "bashls", -- Bash Language Server: "bash-language-server"
  "biome", -- Biome: "biome"
  "cssls", -- CSS Language Server: "css-lsp"
  "cssmodules_ls", -- CSS Modules Language Server: "cssmodules-language-server"
  "denols", -- Deno Language Server: "deno"
  "dockerls", -- Docker Language Server: "dockerfile-language-server"
  "docker_compose_language_service", -- Docker Compose Language Service: "docker-compose-language-service"
  "eslint", -- ESLint Language Server: "eslint-lsp"
  "html", -- HTML Language Server: "html-lsp"
  "htmx", -- HTMX Language Server: "htmx-lsp"
  "jsonls", -- JSON Language Server: "json-lsp"
  "lua_ls", -- Lua Language Server: "lua-language-server"
  "mdx_analyzer", -- MDX Analyzer: "mdx-analyzer"
  "kotlin_language_server", -- Kotlin Language Server: "kotlin-language-server"
  "tailwindcss", -- Tailwind CSS Language Server: "tailwindcss-language-server"
  "terraformls", -- Terraform Language Server: "terraform-ls"
  "tsserver", -- TypeScript Language Server: "typescript-language-server"
  "yamlls", -- YAML Language Server: "yaml-language-server"

  -- DAP servers

  -- Formatters

  -- Linters
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- LSP Configuration Entry Point
-- This file initializes all LSP servers and configurations

local M = {}

-- Get default capabilities for all LSP servers
M.capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup all LSP servers
function M.setup()
  local lspconfig = require("lspconfig")
  
  -- Load individual server configurations
  require("config.lsp.servers.jsonls").setup(lspconfig, M.capabilities)
  require("config.lsp.servers.yamlls").setup(lspconfig, M.capabilities)
  require("config.lsp.servers.lua_ls").setup(lspconfig, M.capabilities)
  require("config.lsp.servers.gopls").setup(lspconfig, M.capabilities)
  require("config.lsp.servers.graphql").setup(lspconfig, M.capabilities)
  require("config.lsp.servers.helm_ls").setup(lspconfig, M.capabilities)
  
  -- Setup default servers (simple configurations)
  local default_servers = {
    "ansiblels", 
    "bashls", 
    "biome", 
    "cssls", 
    "css_variables", 
    "cssmodules_ls",
    "denols", 
    "docker_compose_language_service", 
    "dockerls", 
    "eslint",
    "html", 
    "htmx", 
    "ltex", 
    "mdx_analyzer", 
    "marksman",
    "nginx_language_server", 
    "powershell_es", 
    "sqlls", 
    "taplo", 
    "tailwindcss",
    "terraformls", 
    "ts_ls", 
    "vimls", 
    "lemminx"
  }
  
  for _, server in ipairs(default_servers) do
    lspconfig[server].setup({
      capabilities = M.capabilities,
    })
  end
end

return M
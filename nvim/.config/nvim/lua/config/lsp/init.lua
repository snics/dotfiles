-- LSP Configuration Entry Point
-- This file initializes all LSP servers and configurations

local M = {}

-- Get default capabilities for all LSP servers
M.capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup all LSP servers
function M.setup()
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")
  
  -- Get all installed LSP servers from mason-lspconfig
  local installed_servers = mason_lspconfig.get_installed_servers()
  
  -- Process each installed LSP server
  for _, server_name in ipairs(installed_servers) do
    -- Try to load server-specific configuration if it exists
    local ok, server_module = pcall(require, "config.lsp.servers." .. server_name)
    
    if ok and server_module.setup then
      -- Server has custom configuration, use it
      server_module.setup(lspconfig, M.capabilities)
    else
      -- No custom config found, use default configuration
      lspconfig[server_name].setup({
        capabilities = M.capabilities,
      })
    end
  end
end

return M
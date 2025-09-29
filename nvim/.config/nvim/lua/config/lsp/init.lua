-- LSP Configuration Entry Point
-- This file initializes all LSP servers and configurations

local M = {}

-- Get default capabilities for all LSP servers
M.capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup all LSP servers
function M.setup()
  local mason_lspconfig = require("mason-lspconfig")
  
  -- Get all installed LSP servers from mason-lspconfig
  local installed_servers = mason_lspconfig.get_installed_servers()
  
  -- Process each installed LSP server
  for _, server_name in ipairs(installed_servers) do
    -- Try to load server-specific configuration if it exists
    local ok, server_module = pcall(require, "config.lsp.servers." .. server_name)
    
    if ok and server_module.config then
      -- Server has custom configuration, apply it using vim.lsp.config
      vim.lsp.config(server_name, vim.tbl_extend('force', server_module.config, {
        capabilities = M.capabilities,
      }))
    else
      -- No custom config found, use default configuration
      vim.lsp.config(server_name, {
        capabilities = M.capabilities,
      })
    end
    
    -- Enable the LSP server using the new API
    vim.lsp.enable(server_name)
  end
end

return M
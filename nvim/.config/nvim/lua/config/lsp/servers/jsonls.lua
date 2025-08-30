-- JSON Language Server Configuration

local M = {}

function M.setup(lspconfig, capabilities)
  lspconfig.jsonls.setup({
    capabilities = capabilities,
    settings = {
      json = {
        -- Schema configuration
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
        
        -- Formatting options
        format = { 
          enable = true,
          keepLines = false,
        },
        
        -- Visual enhancements
        colorDecorators = { enable = true }, -- Show color previews for color values
        
        -- Performance settings
        maxItemsComputed = 5000, -- Limit computed properties for large files
        
        -- Schema download control
        schemaDownload = { enable = true }, -- Auto-download missing schemas
        
        -- Completion settings
        completion = {
          triggerCharacters = { '"', ':' },
        },
        
        -- Hover information
        hover = { enable = true },
        
        -- Trace settings (for debugging)
        trace = { server = 'off' }, -- Options: 'off', 'messages', 'verbose'
      },
    },
    -- File type associations
    filetypes = { 
      "json", 
      "jsonc", -- JSON with comments
      "json5"  -- JSON5 format
    },
  })
end

return M
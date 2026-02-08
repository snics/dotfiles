-- gopls — Go Language Server
-- cmd, filetypes, root_dir are auto-configured by lspconfig

local M = {}

M.config = {
    settings = {
        gopls = {
            -- completeUnimported = true,       -- default: true
            usePlaceholders = true, -- default: false — insert parameter placeholders in completions
            -- analyses = { unusedparams = true }, -- default: true
        },
    },
}

return M

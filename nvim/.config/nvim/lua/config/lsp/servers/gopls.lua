-- gopls — Go Language Server
-- cmd, filetypes, root_dir are auto-configured by lspconfig

local M = {}

M.config = {
    settings = {
        gopls = {
            -- completeUnimported = true,       -- default: true
            usePlaceholders = true, -- default: false — insert parameter placeholders in completions
            -- analyses = { unusedparams = true }, -- default: true

            -- Inlay hints (all OFF by default in gopls — enable explicitly)
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },

            -- CodeLens (most ON by default, but test lens needs explicit enable)
            codelenses = {
                test = true, -- default: false — show "Run Test" on Go test functions
            },
        },
    },
}

return M

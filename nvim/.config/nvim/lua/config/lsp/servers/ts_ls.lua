-- ts_ls — TypeScript/JavaScript Language Server
-- cmd, filetypes, root_dir are auto-configured by lspconfig

local M = {}

-- Shared inlay hint settings for both TypeScript and JavaScript
local inlay_hints = {
    includeInlayParameterNameHints = "all",
    includeInlayVariableTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayEnumMemberValueHints = true,
}

M.config = {
    settings = {
        typescript = {
            inlayHints = inlay_hints,
        },
        javascript = {
            inlayHints = inlay_hints,
        },
    },
}

return M

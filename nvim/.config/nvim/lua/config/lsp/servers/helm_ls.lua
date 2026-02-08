-- helm-ls — Helm Chart Language Server
-- filetypes and root_dir are auto-configured by lspconfig
-- yamlls.path must be set explicitly (no auto-detection)

local M = {}

M.config = {
    settings = {
        ["helm-ls"] = {
            yamlls = {
                path = "yaml-language-server",
            },
        },
    },
}

return M

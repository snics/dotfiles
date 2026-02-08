-- jsonls — JSON Language Server
-- filetypes (json, jsonc) are auto-configured by lspconfig
--
-- Default settings that don't need explicit config:
--   format.enable = true, format.keepLines = false, colorDecorators.enable = true,
--   maxItemsComputed = 5000, schemaDownload.enable = true, trace.server = "off"

local M = {}

M.config = {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
}

return M

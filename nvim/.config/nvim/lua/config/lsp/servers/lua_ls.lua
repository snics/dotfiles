-- lua_ls — Lua Language Server
-- diagnostics.globals is still needed even with lazydev.nvim

local M = {}

M.config = {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" }, -- default: "Disable" — show call snippets instead of function names
        },
    },
}

return M

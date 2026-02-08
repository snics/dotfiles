-- none-ls formatting sources (loaded by plugins/none-ls.lua)

local M = {}

M.biome = require("config.none-ls.formatters.biome")
M.deno_fmt = require("config.none-ls.formatters.deno_fmt")
M.prettierd = require("config.none-ls.formatters.prettierd")
M.taplo = require("config.none-ls.formatters.taplo")

return M

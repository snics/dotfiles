-- ==============================================================================
-- None-ls Custom Formatting Sources
-- ==============================================================================
-- All custom formatting sources organized in one module
-- Usage: local my_formatting = require("config.none-ls.formatting")
--        then use: my_formatting.taplo, my_formatting.biome, etc.
-- ==============================================================================

local M = {}

-- ==============================================================================
-- CUSTOM FORMATTING SOURCES
-- ==============================================================================

-- Custom Taplo integration (your own implementation)
M.taplo = require("config.none-ls.formatters.taplo")

-- ==============================================================================
-- SMART FORMATTER SELECTION (loaded from separate files)
-- ==============================================================================

-- Load individual formatter configurations from separate files
M.biome = require("config.none-ls.formatters.biome")
M.deno_fmt = require("config.none-ls.formatters.deno_fmt")
M.prettierd = require("config.none-ls.formatters.prettierd")


return M

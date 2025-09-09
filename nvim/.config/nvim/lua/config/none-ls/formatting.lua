-- ==============================================================================
-- None-ls Custom Formatting Sources
-- ==============================================================================
-- All custom formatting sources organized in one module
-- Usage: local my_formatting = require("config.none-ls.formatting")
--        then use: my_formatting.taplo, my_formatting.custom_formatter, etc.
-- ==============================================================================

local M = {}

-- ==============================================================================
-- CUSTOM FORMATTING SOURCES
-- ==============================================================================

-- Custom Taplo integration (your own implementation)
M.taplo = require("config.none-ls.formatters.taplo")

-- Add more custom formatters here as you create them
-- M.custom_formatter = require("config.none-ls.formatters.custom_formatter")
-- M.biome = require("config.none-ls.formatters.biome")

return M

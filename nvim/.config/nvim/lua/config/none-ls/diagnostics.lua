-- ==============================================================================
-- None-ls Custom Diagnostics Sources
-- ==============================================================================
-- All custom diagnostic/linting sources organized in one module
-- Usage: local my_diagnostics = require("config.none-ls.diagnostics")
--        then use: my_diagnostics.tflint, my_diagnostics.hadolint, etc.
-- ==============================================================================

local M = {}

-- ==============================================================================
-- CUSTOM DIAGNOSTICS SOURCES
-- ==============================================================================

-- Custom TFLint integration (your own implementation)
M.tflint = require("config.none-ls.diagnostics.tflint")

-- Custom Hadolint integration (your own implementation) 
-- M.hadolint = require("config.none-ls.diagnostics.hadolint")

-- Add more custom diagnostics here as you create them
-- M.kubelinter = require("config.none-ls.diagnostics.kubelinter")
-- M.custom_linter = require("config.none-ls.diagnostics.custom_linter")

return M

-- ==============================================================================
-- None-ls Custom Diagnostics Sources
-- ==============================================================================
-- All custom diagnostic/linting sources organized in one module
-- Usage: local my_diagnostics = require("config.none-ls.diagnostics")
--        then use: my_diagnostics.tflint, my_diagnostics.biome, etc.
-- ==============================================================================

local M = {}

-- ==============================================================================
-- CUSTOM DIAGNOSTICS SOURCES
-- ==============================================================================

-- Custom TFLint integration (your own implementation)
M.tflint = require("config.none-ls.diagnostics.tflint")

-- ==============================================================================
-- SMART LINTER SELECTION (loaded from separate files)
-- ==============================================================================

-- Load individual linter configurations from separate files
M.biome = require("config.none-ls.diagnostics.biome")
M.deno_lint = require("config.none-ls.diagnostics.deno_lint")
M.oxlint = require("config.none-ls.diagnostics.oxlint")
M.eslint = require("config.none-ls.diagnostics.eslint")

-- ==============================================================================
-- SECURITY & INFRASTRUCTURE TOOLS
-- ==============================================================================

-- Security and infrastructure scanning tools
M.kube_linter = require("config.none-ls.diagnostics.kube_linter")
M.trufflehog = require("config.none-ls.diagnostics.trufflehog")


return M

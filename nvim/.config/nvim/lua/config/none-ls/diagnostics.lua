-- none-ls diagnostic sources (loaded by plugins/none-ls.lua)

local M = {}

M.biome = require("config.none-ls.diagnostics.biome")
M.deno_lint = require("config.none-ls.diagnostics.deno_lint")
M.eslint = require("config.none-ls.diagnostics.eslint")
M.kube_linter = require("config.none-ls.diagnostics.kube_linter")
M.oxlint = require("config.none-ls.diagnostics.oxlint")
M.tflint = require("config.none-ls.diagnostics.tflint")
M.trufflehog = require("config.none-ls.diagnostics.trufflehog")

return M

-- =============================================================================
-- Custom Taplo Integration for none-ls
-- TOML formatter and validator
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
  name = "taplo_custom",
  meta = {
    url = "https://github.com/tamasfe/taplo",
    description = "A TOML toolkit written in Rust for formatting and validating TOML files",
  },
  method = FORMATTING,
  filetypes = { "toml" },
  generator_opts = {
    command = "taplo",
    args = { "fmt", "-" },
    to_stdin = true,
  },
  factory = h.generator_factory,
  -- Only run if taplo is installed
  runtime_condition = function(params)
    return vim.fn.executable("taplo") == 1
  end,
})

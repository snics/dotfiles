-- =============================================================================
-- Biome Formatter Configuration for none-ls
-- All-in-one formatter for JS/TS/JSON/HTML/CSS (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
  name = "biome",
  meta = {
    url = "https://biomejs.dev/",
    description = "Biome formatter for JavaScript/TypeScript/JSON/HTML/CSS",
  },
  method = FORMATTING,
  filetypes = {
    "javascript",
    "javascriptreact", 
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "html",
    "css",
    "scss",
  },
  generator_opts = {
    command = "biome",
    args = { "format", "--stdin-file-path", "$FILENAME" },
    to_stdin = true,
  },
  factory = h.generator_factory,
  condition = function(utils)
    -- Only enable if biome.json or biome.jsonc exists and biome is installed
    return utils.root_has_file({
      "biome.json",
      "biome.jsonc",
      ".biome.json",
      ".biome.jsonc",
    }) and vim.fn.executable("biome") == 1
  end,
})


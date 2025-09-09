-- =============================================================================
-- Deno Formatter Configuration for none-ls
-- Deno formatter for Deno projects (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
  name = "deno_fmt",
  meta = {
    url = "https://deno.land/manual/tools/formatter",
    description = "Deno formatter for JavaScript/TypeScript/JSON/Markdown",
  },
  method = FORMATTING,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript", 
    "typescriptreact",
    "json",
    "jsonc",
    "markdown",
  },
  generator_opts = {
    command = "deno",
    args = { "fmt", "-" },
    to_stdin = true,
  },
  factory = h.generator_factory,
  condition = function(utils)
    -- Only enable if deno.json or deno.jsonc exists and deno is installed
    return utils.root_has_file({
      "deno.json",
      "deno.jsonc",
      ".deno.json",
      ".deno.jsonc",
    }) and vim.fn.executable("deno") == 1
  end,
})


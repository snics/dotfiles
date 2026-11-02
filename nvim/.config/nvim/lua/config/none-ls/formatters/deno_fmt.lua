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
    args = function(params)
      local ext = ({
        javascript = "js",
        javascriptreact = "jsx",
        typescript = "ts",
        typescriptreact = "tsx",
        json = "json",
        jsonc = "jsonc",
        markdown = "md",
      })[params.ft] or "ts"
      return { "fmt", "--ext=" .. ext, "-" }
    end,
    to_stdin = true,
  },
  factory = h.formatter_factory,
  condition = function(utils)
    -- Only enable if deno.json or deno.jsonc exists and deno is installed (via asdf or system)
    local has_deno_config = utils.root_has_file({
      "deno.json",
      "deno.jsonc",
      ".deno.json",
      ".deno.jsonc",
    })

    if not has_deno_config or utils.root_has_file({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }) then
      return false
    end

    return vim.fn.executable("deno") == 1
  end,
})

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
    -- Only enable if deno.json or deno.jsonc exists and deno is installed (via asdf or system)
    local has_deno_config = utils.root_has_file({
      "deno.json",
      "deno.jsonc",
      ".deno.json",
      ".deno.jsonc",
    })
    
    if not has_deno_config then
      return false
    end
    
    -- Check if deno is available via asdf or system
    local deno_available = vim.fn.executable("deno") == 1
    
    -- If not available via system, try asdf
    if not deno_available then
      local asdf_deno = vim.fn.system("asdf which deno 2>/dev/null")
      deno_available = asdf_deno and asdf_deno ~= "" and not vim.startswith(asdf_deno, "asdf: deno")
    end
    
    return deno_available
  end,
})


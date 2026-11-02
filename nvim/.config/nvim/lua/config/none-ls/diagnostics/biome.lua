-- =============================================================================
-- Biome Linter Configuration for none-ls
-- All-in-one linter for JS/TS/JSON/HTML/CSS (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "biome",
  meta = {
    url = "https://biomejs.dev/",
    description = "Biome linter for JavaScript/TypeScript/JSON/HTML/CSS",
  },
  method = DIAGNOSTICS,
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
    args = { "check", "--reporter=json", "$FILENAME" },
    to_temp_file = true,
    format = "json",
    check_exit_code = function(code)
      -- biome returns 0 on success, 1 on errors/warnings
      return code <= 1
    end,
    on_output = function(params)
      local diagnostics = {}

      -- none-ls has already decoded JSON. Biome reports byte spans.
      for _, diagnostic in ipairs((params.output or {}).diagnostics or {}) do
        local location = diagnostic.location or {}
        local source = location.sourceCode or table.concat(params.content, "\n")
        local function position(offset)
          local prefix = source:sub(1, offset)
          local _, lines = prefix:gsub("\n", "")
          local last_line = prefix:match("[^\n]*$") or ""
          return lines + 1, #last_line + 1
        end
        local span = type(location.span) == "table" and location.span or { 0, 0 }
        local row, col = position(span[1])
        local end_row, end_col = position(span[2])
        table.insert(diagnostics, {
          row = row,
          col = col,
          end_row = end_row,
          end_col = end_col,
          message = diagnostic.description or "Biome diagnostic",
          severity = h.diagnostics.severities[diagnostic.severity] or h.diagnostics.severities.warning,
          code = diagnostic.category,
          source = "biome",
        })
      end

      return diagnostics
    end,
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

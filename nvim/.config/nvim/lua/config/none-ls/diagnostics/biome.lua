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
    args = { "check", "--reporter=json", "--stdin-file-path", "$FILENAME" },
    to_stdin = true,
    format = "json",
    check_exit_code = function(code)
      -- biome returns 0 on success, 1 on errors/warnings
      return code <= 1
    end,
    on_output = function(params)
      local diagnostics = {}
      
      -- Parse JSON output
      local ok, decoded = pcall(vim.json.decode, params.output)
      if not ok or not decoded then
        return diagnostics
      end
      
      -- Process diagnostics
      for _, diagnostic in ipairs(decoded.diagnostics or {}) do
        local severity = h.diagnostics.severities.warning
        
        -- Map biome severity to none-ls severity
        if diagnostic.level == "error" then
          severity = h.diagnostics.severities.error
        elseif diagnostic.level == "warning" then
          severity = h.diagnostics.severities.warning
        elseif diagnostic.level == "info" then
          severity = h.diagnostics.severities.information
        elseif diagnostic.level == "hint" then
          severity = h.diagnostics.severities.hint
        end
        
        table.insert(diagnostics, {
          row = diagnostic.location.start.line + 1, -- biome uses 0-based, none-ls uses 1-based
          col = diagnostic.location.start.column + 1,
          end_row = diagnostic.location["end"].line + 1,
          end_col = diagnostic.location["end"].column + 1,
          message = diagnostic.message,
          severity = severity,
          code = diagnostic.rule_id,
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
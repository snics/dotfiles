-- =============================================================================
-- OXLint Configuration for none-ls
-- Fast Rust-based linter for JavaScript/TypeScript (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "oxlint",
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "Fast Rust-based linter for JavaScript/TypeScript",
  },
  method = DIAGNOSTICS,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
  generator_opts = {
    command = "oxlint",
    args = { "--format", "json", "--stdin" },
    to_stdin = true,
    format = "json",
    check_exit_code = function(code)
      -- oxlint returns 0 on success, 1 on errors/warnings
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
        
        -- Map oxlint severity to none-ls severity
        if diagnostic.severity == "error" then
          severity = h.diagnostics.severities.error
        elseif diagnostic.severity == "warning" then
          severity = h.diagnostics.severities.warning
        elseif diagnostic.severity == "info" then
          severity = h.diagnostics.severities.information
        elseif diagnostic.severity == "hint" then
          severity = h.diagnostics.severities.hint
        end
        
        table.insert(diagnostics, {
          row = diagnostic.range.start.line + 1, -- oxlint uses 0-based, none-ls uses 1-based
          col = diagnostic.range.start.character + 1,
          end_row = diagnostic.range["end"].line + 1,
          end_col = diagnostic.range["end"].character + 1,
          message = diagnostic.message,
          severity = severity,
          code = diagnostic.rule_id,
          source = "oxlint",
        })
      end
      
      return diagnostics
    end,
  },
  factory = h.generator_factory,
  condition = function(utils)
    -- Only enable if oxlint config exists and no Biome/Deno/ESLint config
    local has_biome = utils.root_has_file({
      "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc"
    })
    local has_deno = utils.root_has_file({
      "deno.json", "deno.jsonc", ".deno.json", ".deno.jsonc"
    })
    local has_eslint = utils.root_has_file({
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
    })
    local has_oxlint = utils.root_has_file({
      "oxlint.json",
      ".oxlint.json",
      "oxlint.toml",
      ".oxlint.toml",
    })
    
    return has_oxlint and not has_biome and not has_deno and not has_eslint and vim.fn.executable("oxlint") == 1
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
})


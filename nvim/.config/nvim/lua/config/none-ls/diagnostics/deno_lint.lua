-- =============================================================================
-- Deno Lint Configuration for none-ls
-- Deno linter for Deno projects (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "deno_lint",
  meta = {
    url = "https://deno.land/manual/tools/linter",
    description = "Deno linter for JavaScript/TypeScript",
  },
  method = DIAGNOSTICS,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
  },
  generator_opts = {
    command = "deno",
    args = { "lint", "--json", "-" },
    to_stdin = true,
    format = "json",
    check_exit_code = function(code)
      -- deno lint returns 0 on success, 1 on errors
      return code <= 1
    end,
    on_output = function(params)
      local diagnostics = {}
      
      -- Parse JSON output
      local ok, decoded = pcall(vim.json.decode, params.output)
      if not ok or not decoded then
        return diagnostics
      end
      
      -- Process linting results
      for _, diagnostic in ipairs(decoded.diagnostics or {}) do
        local severity = h.diagnostics.severities.warning
        
        -- Map deno lint severity to none-ls severity
        if diagnostic.level == "error" then
          severity = h.diagnostics.severities.error
        elseif diagnostic.level == "warning" then
          severity = h.diagnostics.severities.warning
        elseif diagnostic.level == "info" then
          severity = h.diagnostics.severities.information
        end
        
        table.insert(diagnostics, {
          row = diagnostic.range.start.line + 1, -- deno uses 0-based, none-ls uses 1-based
          col = diagnostic.range.start.character + 1,
          end_row = diagnostic.range["end"].line + 1,
          end_col = diagnostic.range["end"].character + 1,
          message = diagnostic.message,
          severity = severity,
          code = diagnostic.code,
          source = "deno_lint",
        })
      end
      
      return diagnostics
    end,
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


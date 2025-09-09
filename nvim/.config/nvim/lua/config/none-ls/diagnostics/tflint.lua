-- =============================================================================
-- Custom TFLint Integration for none-ls
-- Terraform linter integration
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "tflint_custom",
  meta = {
    url = "https://github.com/terraform-linters/tflint",
    description = "Terraform linter for finding possible errors and best practices",
  },
  method = DIAGNOSTICS,
  filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
  generator_opts = {
    command = "tflint",
    args = { "--format=json" },
    to_stdin = false,
    format = "json",
    check_exit_code = function(code)
      -- tflint returns 0 on success, 2 on errors, 3 on warnings
      return code <= 3
    end,
    on_output = function(params)
      local diagnostics = {}
      
      -- Parse JSON output
      local ok, decoded = pcall(vim.json.decode, params.output)
      if not ok or not decoded then
        return diagnostics
      end
      
      -- tflint has both "issues" and "errors" in its output
      local issues = decoded.issues or {}
      local errors = decoded.errors or {}
      
      -- Process issues (linting problems)
      for _, issue in ipairs(issues) do
        local severity = h.diagnostics.severities.warning
        
        -- Map tflint severity to none-ls severity
        if issue.rule and issue.rule.severity then
          if issue.rule.severity == "ERROR" then
            severity = h.diagnostics.severities.error
          elseif issue.rule.severity == "WARNING" then
            severity = h.diagnostics.severities.warning
          elseif issue.rule.severity == "NOTICE" then
            severity = h.diagnostics.severities.information
          end
        end
        
        table.insert(diagnostics, {
          row = issue.range and issue.range.start and issue.range.start.line or 1,
          col = issue.range and issue.range.start and issue.range.start.column or 0,
          end_row = issue.range and issue.range["end"] and issue.range["end"].line,
          end_col = issue.range and issue.range["end"] and issue.range["end"].column,
          message = string.format("[%s] %s", issue.rule and issue.rule.name or "TFLINT", issue.message),
          severity = severity,
          code = issue.rule and issue.rule.name,
          source = "tflint",
        })
      end
      
      -- Process errors (tflint execution errors)
      for _, error in ipairs(errors) do
        table.insert(diagnostics, {
          row = error.line or 1,
          col = error.column or 0,
          message = string.format("[TFLINT ERROR] %s", error.message),
          severity = h.diagnostics.severities.error,
          source = "tflint",
        })
      end
      
      return diagnostics
    end,
  },
  factory = h.generator_factory,
  -- Only run in Terraform projects
  condition = function(utils)
    return utils.root_has_file({ "*.tf", "*.tfvars", ".terraform", "terraform.tfstate" })
      and vim.fn.executable("tflint") == 1
  end,
})

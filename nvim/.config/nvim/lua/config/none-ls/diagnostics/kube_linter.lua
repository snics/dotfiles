-- =============================================================================
-- Kube-Linter Configuration for none-ls
-- Kubernetes/Helm linter for YAML manifests (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "kube_linter",
  meta = {
    url = "https://github.com/stackrox/kube-linter",
    description = "Kubernetes/Helm linter for YAML manifests",
  },
  method = DIAGNOSTICS,
  filetypes = {
    "yaml",
    "yml",
  },
  generator_opts = {
    command = "kube-linter",
    args = { "lint", "--format", "json", "$FILENAME" },
    to_stdin = false,
    format = "json",
    check_exit_code = function(code)
      -- kube-linter returns 0 on success, 1 on errors/warnings
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
      for _, check in ipairs(decoded.checks or {}) do
        for _, violation in ipairs(check.violations or {}) do
          local severity = h.diagnostics.severities.warning
          
          -- Map kube-linter severity to none-ls severity
          if violation.severity == "error" then
            severity = h.diagnostics.severities.error
          elseif violation.severity == "warning" then
            severity = h.diagnostics.severities.warning
          elseif violation.severity == "info" then
            severity = h.diagnostics.severities.information
          end
          
          table.insert(diagnostics, {
            row = violation.location.line,
            col = violation.location.column or 1,
            end_row = violation.location.line,
            end_col = violation.location.column or 1,
            message = violation.message,
            severity = severity,
            code = check.check,
            source = "kube_linter",
          })
        end
      end
      
      return diagnostics
    end,
  },
  factory = h.generator_factory,
  condition = function(utils)
    -- Only enable if kube-linter is installed and file looks like a K8s manifest
    local is_k8s_file = utils.root_has_file({
      "kustomization.yaml",
      "kustomization.yml",
      "Chart.yaml",
      "values.yaml",
      "values.yml",
    }) or vim.fn.search("kind:\\s*\\w+", "n") > 0
    
    return is_k8s_file and vim.fn.executable("kube-linter") == 1
  end,
})

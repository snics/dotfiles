-- =============================================================================
-- Kubeconform Configuration for none-ls
-- Kubernetes schema validation for YAML manifests (custom implementation)
-- =============================================================================

local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "kubeconform",
  meta = {
    url = "https://github.com/yannh/kubeconform",
    description = "Kubernetes schema validator for YAML manifests",
  },
  method = DIAGNOSTICS,
  filetypes = {
    "yaml",
    "yml",
  },
  generator_opts = {
    command = "kubeconform",
    args = {
      "-strict",
      "-output",
      "json",
      "-schema-location",
      "default",
      "-schema-location",
      "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json",
      "$FILENAME",
    },
    to_stdin = false,
    format = "json_raw",
    check_exit_code = function(code)
      -- kubeconform returns 0 on success, 1 on validation errors
      return code <= 1
    end,
    on_output = function(params)
      local diagnostics = {}

      if not params.output then
        return diagnostics
      end

      -- JSON output is a single object containing a resources array.
      for _, result in ipairs(params.output.resources or {}) do
        if result.status == "statusInvalid" or result.status == "statusError" then
          local messages = {}
          for _, validation in ipairs(result.validationErrors or {}) do
            table.insert(messages, (validation.path or "/") .. ": " .. (validation.msg or "validation error"))
          end
          table.insert(diagnostics, {
            row = 1,
            col = 1,
            message = result.msg or table.concat(messages, "\n"),
            severity = result.status == "statusInvalid" and h.diagnostics.severities.error
              or h.diagnostics.severities.warning,
            source = "kubeconform",
          })
        end
      end

      return diagnostics
    end,
  },
  factory = h.generator_factory,
  condition = function(utils)
    -- Only enable in K8s projects where kubeconform is installed
    local is_k8s_project = utils.root_has_file({
      "kustomization.yaml",
      "kustomization.yml",
      "Chart.yaml",
    })

    return is_k8s_project and vim.fn.executable("kubeconform") == 1
  end,
})

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
            "-output", "json",
            "-schema-location", "default",
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

            -- kubeconform outputs one JSON object per line (JSONL format)
            for line in params.output:gmatch("[^\n]+") do
                local ok, result = pcall(vim.json.decode, line)
                if ok and result and result.status == "statusInvalid" then
                    for _, msg in ipairs(result.validationErrors or {}) do
                        table.insert(diagnostics, {
                            row = 1,
                            col = 1,
                            message = string.format(
                                "%s: %s (path: %s)",
                                result.filename or "unknown",
                                msg.msg or "validation error",
                                msg.path or "/"
                            ),
                            severity = h.diagnostics.severities.error,
                            source = "kubeconform",
                        })
                    end
                elseif ok and result and result.status == "statusError" then
                    table.insert(diagnostics, {
                        row = 1,
                        col = 1,
                        message = string.format(
                            "%s: %s",
                            result.filename or "unknown",
                            result.msg or "schema error"
                        ),
                        severity = h.diagnostics.severities.warning,
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

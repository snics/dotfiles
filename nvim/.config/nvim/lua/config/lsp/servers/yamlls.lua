-- yamlls — YAML Language Server with Kubernetes support
-- Managed by yaml-companion.nvim (see lsp/init.lua externally_managed)
-- SchemaStore.nvim provides standard schemas, kubernetes.nvim adds CRD schemas

local M = {}

M.config = {
    settings = {
        yaml = {
            schemaStore = {
                enable = false, -- disabled: we use SchemaStore.nvim instead
                url = "",       -- avoid TypeError when schemaStore is disabled
            },
            schemas = (function()
                local schemas = require("schemastore").yaml.schemas()

                -- kubernetes.nvim: adds cluster-specific schemas (incl. CRDs)
                local k8s_ok, kubernetes = pcall(require, "kubernetes")
                if k8s_ok then
                    local schema_path = kubernetes.yamlls_schema()
                    if schema_path then
                        schemas[schema_path] = "*.{yaml,yml}"
                    end
                end

                -- K8s content-based detection is handled by yaml-companion.nvim
                return schemas
            end)(),
            format = { enable = true },
            -- validate, completion, hover all default to true
        },
    },
    filetypes = {
        "yaml",
        "yml",
        "yaml.docker-compose",
        "yaml.gitlab",
        "yaml.ansible",
    },
    root_dir = vim.fs.root(0, {
        ".git",
        "docker-compose.yml",
        "docker-compose.yaml",
        "Chart.yaml",
        "values.yaml",
        "ansible.cfg",
        ".gitlab-ci.yml",
    }),
}

return M

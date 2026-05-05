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

                -- K8s schema (kubernetes.nvim) is routed via yaml-companion's
                -- custom matcher in plugins/yaml-companion.lua, not as a
                -- wildcard glob here — that would falsely apply the K8s schema
                -- to every YAML file (Compose, CI configs, etc.).
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

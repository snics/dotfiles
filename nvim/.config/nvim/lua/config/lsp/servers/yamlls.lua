-- YAML Language Server Configuration with Kubernetes support

local M = {}

-- Export configuration table (for vim.lsp.config)
M.config = {
    settings = {
        yaml = {
            schemaStore = {
                -- Disable built-in schemaStore support since we use SchemaStore.nvim
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
            },
            schemas = (function()
                -- SchemaStore.nvim for all standard schemas
                local schemas = require('schemastore').yaml.schemas()

                -- kubernetes.nvim: adds cluster-specific schemas (incl. CRDs)
                local k8s_ok, kubernetes = pcall(require, 'kubernetes')
                if k8s_ok then
                    local schema_path = kubernetes.yamlls_schema()
                    if schema_path then
                        schemas[schema_path] = "*.{yaml,yml}"
                    end
                end

                -- Note: K8s content-based detection is handled by yaml-companion.nvim
                -- No filename-pattern fallback needed anymore.
                return schemas
            end)(),
            format = {
                enable = true,
                singleQuote = false,
                bracketSpacing = true,
            },
            validate = true,
            completion = true,
            hover = true,
            -- Kubernetes support now handled by kubernetes.nvim plugin
        }
    },
    -- Improved file type detection
    filetypes = {
        "yaml",
        "yml",
        "yaml.docker-compose",
        "yaml.gitlab",
        "yaml.ansible"
    },
    -- Root directory detection
    root_dir = vim.fs.root(0, {
        ".git",
        "docker-compose.yml",
        "docker-compose.yaml",
        "Chart.yaml",
        "values.yaml",
        "ansible.cfg",
        ".gitlab-ci.yml"
    }),
}

return M

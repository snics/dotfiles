return {
    "mosheavni/yaml-companion.nvim",
    ft = { "yaml", "yml" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "b0o/schemastore.nvim",
    },
    keys = {
        -- Schema management
        {
            "<leader>ys",
            function() require("yaml-companion").open_ui_select() end,
            desc = "Select YAML schema",
            ft = "yaml",
        },
        {
            "<leader>yS",
            function()
                local schema = require("yaml-companion").get_buf_schema(0)
                if schema.result[1].name == "none" then
                    vim.notify("No schema active", vim.log.levels.INFO)
                else
                    vim.notify("Schema: " .. schema.result[1].name, vim.log.levels.INFO)
                end
            end,
            desc = "Show current YAML schema",
            ft = "yaml",
        },
        -- CRD features
        { "<leader>yd", "<cmd>YamlBrowseDatreeSchemas<cr>", desc = "Browse Datree CRD schemas",  ft = "yaml" },
        { "<leader>yc", "<cmd>YamlBrowseClusterCRDs<cr>",   desc = "Browse cluster CRD schemas", ft = "yaml" },
        { "<leader>ym", "<cmd>YamlAddCRDModelines<cr>",     desc = "Add CRD schema modelines",   ft = "yaml" },
        -- Key navigation
        { "<leader>yQ", "<cmd>YamlKeys<cr>",                desc = "YAML keys to quickfix",      ft = "yaml" },
    },
    config = function()
        -- Workaround: schema.lua:99 indexes `schema.result[1]` without
        -- guarding against nil `result`, which happens when yamlls returns
        -- an error (e.g. "Maximum call stack size exceeded" on large K8s
        -- schemas). Wrap `current` with pcall to fall back to default.
        local yc_schema = require("yaml-companion.schema")
        local original_current = yc_schema.current
        yc_schema.current = function(bufnr)
            local ok, result = pcall(original_current, bufnr)
            if not ok then
                return yc_schema.default()
            end
            return result
        end

        local yamlls_config = require("config.lsp.servers.yamlls").config
        local capabilities = require("config.lsp").capabilities

        local cfg = require("yaml-companion").setup({
            builtin_matchers = {
                kubernetes = { enabled = true },
                cloud_init = { enabled = true },
            },

            keys = { enabled = true },

            cluster_crds = {
                enabled = true,
                fallback = true, -- auto-fallback to cluster when Datree unavailable
            },

            modeline = {
                validate_urls = true, -- required when fallback = true
                notify = true,
            },

            lspconfig = vim.tbl_deep_extend("force", yamlls_config, {
                capabilities = capabilities,
            }),
        })

        vim.lsp.config("yamlls", cfg)
        vim.lsp.enable("yamlls")

        -- Route the builtin kubernetes matcher to kubernetes.nvim's local
        -- schema instead of the upstream GitHub URI. Detection: any buffer
        -- with both `apiVersion:` and `kind:` (covers CRDs, not just the
        -- hardcoded core resource list of the builtin matcher).
        local k8s_ok, kubernetes = pcall(require, "kubernetes")
        if k8s_ok then
            -- yamlls_schema() already returns a `file://` URI, not a raw path.
            local schema_uri = kubernetes.yamlls_schema()
            if schema_uri then
                local schema = {
                    name = "Kubernetes (cluster, via kubernetes.nvim)",
                    uri = schema_uri,
                }
                local matchers = require("yaml-companion._matchers")._loaded
                if matchers.kubernetes then
                    matchers.kubernetes.match = function(bufnr)
                        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                        local has_kind, has_api = false, false
                        for _, line in ipairs(lines) do
                            if not has_kind and line:match("^kind:%s+%S") then
                                has_kind = true
                            end
                            if not has_api and line:match("^apiVersion:%s+%S") then
                                has_api = true
                            end
                            if has_kind and has_api then
                                return schema
                            end
                        end
                    end
                    matchers.kubernetes.handles = function()
                        return { schema }
                    end
                end
            end
        end

        -- yaml-companion's picker only shows `schema.name or schema.uri`, but
        -- entries from yamlls's `from_store()` have no name → URLs only.
        -- Build a URL→name lookup from SchemaStore.nvim's catalog and
        -- replace `open_ui_select` with a version that uses it.
        local schemastore_ok, schemastore = pcall(require, "schemastore")
        if schemastore_ok then
            local url_to_name = {}
            for _, entry in ipairs(schemastore.json.load().schemas or {}) do
                if entry.url and entry.name then
                    url_to_name[entry.url] = entry.name
                end
            end

            require("yaml-companion.ui.schema_select").open_ui_select = function()
                local schemas = require("yaml-companion.schema").all()
                if #schemas == 0 then
                    return
                end
                vim.ui.select(schemas, {
                    prompt = "Select YAML Schema",
                    format_item = function(s)
                        local name = s.name or url_to_name[s.uri]
                        if name then
                            return string.format("%s  ·  %s", name, s.uri)
                        end
                        return s.uri
                    end,
                }, function(s)
                    if not s then
                        return
                    end
                    require("yaml-companion.context").schema(0, { name = s.name, uri = s.uri })
                end)
            end
        end
    end,
}

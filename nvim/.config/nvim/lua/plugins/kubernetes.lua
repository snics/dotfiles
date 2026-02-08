return {
    'diogo464/kubernetes.nvim',
    -- Only load when kubectl is installed (no network check at startup)
    cond = function()
        return vim.fn.executable('kubectl') == 1
    end,
    -- Lazy load: only when opening YAML files
    ft = { "yaml", "yml" },
    keys = {
        { "<leader>Ks", "<cmd>KubernetesGenerateSchema<CR>", desc = "Regenerate K8s schema from cluster" },
    },
    -- Available config: schema_strict, schema_generate_always, patch, yamlls_root
    opts = {
        -- Use cached schema; regenerate manually via <leader>Ks or :KubernetesGenerateSchema
        schema_generate_always = false, -- default: true — disable auto-regen on every startup
        yamlls_root = function()        -- default: mason path — explicit for clarity
            return vim.fs.joinpath(vim.fn.stdpath("data"), "mason/packages/yaml-language-server")
        end,
        -- schema_strict = true,        -- default: true — additionalProperties=false for better completion
        -- patch = true,                -- default: true — patches yamlls validation.js for custom schemas
    }
}

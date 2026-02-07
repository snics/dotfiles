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
    opts = {
        schema_strict = true,
        -- Use cached schema; regenerate manually via <leader>Ks or :KubernetesGenerateSchema
        schema_generate_always = false,
        patch = true,
        yamlls_root = function()
            return vim.fs.joinpath(vim.fn.stdpath("data"), "/mason/packages/yaml-language-server/")
        end
    }
}

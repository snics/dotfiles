return {
    'diogo464/kubernetes.nvim',
    cond = function()
        -- Nur laden wenn kubectl verfügbar ist und Cluster erreichbar
        local kubectl_available = vim.fn.executable('kubectl') == 1
        if not kubectl_available then
            return false
        end
        
        -- Prüfe Cluster-Verbindung (non-blocking)
        local handle = io.popen('kubectl cluster-info --request-timeout=2s 2>/dev/null')
        if handle then
            local result = handle:read('*l')
            handle:close()
            return result and result:match('Kubernetes') ~= nil
        end
        return false
    end,
    opts = {
        -- this can help with autocomplete. it sets the `additionalProperties` field on type definitions to false if it is not already present.
        schema_strict = true,
        -- true:  generate the schema every time the plugin starts
        -- false: only generate the schema if the files don't already exists. run `:KubernetesGenerateSchema` manually to generate the schema if needed.
        schema_generate_always = true,
        -- Patch yaml-language-server's validation.js file.
        patch = true,
        -- root path of the yamlls language server. by default it is assumed you are using mason but if not this option allows changing that path.
        yamlls_root = function()
            return vim.fs.joinpath(vim.fn.stdpath("data"), "/mason/packages/yaml-language-server/")
        end
    }
}

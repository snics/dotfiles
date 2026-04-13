-- Kustomize workflow: build, validate, deprecation checks, resource navigation.
-- Requires: kustomize, kubeconform, kubent CLI tools (brew install).
return {
    "Allaman/kustomize.nvim",
    ft = "yaml",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        enable_key_mappings = false, -- we define our own under <leader>k via which-key
        enable_lua_snip = true,      -- load kustomize LuaSnip snippets

        build = {
            additional_args = {},
        },

        run = {
            validate = {
                cmd = "kubeconform",
                args = {
                    "-strict",
                    "-schema-location", "default",
                    "-schema-location",
                    "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json",
                },
            },
            deprecations = {
                cmd = "kubent",
                args = { "-t", "1.32", "-c=false", "--helm3=false", "-l=error", "-e", "-f" },
            },
        },
    },
    keys = {
        { "<leader>kb", "<cmd>KustomizeBuild<CR>",          ft = "yaml", desc = "Kustomize build" },
        { "<leader>kk", "<cmd>KustomizeListKinds<CR>",      ft = "yaml", desc = "List resource kinds" },
        { "<leader>kl", "<cmd>KustomizeListResources<CR>",  ft = "yaml", desc = "List resources" },
        { "<leader>kp", "<cmd>KustomizePrintResources<CR>", ft = "yaml", desc = "Print resources at cursor" },
        { "<leader>kv", "<cmd>KustomizeValidate<CR>",       ft = "yaml", desc = "Validate (kubeconform)" },
        { "<leader>kd", "<cmd>KustomizeDeprecations<CR>",   ft = "yaml", desc = "Check deprecations (kubent)" },
    },
}

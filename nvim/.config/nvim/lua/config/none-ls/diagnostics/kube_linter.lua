-- Use the upstream parser for KubeLinter Reports and file locations.
return require("null-ls").builtins.diagnostics.kube_linter.with({
  condition = function(utils)
    -- Only enable if kube-linter is installed and file looks like a K8s manifest
    local is_k8s_file = utils.root_has_file({
      "kustomization.yaml",
      "kustomization.yml",
      "Chart.yaml",
      "values.yaml",
      "values.yml",
    }) or vim.fn.search("kind:\\s*\\w+", "n") > 0

    return is_k8s_file and vim.fn.executable("kube-linter") == 1
  end,
})

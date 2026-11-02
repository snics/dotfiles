-- Oxlint output parsing is maintained by none-ls-extras.
return require("none-ls.diagnostics.oxlint").with({
  condition = function(utils)
    -- Only enable if oxlint config exists and no Biome/Deno/ESLint config
    local has_biome = utils.root_has_file({
      "biome.json",
      "biome.jsonc",
      ".biome.json",
      ".biome.jsonc",
    })
    local has_deno = utils.root_has_file({
      "deno.json",
      "deno.jsonc",
      ".deno.json",
      ".deno.jsonc",
    })
    local has_eslint = utils.root_has_file({
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
    })
    local has_oxlint = utils.root_has_file({
      ".oxlintrc.json",
      ".oxlintrc.jsonc",
      "oxlint.json",
      ".oxlint.json",
      "oxlint.toml",
      ".oxlint.toml",
    })

    return has_oxlint and not has_biome and not has_deno and not has_eslint and vim.fn.executable("oxlint") == 1
  end,
})

-- =============================================================================
-- ESLint Configuration for none-ls
-- Traditional JavaScript/TypeScript linter (using eslint_d daemon)
-- =============================================================================

local require_eslint = require("none-ls.diagnostics.eslint_d")

return require_eslint.with({
  condition = function(utils)
    -- Only enable if ESLint config exists and no Biome/Deno config
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

    return has_eslint and not has_biome and not has_deno
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
})

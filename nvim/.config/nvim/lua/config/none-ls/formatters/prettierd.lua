-- =============================================================================
-- PrettierD Configuration for none-ls
-- Fast Prettier daemon for JavaScript/TypeScript projects
-- =============================================================================

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting

return formatting.prettierd.with({
  condition = function(utils)
    -- Only enable if Prettier config exists and no Biome/Deno config
    local has_biome = utils.root_has_file({
      "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc"
    })
    local has_deno = utils.root_has_file({
      "deno.json", "deno.jsonc", ".deno.json", ".deno.jsonc"
    })
    local has_prettier = utils.root_has_file({
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.js",
      ".prettierrc.cjs",
      ".prettierrc.yaml",
      ".prettierrc.yml",
      "prettier.config.js",
      "prettier.config.cjs",
      "prettier.config.mjs",
    })
    
    return has_prettier and not has_biome and not has_deno
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "css",
    "scss",
    "less",
    "html",
    "json",
    "jsonc",
    "yaml",
    "markdown",
    "markdown.mdx",
    "graphql",
    "handlebars",
  },
})

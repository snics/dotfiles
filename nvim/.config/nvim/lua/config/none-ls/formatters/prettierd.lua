-- =============================================================================
-- PrettierD Configuration for none-ls
-- Fast Prettier daemon for JavaScript/TypeScript projects
-- =============================================================================

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting

return formatting.prettierd.with({
  condition = function(utils)
    -- Use prettierd as fallback when no other formatters are available
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
    -- Oxlint only lints; it must not disable the fallback formatter.
    return not has_biome and not has_deno
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
    "markdown",
    "markdown.mdx",
    "graphql",
    "handlebars",
  },
})

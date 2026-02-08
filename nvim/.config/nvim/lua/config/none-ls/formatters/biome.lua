-- Biome formatter — uses none-ls builtin with smart-selection condition
-- Only activates when biome.json exists (otherwise prettierd is used as fallback)

local formatting = require("null-ls").builtins.formatting

return formatting.biome.with({
    condition = function(utils)
        return utils.root_has_file({
            "biome.json",
            "biome.jsonc",
            ".biome.json",
            ".biome.jsonc",
        })
    end,
})

-- Telescope minimal setup - only for trouble integration and todo-comments
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local trouble_telescope = require("trouble.sources.telescope")

    -- Minimal setup for trouble integration only
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-t>"] = trouble_telescope.open, -- open trouble
          },
        },
      },
    })

    telescope.load_extension("todo-comments") -- load todo-comments extension
  end,
}

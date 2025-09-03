-- Minimal nvim-tree setup only for nvim-lsp-file-operations
-- Snacks.explorer remains the main explorer!
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  lazy = true,
  opts = {
    -- Minimal config - nvim-tree is not used directly
    -- It's only here to make nvim-lsp-file-operations work
    disable_netrw = false,
    hijack_netrw = false,
    view = {
      width = 30,
      side = "left",
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)
    
    -- These events are used by nvim-lsp-file-operations
    -- to trigger LSP rename/move/delete
    vim.api.nvim_create_autocmd("User", {
      pattern = "NvimTreeInit",
      callback = function()
        -- nvim-lsp-file-operations will automatically catch these events
      end,
    })
  end,
  -- No keybindings! We use Snacks.explorer as the main explorer
}

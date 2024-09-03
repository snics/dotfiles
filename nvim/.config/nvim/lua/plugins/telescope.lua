return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
     "folke/trouble.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope") -- telescope
    local actions = require("telescope.actions") -- telescope actions
    local transform_mod = require("telescope.actions.mt").transform_mod -- transform module

    local trouble = require("trouble") -- trouble.nvim
    local trouble_telescope = require("trouble.sources.telescope") -- use telescope as source for trouble

    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix") -- open trouble quickfix
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "smart" }, -- shorten path
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist, -- send selected to quickfix list
            ["<C-t>"] = trouble_telescope.open, -- open trouble
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--hidden", "--follow", "--no-ignore", "--exclude", ".git" },
        },
      },
    })

    telescope.load_extension("fzf") -- load fzf extension

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in current working directory" }) -- fuzzy find files in cwd
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" }) -- fuzzy find recent files
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in current working directory" }) -- find string in cwd
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in current working directory" }) -- find string under cursor in cwd
  end,
}
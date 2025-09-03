return {
  "cuducos/yaml.nvim",
  ft = { "yaml", "yml" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim", -- optional
    "ibhagwan/fzf-lua" -- optional
  },
  config = function()
    -- Korrekte API basierend auf der offiziellen Dokumentation
    local yaml = require("yaml_nvim")
    
    -- Keybindings mit direkter Lua API (viel eleganter!)
    local keymap = vim.keymap
    
    keymap.set("n", "<leader>yv", function() yaml.view() end, { desc = "Show YAML path and value" })
    keymap.set("n", "<leader>yy", function() yaml.yank_all() end, { desc = "Yank YAML path and value" })
    keymap.set("n", "<leader>yk", function() yaml.yank_key() end, { desc = "Yank YAML key" })
    keymap.set("n", "<leader>yV", function() yaml.yank_value() end, { desc = "Yank YAML value" })
    keymap.set("n", "<leader>yq", function() yaml.quickfix() end, { desc = "YAML quickfix" })
    keymap.set("n", "<leader>yh", function() yaml.remove_highlight() end, { desc = "Remove YAML highlight" })
    
    -- Conditional keybindings für optionale Dependencies
    if pcall(require, "snacks") then
      keymap.set("n", "<leader>ys", function() yaml.snacks() end, { desc = "YAML Snacks picker" })
    end

  end,
}

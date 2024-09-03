return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = "nvim-tree/nvim-web-devicons",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
      preset = "modern",
  },
  config = function(_, opts)
    require("which-key").setup(opts)
    require("nvim-web-devicons").setup()

    -- Register your keybindings
    local wk = require("which-key")
    wk.add({
        -- Increment/decrement numbers
        { "<leader>+", icon = "" }, -- add icon to decrement number
        { "<leader>-", icon = "" }, -- add icon to decrement number

        -- Window management
        { "<leader>s", group = "Window management", icon = "" }, -- group for window management
        { "<leader>sv", icon = "" }, -- add icon to split window vertically
        { "<leader>sh", icon = "" }, -- add icon to split windwo horizontally
        { "<leader>se", icon = "󰖮" }, -- add icon to make splits equal size
        { "<leader>sx", icon = "" }, -- add icon to close current split

        -- Tap management
        { "<leader>t", group = "Tab management", icon = "󰓩" }, -- group for tab management
        { "<leader>to", icon = "󰝜" }, -- add icon to open new tab
        { "<leader>tx", icon = "󰭌" }, -- add icon to close current tab
        { "<leader>tn", icon = "󰒭" }, -- add icon to go to next tab
        { "<leader>tp", icon = "󰒮" }, -- add icon to go to previous tab
        { "<leader>tf", icon = "󰓪" }, -- add icon to move current buffer to new tab

        -- File explorer
        { "<leader>e", group = "File explorer", icon = "" }, -- group for file explorer
        { "<leader>ee", icon = "", desc = "Toggle file explorer" }, -- add icon to toggle file explorer
        { "<leader>ef", icon = "" }, -- add icon to toggle file explorer on current file
        { "<leader>ec", icon = "󰁄" }, -- add icon to collapse file explorer
        { "<leader>er", icon = "󰕂" }, -- add icon to refresh file explorer

        -- Telescope
        { "<leader>f", group = "Telescope", icon = "" }, -- group for telescope
        { "<leader>ff", icon = "󰈞", desc = "Fuzzy find files in current working directory" }, -- add icon to fuzzy find files in cwd
        { "<leader>fr", icon = "󰈞", desc = "Fuzzy find recent files" }, -- add icon to fuzzy find recent files
        { "<leader>fs", icon = "", desc = "Find string in current working directory" }, -- add icon to find string in cwd
        { "<leader>fc", icon = "", desc = "Find string under cursor in current working directory" }, -- add icon to find string under cursor in cwd
    })
  end,
}
-- Ctrl+h/j/k/l navigation and Alt+Shift+h/j/k/l resizing across NeoVim
-- splits and herdr panes. The plugin detects herdr itself (HERDR_ENV):
-- inside a herdr pane it hands off at split edges; elsewhere (SSH,
-- containers) it simply navigates NeoVim windows. Resize lives on
-- Alt+Shift because plain Alt+j/k is taken by move-line (keymaps.lua);
-- the herdr side mirrors this in herdr/.config/herdr/config.toml.
return {
  "lmilojevicc/herdr-splits.nvim",
  opts = { auto_sync_herdr = true },
  keys = {
    { "<C-h>", function() require("herdr-splits").move_cursor_left() end,  desc = "Go to left pane (herdr-aware)" },
    { "<C-j>", function() require("herdr-splits").move_cursor_down() end,  desc = "Go to lower pane (herdr-aware)" },
    { "<C-k>", function() require("herdr-splits").move_cursor_up() end,    desc = "Go to upper pane (herdr-aware)" },
    { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Go to right pane (herdr-aware)" },
    { "<M-H>", function() require("herdr-splits").resize_left() end,  desc = "Resize pane left (herdr-aware)" },
    { "<M-J>", function() require("herdr-splits").resize_down() end,  desc = "Resize pane down (herdr-aware)" },
    { "<M-K>", function() require("herdr-splits").resize_up() end,    desc = "Resize pane up (herdr-aware)" },
    { "<M-L>", function() require("herdr-splits").resize_right() end, desc = "Resize pane right (herdr-aware)" },
  },
}

return {
  "christoomey/vim-tmux-navigator",
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Go to left pane (tmux-aware)" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Go to lower pane (tmux-aware)" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Go to upper pane (tmux-aware)" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right pane (tmux-aware)" },
  },
}

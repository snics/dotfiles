return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- TODO: add good handling for treesitter and lsp integration
    -- import comment plugin safely
    local comment = require("Comment")
    -- import ts_context_commentstring plugin safely for tsx, jsx, html files
    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    -- enable comment with comprehensive configuration
    comment.setup({
      -- Add a space b/w comment and the line
      padding = true,
      
      -- Whether the cursor should stay at its position
      sticky = true,
      
      -- Lines to be ignored while (un)comment
      ignore = nil,
      
      -- LHS of toggle mappings in NORMAL mode
      toggler = {
        -- Line-comment toggle keymap
        line = 'gcc',
        -- Block-comment toggle keymap
        block = 'gbc',
      },
      
      -- LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        -- Line-comment keymap
        line = 'gc',
        -- Block-comment keymap
        block = 'gb',
      },
      
      -- LHS of extra mappings
      extra = {
        -- Add comment on the line above
        above = 'gcO',
        -- Add comment on the line below
        below = 'gco',
        -- Add comment at the end of line
        eol = 'gcA',
      },
      
      -- Enable keybindings
      -- NOTE: If given `false` then the plugin won't create any mappings
      mappings = {
        -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        -- Extra mapping; `gco`, `gcO`, `gcA`
        extra = true,
      },
      
      -- Function to call before (un)comment
      pre_hook = ts_context_commentstring.create_pre_hook(),
      
      -- Function to call after (un)comment
      post_hook = nil,
    })
  end,
}
return {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    -- Snacks.nvim is already configured in your setup with input enabled
    { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
  },
  ---@type opencode.Opts
  opts = {
    -- Your configuration, if any — see lua/opencode/config.lua for all options
  },
  keys = {
    -- Recommended keymaps
    { '<leader>oA', function() require('opencode').ask() end, desc = 'Ask opencode', },
    { '<leader>oa', function() require('opencode').ask('@cursor: ') end, desc = 'Ask opencode about this', mode = 'n', },
    { '<leader>oa', function() require('opencode').ask('@selection: ') end, desc = 'Ask opencode about selection', mode = 'v', },
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle embedded opencode', },
    { '<leader>on', function() require('opencode').command('session_new') end, desc = 'New session', },
    { '<leader>oy', function() require('opencode').command('messages_copy') end, desc = 'Copy last message', },
    { '<S-C-u>', function() require('opencode').command('messages_half_page_up') end, desc = 'Scroll messages up', },
    { '<S-C-d>', function() require('opencode').command('messages_half_page_down') end, desc = 'Scroll messages down', },
    { '<leader>op', function() require('opencode').select_prompt() end, desc = 'Select prompt', mode = { 'n', 'v', }, },
    -- Custom prompt examples
    { '<leader>oe', function() require('opencode').prompt("Explain @cursor and its context") end, desc = "Explain code near cursor", },
    { '<leader>or', function() require('opencode').prompt("Review @selection for potential improvements") end, desc = "Review selected code", mode = "v", },
    { '<leader>od', function() require('opencode').prompt("Add documentation for @cursor") end, desc = "Document code at cursor", },
  },
  config = function(_, opts)
    require('opencode').setup(opts)
    
    -- Optional: Listen for opencode events for custom automation
    vim.api.nvim_create_autocmd("User", {
      pattern = "OpencodeEvent",
      callback = function(args)
        -- Example: Show notification when opencode finishes responding
        if args.data.type == "session.idle" then
          vim.notify("Opencode finished responding", vim.log.levels.INFO)
        end
      end,
    })
  end,
}

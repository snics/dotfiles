return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    -- 🔍 SEARCH MODES
    modes = {
      -- Standard search with Flash enhancement
      search = {
        enabled = true,                    -- enable flash for normal search (/ and ?)
        highlight = { backdrop = false },  -- no backdrop highlighting for search
        jump = { 
          history = true,                  -- save jumps in jumplist
          register = true,                 -- save search pattern in register
          nohlsearch = true                -- remove highlighting after jump
        },
        search = {
          multi_window = true,             -- multi-window search
          forward = true,                  -- search direction
          wrap = true,                     -- when false, find only matches in given direction
          -- Each mode will take ignorecase and smartcase into account.
          -- * exact: exact match
          -- * search: regular search  
          -- * fuzzy: fuzzy search
          mode = "fuzzy",                  -- exact match mode
          incremental = true,              -- behave like incsearch
        },
      },
      -- Char mode for f/F/t/T
      char = {
        enabled = true,                           -- enable enhanced f/F/t/T functions
        autohide = false,                         -- hide after jump when not using jump labels
        jump_labels = true,                       -- show jump labels
        multi_line = true,                        -- set to false to use current line only
        keys = { "f", "F", "t", "T", ";", "," },  -- when using jump labels, don't use these keys
        search = { wrap = false },                -- no wrapping for char search
        highlight = { backdrop = true },          -- backdrop highlighting for char search
        jump = { register = false },              -- no register saving for char search
      },
      -- Treesitter mode
      treesitter = {
        labels = "abcdefghijklmnopqrstuvwxyz",  -- labels for treesitter mode
        jump = { pos = "range" },               -- jump to whole ranges
        search = { incremental = false },       -- no live search for treesitter
        label = { 
          before = true,                        -- labels before the match
          after = true,                         -- labels after the match
          style = "inline"                      -- inline style for labels
        },
        highlight = {
          backdrop = false,                     -- no backdrop for treesitter
          matches = false,                      -- no match highlighting
        },
      },
    },

    -- 🏷️ LABEL CONFIGURATION
    label = {
      uppercase = true,                        -- allow uppercase labels
      current = true,                          -- add a label for the first match in current window
      after = { 0, 0 },                        -- show the label after the match
      before = false,                          -- show the label before the match
      style = "overlay",                       -- position of the label extmark
      reuse = "lowercase",                     -- re-use labels when typing more characters
      distance = true,                         -- for current window, label targets closer to cursor first
    },

    -- 🎨 HIGHLIGHT GROUPS
    highlight = {
      backdrop = true,                         -- show a backdrop with hl FlashBackdrop
      matches = true,                          -- highlight the search matches
      priority = 5000,                         -- extmark priority
      groups = {
        match = "FlashMatch",                  -- highlight group for matches
        current = "FlashCurrent",              -- highlight group for current match
        backdrop = "FlashBackdrop",            -- highlight group for backdrop
        label = "FlashLabel",                  -- highlight group for labels
      },
    },

    -- 🎯 ACTION OPTIONS  
    action = nil,                              -- no special action defined
    pattern = "",                              -- pattern to search for
    -- When `true`, flash will be activated during regular search by default.
    -- You can always toggle flash with `require("flash").toggle()`
    search = {
      multi_window = true,                     -- search/jump in all windows
      forward = true,                          -- search direction
      wrap = true,                             -- when false, find only matches in given direction
      ---@type Flash.Pattern.Mode
      mode = "exact",                          -- exact match mode
      incremental = true,                      -- behave like incsearch
      -- Excluded filetypes and custom window filters
      exclude = {
        "notify",                              -- notification windows
        "cmp_menu",                            -- autocompletion menu
        "noice",                               -- noice plugin windows
        "flash_prompt",                        -- flash prompt windows
        function(win)                          -- exclude non-focusable windows
          return not vim.api.nvim_win_get_config(win).focusable
        end,
      },
      -- Optional trigger character (set to `false` to disable)
      trigger = "",                            -- optional trigger character
      -- max pattern length. If the pattern length is equal to this
      -- labels will no longer be skipped. When it exceeds this length
      -- it will either end in a jump or terminate the search
      max_length = false,                      -- max pattern length
    },
    jump = {
      jumplist = true,                         -- save location in the jumplist
      pos = "start",                           -- jump position
      history = false,                         -- add pattern to search history
      register = false,                        -- add pattern to search register
      nohlsearch = false,                      -- clear highlight after jump
      autojump = false,                        -- automatically jump when there is only one match
      -- You can force inclusive/exclusive jumps by setting the
      -- `inclusive` option. By default it will be automatically
      -- set based on the mode.
      inclusive = nil,                         -- inclusive/exclusive detection
      -- jump position offset. Not used for range jumps.
      -- 0: default
      -- 1: when pos == "end" and pos < current position
      offset = nil,                            -- jump position offset
    },
    -- 🔤 LABEL LETTERS (Standard: lowercase and uppercase)
    labels = "asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM",  -- 52 labels: all letters for maximum efficiency
    rainbow = {
      enabled = false,                         -- rainbow labels disabled
      shade = 5,                               -- shade intensity (not used)
    },
    -- 🚀 PROMPT OPTIONS
    prompt = {
      enabled = true,                          -- flash prompt enabled
      prefix = { { "⚡", "FlashPromptIcon" } }, -- lightning symbol as prefix
      win_config = {                           -- window configuration for prompt
        relative = "editor",                   -- relative to editor positioned
        width = 1,                             -- 1 character wide
        height = 1,                            -- 1 line high
        row = -1,                              -- 1 line above cursor
        col = 0,                               -- at beginning of line
        zindex = 1000,                         -- high z-index for visibility
      },
    },
    -- 🔌 INTEGRATION with other plugins
    remote_op = {
      restore = true,                          -- restore after remote operation
      motion = true,                           -- motion integration enabled
    },
  },
  -- stylua: ignore
  keys = {
    -- Core navigation
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },  -- standard flash jump in normal, visual and operator mode
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },  -- treesitter-based jump for structured navigation
    
    -- Enhanced f/F/t/T (optional - remove if you prefer native)
    { "f", mode = { "n", "x", "o" }, function() 
      require("flash").jump({ 
        search = { mode = "search", max_length = 1 },  -- search only 1 character
        label = { after = { 0, 0 } }                   -- labels directly at character
      }) 
    end, desc = "Flash f" },  -- enhanced f function with labels across multiple lines
    
    { "F", mode = { "n", "x", "o" }, function() 
      require("flash").jump({ 
        search = { mode = "search", max_length = 1, forward = false },  -- backward
        label = { after = { 0, 0 } } 
      }) 
    end, desc = "Flash F" },  -- enhanced F function (backward) with labels
    
    { "t", mode = { "n", "x", "o" }, function() 
      require("flash").jump({ 
        search = { mode = "search", max_length = 1 }, 
        jump = { offset = 1 }  -- 1 position before target
      }) 
    end, desc = "Flash t" },  -- enhanced t function (till) with labels
    
    { "T", mode = { "n", "x", "o" }, function() 
      require("flash").jump({ 
        search = { mode = "search", max_length = 1, forward = false }, 
        jump = { offset = -1 }  -- 1 position after target (backward)
      }) 
    end, desc = "Flash T" },  -- enhanced T function (till backward) with labels
    
    -- Operator mode
    { "r", mode = { "o" }, function() require("flash").remote() end, desc = "Remote Flash" },  -- remote flash only in operator mode (e.g. dS = delete to treesitter node)
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },  -- treesitter search in operator and visual mode
    
    -- Toggle in command mode
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },  -- ctrl+s = toggle flash in command mode
  },
}
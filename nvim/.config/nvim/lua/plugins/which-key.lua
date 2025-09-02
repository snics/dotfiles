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
        -- General
        { "jj", desc = "Exit insert mode", icon = "󰉿", mode = "i" },
        { "<Esc>", desc = "Clear highlights", icon = "󰌑" },

        -- Closing
        { "<leader>qq", desc = "Close buffers", icon = "󰩈", mode = "n" },
        { "<leader>QQ", desc = "Close force buffer", icon = "󰩈", mode = "n" },

        -- Save
        { "<leader>ss", desc = "Save buffer", icon = "󰈸", mode = "n" },
        { "<leader>SS", desc = "Save buffer and close", icon = "󰈸", mode = "n" },

        -- Increment/decrement numbers
        { "<leader>+", icon = "" }, -- add icon to decrement number
        { "<leader>-", icon = "" }, -- add icon to decrement number

        -- LSP Config
        { "gR", desc = "Show LSP references", icon = "󰁨" },
        { "gD", desc = "Go to declaration", icon = "󰁨" },
        { "gd", desc = "Show LSP definitions", icon = "󰁨" },
        { "gi", desc = "Show LSP implementations", icon = "󰁨" },
        { "gt", desc = "Show LSP type definitions", icon = "󰁨" },
        { "<leader>ca", desc = "See available code actions", icon = "󰁨" },
        { "<leader>rn", desc = "Smart rename", icon = "󰁨" },
        { "<leader>D", desc = "Show buffer diagnostics", icon = "󰁨" },
        { "<leader>d", desc = "Show line diagnostics", icon = "󰁨" },
        { "[d", desc = "Go to previous diagnostic", icon = "󰁨" },
        { "]d", desc = "Go to next diagnostic", icon = "󰁨" },
        { "K", desc = "Show documentation for what is under cursor", icon = "󰁨" },
        { "<leader>rs", desc = "Restart LSP", icon = "󰁨" },

        -- Search/Snacks (CHANGED: was Window management)
        { "<leader>s", group = "Search", icon = "" }, -- group for window management
        { "<leader>sv", icon = "" }, -- add icon to split window vertically
        { "<leader>sh", icon = "" }, -- add icon to split windwo horizontally
        { "<leader>se", icon = "󰖮" }, -- add icon to make splits equal size
        { "<leader>sx", icon = "" }, -- add icon to close current split
        { "<leader>sm", icon = "" }, -- add icon to maximize/minimize a split

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

        -- Find (Snacks picker)
        { "<leader>f", group = "Find", icon = "" }, -- group for find operations
        { "<leader>ff", icon = "󰈞", desc = "Find files" }, -- Snacks picker
        { "<leader>fr", icon = "󰈞", desc = "Find recent files" }, -- Snacks picker
        { "<leader>fs", icon = "", desc = "Find string in current working directory" }, -- Snacks grep
        { "<leader>fc", icon = "", desc = "Find string under cursor in current working directory" }, -- Snacks grep_word
        { "<leader>ft", icon = "", desc = "Find all todos" }, -- Trouble todo

        -- Auto session
        { "<leader>w", group = "Auto session", icon = "" }, -- group for auto session
        { "<leader>ws", icon = "", desc = "Save session for auto session root dir" }, -- add icon to save session for auto session root dir
        { "<leader>wr", icon = "", desc = "Restore session for current working directory" }, -- add icon to restore session for current working directory

        -- Trouble
        { "<leader>x", group = "Trouble", icon = "" }, -- group for trouble
        { "<leader>xd", icon = "󱪘", desc = "Open trouble document diagnostics" }, -- add icon to open trouble document diagnostics
        { "<leader>xq", icon = "󰁨", desc = "Open trouble quickfix list" }, -- add icon to open trouble quickfix list
        { "<leader>xl", icon = "", desc = "Open trouble location list" }, -- add icon to open trouble location list
        { "<leader>xt", icon = "", desc = "Open todos in trouble" }, -- add icon to open todos in trouble

        -- Linting
        { "<leader>l", group = "Linting", icon = "" }, -- group for linting
        { "<leader>ll", icon = "", desc = "Trigger linting for current file" }, -- add icon to trigger linting for current file

        -- Formatting
        { "<leader>p", group = "Formatting", icon = "󰁨" }, -- group for formatting
        { "<leader>pf", icon = "󰁨", desc = "Format current file", }, -- add icon to format file or range (in visual mode)
        { "<leader>pf", icon = "󰁨", desc = "Format current selection", mode = "v" }, -- add icon to format file or range (in visual mode)
        { "<leader>pa", icon = "󰁨", desc = "Format all files in the current directory" }, -- add icon to format all files in the current directory

        -- Visual Mode Indentation
        { "<", desc = "Unindent selection", icon = "󰁨", mode = "v" }, -- unindent and keep visual mode
        { ">", desc = "Indent selection", icon = "󰁨", mode = "v" }, -- indent and keep visual mode
        { "<leader><", desc = "Unindent selection", icon = "󰁨", mode = "v" }, -- unindent with leader and keep visual mode
        { "<leader>>", desc = "Indent selection", icon = "󰁨", mode = "v" }, -- indent with leader and keep visual mode

        -- Git
        { "<leader>G", group = "Git", icon = "󰊢" }, -- group for git
        { "<leader>Go", icon = "", desc = "Open lazy git" }, -- add icon to lazy git

        -- Gitsigns hunk
        { "<leader>h", group = "Git [H]unk", icon = "" }, -- group for gitsigns
        { "<leader>hs", desc = "Stage hunk", icon = "" }, -- add icon to stage hunk
        { "<leader>hs", desc = "Stage hunk", icon = "", mode = "v" }, -- add icon to stage hunk in visual mode
        { "<leader>hr", desc = "Reset hunk", icon = "" }, -- add icon to reset hunk
        { "<leader>hr", desc = "Reset hunk", icon = "", mode = "v" }, -- add icon to reset hunk in visual mode
        { "<leader>hS", desc = "Stage buffer", icon = "" }, -- add icon to stage buffer
        { "<leader>hR", desc = "Reset buffer", icon = "" }, -- add icon to reset buffer
        { "<leader>hu", desc = "Undo stage hunk", icon = "" }, -- add icon to undo stage hunk
        { "<leader>hp", desc = "Preview hunk", icon = "" }, -- add icon to preview hunk
        { "<leader>hb", desc = "Blame line", icon = "" }, -- add icon to blame line
        { "<leader>hB", desc = "Toggle line blame", icon = "" }, -- add icon to toggle line blame
        { "<leader>hd", desc = "Diff this", icon = "" }, -- add icon to diff this
        { "<leader>hD", desc = "Diff this ~", icon = "" }, -- add icon to diff this ~
        
        -- YAML Tools
        { "<leader>y", group = "YAML Tools", icon = "󰈙" },
        { "<leader>yv", desc = "Show YAML path and value", icon = "󰈙" },
        { "<leader>yy", desc = "Yank YAML path and value", icon = "󰅌" },
        { "<leader>yk", desc = "Yank YAML key", icon = "󰌌" },
        { "<leader>yV", desc = "Yank YAML value", icon = "󰅌" },
        { "<leader>yq", desc = "YAML quickfix", icon = "󰎟" },
        { "<leader>yh", desc = "Remove YAML highlight", icon = "󰸱" },
        { "<leader>ys", desc = "YAML Snacks picker", icon = "󰍉" },
        { "<leader>yt", desc = "YAML Telescope picker", icon = "󰭎" },

        -- 🚀 Treesitter Textobjects & Incremental Selection
        { "<C-space>", desc = "Start/Expand selection", icon = "󰒅", mode = "n" },
        { "<C-space>", desc = "Expand selection", icon = "󰒅", mode = "v" },
        { "<C-s>", desc = "Expand selection to scope", icon = "󰒓", mode = "v" },
        { "<C-backspace>", desc = "Shrink selection", icon = "󰒆", mode = "v" },
        
        -- 📝 Treesitter Textobjects - Functions & Classes
        { "af", desc = "Select around function", icon = "󰊕", mode = { "o", "x" } },
        { "if", desc = "Select inside function", icon = "󰊕", mode = { "o", "x" } },
        { "ac", desc = "Select around class", icon = "󰌗", mode = { "o", "x" } },
        { "ic", desc = "Select inside class", icon = "󰌗", mode = { "o", "x" } },
        
        -- 📝 Treesitter Textobjects - Parameters & Arguments
        { "aa", desc = "Select around argument", icon = "󰏪", mode = { "o", "x" } },
        { "ia", desc = "Select inside argument", icon = "󰏪", mode = { "o", "x" } },
        
        -- 📝 Treesitter Textobjects - Control Flow
        { "ai", desc = "Select around conditional", icon = "󰕷", mode = { "o", "x" } },
        { "ii", desc = "Select inside conditional", icon = "󰕷", mode = { "o", "x" } },
        { "al", desc = "Select around loop", icon = "󰑓", mode = { "o", "x" } },
        { "il", desc = "Select inside loop", icon = "󰑓", mode = { "o", "x" } },
        
        -- 📝 Treesitter Textobjects - Blocks & Calls
        { "ab", desc = "Select around block", icon = "󰅩", mode = { "o", "x" } },
        { "ib", desc = "Select inside block", icon = "󰅩", mode = { "o", "x" } },
        { "aC", desc = "Select around call", icon = "󰘧", mode = { "o", "x" } },
        { "iC", desc = "Select inside call", icon = "󰘧", mode = { "o", "x" } },
        
        -- 🗂️ Treesitter Textobjects - YAML (Kubernetes/Helm)
        { "as", desc = "Select around assignment (key: value)", icon = "󰈙", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "is", desc = "Select inside assignment (value only)", icon = "󰈙", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "ak", desc = "Select assignment key (left side)", icon = "󰌌", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "av", desc = "Select assignment value (right side)", icon = "󰅌", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "an", desc = "Select around number", icon = "󰩥", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "at", desc = "Select around comment", icon = "󰨱", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "it", desc = "Select inside comment", icon = "󰨱", mode = { "o", "x" } }, -- Source: treesitter.lua
        { "aS", desc = "Select around YAML statement", icon = "󰈙", mode = { "o", "x" } }, -- Source: treesitter.lua
        
        -- 🧭 Treesitter Navigation - Next
        { "]m", desc = "Next function start", icon = "󰊕" },
        { "]M", desc = "Next function end", icon = "󰊕" },
        { "]c", desc = "Next class start", icon = "󰌗" },
        { "]C", desc = "Next class end", icon = "󰌗" },
        { "]i", desc = "Next conditional start", icon = "󰕷" },
        { "]I", desc = "Next conditional end", icon = "󰕷" },
        { "]l", desc = "Next loop start", icon = "󰑓" },
        { "]L", desc = "Next loop end", icon = "󰑓" },
        
        -- 🧭 Treesitter Navigation - Previous
        { "[m", desc = "Previous function start", icon = "󰊕" },
        { "[M", desc = "Previous function end", icon = "󰊕" },
        { "[c", desc = "Previous class start", icon = "󰌗" },
        { "[C", desc = "Previous class end", icon = "󰌗" },
        { "[i", desc = "Previous conditional start", icon = "󰕷" },
        { "[I", desc = "Previous conditional end", icon = "󰕷" },
        { "[l", desc = "Previous loop start", icon = "󰑓" },
        { "[L", desc = "Previous loop end", icon = "󰑓" },
        
        -- 🔄 Treesitter Swapping
        { "<leader>a", desc = "Swap parameter with next", icon = "󰓡" },
        { "<leader>A", desc = "Swap parameter with previous", icon = "󰓡" },

        -- 💬 Comment.nvim
        { "gc", group = "Comment", icon = "💬" },
        { "gcc", desc = "Toggle line comment", icon = "💬" },
        { "gbc", desc = "Toggle block comment", icon = "💬" },
        { "gco", desc = "Add comment below", icon = "💬" },
        { "gcO", desc = "Add comment above", icon = "💬" },
        { "gcA", desc = "Add comment at end of line", icon = "💬" },
        { "gc", desc = "Line comment operator", icon = "💬", mode = "v" },
        { "gb", desc = "Block comment operator", icon = "💬", mode = "v" },
    })
  end,
}
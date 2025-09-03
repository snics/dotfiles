return {
  "Exafunction/windsurf.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({
      -- General configuration
      enable_cmp_source = true, -- Always enable nvim-cmp source
      virtual_text = {
        enabled = true,  -- Enable virtual text permanently
        manual = false,  -- Automatic virtual text
        idle_delay = 75, -- Delay before requesting completions (ms)
        filetypes = {
          -- Enable for most file types
          yaml = true,
          markdown = true,
          lua = true,
          javascript = true,
          typescript = true,
          python = true,
          go = true,
          rust = true,
          html = true,
          css = true,
        },
        default_filetype_enabled = true, -- Enable for all other filetypes
        key_bindings = {
          accept = "<C-g>",        -- Accept completion
          accept_word = "<C-Right>", -- Accept next word
          accept_line = "<C-Down>",  -- Accept next line
          clear = "<C-]>",         -- Clear virtual text
          next = "<M-]>",          -- Next completion
          prev = "<M-[>",          -- Previous completion
        },
      },
      workspace_root = {
        use_lsp = true, -- Use LSP to find workspace root
        paths = {       -- Fallback paths to search for
          ".git", 
          ".hg", 
          ".svn", 
          ".bzr",
          "_FOSSIL_",
          "package.json",
          "Cargo.toml",
          "go.mod",
          "pyproject.toml",
          "requirements.txt",
        }
      }
    })
  end,
  event = "BufEnter", -- Load when entering a buffer
}

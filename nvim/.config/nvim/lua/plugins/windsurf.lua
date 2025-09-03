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
        enabled = true,   -- Enable virtual text infrastructure
        manual = false,   -- Allow automatic virtual text (we control via config)
        idle_delay = 75,  -- Delay before requesting completions (ms)
        virtual_text_priority = 65535,
        map_keys = true,
        accept_fallback = nil,
        default_filetype_enabled = false, -- We control via filetypes
        key_bindings = {
          accept = "<C-l>",        -- Accept completion
          accept_word = "<C-Right>", -- Accept next word
          accept_line = "<C-Down>",  -- Accept next line
          clear = "<M-c>",         -- Clear virtual text
          next = "<M-]>",          -- Next completion
          prev = "<M-[>",          -- Previous completion
        },
        filetypes = {}, -- Start with no filetypes (disabled by default)
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

    -- Session-scoped virtual text toggle (default OFF)
    vim.g.windsurf_virtual_text_enabled = false

    -- Get access to the codeium config to modify filetypes dynamically
    local codeium_config = require('codeium.config')
    
    local function _windsurf_apply_vt_autocmds()
      if vim.g.windsurf_virtual_text_enabled then
        -- Enable virtual text by setting filetypes
        codeium_config.options.virtual_text.filetypes = {
          lua = true,
          javascript = true,
          typescript = true,
          python = true,
          go = true,
          rust = true,
          html = true,
          css = true,
          yaml = true,
          markdown = true,
        }
        codeium_config.options.virtual_text.default_filetype_enabled = true
      else
        -- Disable virtual text by clearing filetypes
        codeium_config.options.virtual_text.filetypes = {}
        codeium_config.options.virtual_text.default_filetype_enabled = false
        -- Clear any existing virtual text
        local ok, vt = pcall(require, "codeium.virtual_text")
        if ok and vt then
          pcall(function()
            vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace('codeium'), 0, -1)
          end)
        end
      end
    end

    vim.api.nvim_create_user_command("WindsurfVirtualTextToggle", function()
      vim.g.windsurf_virtual_text_enabled = not vim.g.windsurf_virtual_text_enabled
      _windsurf_apply_vt_autocmds()
      vim.notify("Windsurf virtual text: " .. (vim.g.windsurf_virtual_text_enabled and "ON" or "OFF"))
    end, {})

    vim.api.nvim_create_user_command("WindsurfVirtualTextOn", function()
      vim.g.windsurf_virtual_text_enabled = true
      _windsurf_apply_vt_autocmds()
      vim.notify("Windsurf virtual text: ON")
    end, {})

    vim.api.nvim_create_user_command("WindsurfVirtualTextOff", function()
      vim.g.windsurf_virtual_text_enabled = false
      _windsurf_apply_vt_autocmds()
      vim.notify("Windsurf virtual text: OFF")
    end, {})

    -- Keymaps
    vim.keymap.set("n", "<leader>wv", "<cmd>WindsurfVirtualTextToggle<CR>", { desc = "Windsurf: Toggle virtual text" })
    vim.keymap.set("n", "<leader>wV", "<cmd>WindsurfVirtualTextOn<CR>", { desc = "Windsurf: Virtual text ON" })
    vim.keymap.set("n", "<leader>wx", "<cmd>WindsurfVirtualTextOff<CR>", { desc = "Windsurf: Virtual text OFF" })

    -- Initialize OFF
    _windsurf_apply_vt_autocmds()
  end,
  event = "BufEnter", -- Load when entering a buffer
}

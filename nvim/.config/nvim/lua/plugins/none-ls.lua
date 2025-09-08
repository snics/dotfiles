return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvimtools/none-ls-extras.nvim", -- Wichtig für zusätzliche Sources wie eslint_d
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics
    local code_actions = null_ls.builtins.code_actions
    local hover = null_ls.builtins.hover
    
    null_ls.setup({
      -- Sources define what tools none-ls will use
      sources = {
        
        -- Lua formatter (essential for Neovim config)
        formatting.stylua.with({
          -- Configure stylua options
          extra_args = {
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
            "--quote-style",
            "AutoPreferDouble",
          },
        }),
       
        hover.dictionary,
      },
      on_attach = function(client, bufnr)
        -- Format on save
        if client.supports_method("textDocument/formatting") then
          -- Create an autocommand group for formatting
          local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
          
          -- Clear existing autocommands for this buffer
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          
          -- Format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
                timeout_ms = 2000,  -- 2 second timeout
                filter = function(c)
                  -- Only use null-ls for formatting
                  return c.name == "null-ls"
                end,
              })
            end,
          })
        end
        
        
        local opts = { buffer = bufnr, noremap = true, silent = true }
        
        -- Manual formatting
        vim.keymap.set({ "n", "v" }, "<leader>pf", function()
          vim.lsp.buf.format({
            timeout_ms = 2000,
            filter = function(c)
              return c.name == "null-ls"
            end,
          })
        end, vim.tbl_extend("force", opts, { desc = "Format file or range" }))
        
        -- Show hover documentation
        vim.keymap.set("n", "K", vim.lsp.buf.hover, 
          vim.tbl_extend("force", opts, { desc = "Show hover documentation" })
        )
      end,
      
      -- Debounce diagnostics to avoid too frequent updates
      debounce = 150,  -- milliseconds
      
      -- Default timeout for all sources
      default_timeout = 5000,  -- 5 seconds
      
      -- Diagnostic display configuration
      diagnostic_config = {
        underline = true,         -- Underline problematic code
        virtual_text = true,      -- Show inline diagnostic messages
        signs = true,             -- Show signs in the sign column
        update_in_insert = false, -- Don't update diagnostics in insert mode
        severity_sort = true,     -- Sort diagnostics by severity
      },
      
      -- Debug mode - set to true when troubleshooting
      debug = false,
    })
    
    -- ==============================================================================
    -- Step 6: Utility Commands
    -- ==============================================================================
    
    -- Command to show none-ls log (useful for debugging)
    vim.keymap.set("n", "<leader>nl", function()
      vim.cmd("NullLsLog")
    end, { desc = "Open none-ls log" })
    
    -- Command to show none-ls info (shows active sources)
    vim.keymap.set("n", "<leader>ni", function()
      vim.cmd("NullLsInfo")
    end, { desc = "Show none-ls info" })
  end,
}
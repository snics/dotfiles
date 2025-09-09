return {
  "olexsmir/gopher.nvim",
  ft = "go",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  
  config = function()
    require("gopher").setup({
      -- Log level for debugging (INFO, DEBUG, TRACE)
      log_level = vim.log.levels.INFO,
      
      -- Timeout for running internal commands (in milliseconds)
      timeout = 5000,
      
      -- Commands configuration
      commands = {
        go = "go",
        gomodifytags = "gomodifytags",
        gotests = "gotests",
        impl = "impl",
        iferr = "iferr",
      },
      
      -- gotests configuration for generating tests
      gotests = {
        -- Use default template for test generation
        template = "default",
        -- Path to custom test templates (optional)
        template_dir = nil,
        -- DISABLED: The -named flag is not supported in the current gotests version
        -- Use map instead of slice for table tests (with test name as key)
        named = false,
      },
      
      -- gomodifytags configuration for struct tags
      gotag = {
        -- Transform tag names (snakecase, camelcase, lispcase, pascalcase, keep)
        transform = "snakecase",
        -- Default tags to add when no tag is specified
        default_tag = "json",
      },
      
      -- iferr configuration for error handling
      iferr = {
        -- Custom error message (nil uses default)
        message = nil,
      },
    })
    
    -- ================================================================================
    -- KEYMAPS
    -- ================================================================================
    
    local opts = { noremap = true, silent = true }
    
    -- Struct Tags Management
    vim.keymap.set("n", "<leader>gtj", "<cmd>GoTagAdd json<cr>", 
      vim.tbl_extend("force", opts, { desc = "Add json tags to struct" })
    )
    vim.keymap.set("n", "<leader>gty", "<cmd>GoTagAdd yaml<cr>", 
      vim.tbl_extend("force", opts, { desc = "Add yaml tags to struct" })
    )
    vim.keymap.set("n", "<leader>gtx", "<cmd>GoTagAdd xml<cr>", 
      vim.tbl_extend("force", opts, { desc = "Add xml tags to struct" })
    )
    vim.keymap.set("n", "<leader>gtr", "<cmd>GoTagRm<cr>", 
      vim.tbl_extend("force", opts, { desc = "Remove tags from struct" })
    )
    
    -- Test Generation
    vim.keymap.set("n", "<leader>gta", "<cmd>GoTestAdd<cr>", 
      vim.tbl_extend("force", opts, { desc = "Generate test for function under cursor" })
    )
    vim.keymap.set("n", "<leader>gtA", "<cmd>GoTestsAll<cr>", 
      vim.tbl_extend("force", opts, { desc = "Generate tests for all functions" })
    )
    vim.keymap.set("n", "<leader>gte", "<cmd>GoTestsExp<cr>", 
      vim.tbl_extend("force", opts, { desc = "Generate tests for exported functions" })
    )
    
    -- Go Module Commands
    vim.keymap.set("n", "<leader>gmt", "<cmd>GoMod tidy<cr>", 
      vim.tbl_extend("force", opts, { desc = "Run go mod tidy" })
    )
    vim.keymap.set("n", "<leader>gmi", function()
      vim.ui.input({ prompt = "Module name: " }, function(input)
        if input then
          vim.cmd("GoMod init " .. input)
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Run go mod init" }))
    
    vim.keymap.set("n", "<leader>gmg", function()
      vim.ui.input({ prompt = "Package to get: " }, function(input)
        if input then
          vim.cmd("GoGet " .. input)
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Run go get" }))
    
    -- Interface Implementation
    vim.keymap.set("n", "<leader>gii", function()
      vim.ui.input({ prompt = "Interface to implement: " }, function(input)
        if input then
          vim.cmd("GoImpl " .. input)
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Implement interface" }))
    
    -- Error Handling
    vim.keymap.set("n", "<leader>gie", "<cmd>GoIfErr<cr>", 
      vim.tbl_extend("force", opts, { desc = "Generate if err != nil {}" })
    )
    
    -- Documentation
    vim.keymap.set("n", "<leader>gc", "<cmd>GoCmt<cr>", 
      vim.tbl_extend("force", opts, { desc = "Generate doc comment" })
    )
    
    -- Go Generate
    vim.keymap.set("n", "<leader>gg", "<cmd>GoGenerate<cr>", 
      vim.tbl_extend("force", opts, { desc = "Run go generate" })
    )
    vim.keymap.set("n", "<leader>gG", "<cmd>GoGenerate %<cr>", 
      vim.tbl_extend("force", opts, { desc = "Run go generate for current file" })
    )
    
    -- ================================================================================
    -- WHICH-KEY INTEGRATION (if installed)
    -- ================================================================================
    
    local ok, which_key = pcall(require, "which-key")
    if ok then
      which_key.add({
        { "<leader>g", group = "Go", icon = "" },
        { "<leader>gt", group = "Go Tags/Tests", icon = "" },
        { "<leader>gm", group = "Go Modules", icon = "" },
        { "<leader>gi", group = "Go Interface/Error", icon = "" },
      })
    end
  end,
}

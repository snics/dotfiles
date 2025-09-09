return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvimtools/none-ls-extras.nvim", -- Wichtig für zusätzliche Sources wie eslint_d
    "gbprod/none-ls-shellcheck.nvim", -- Shellcheck diagnostics und code actions
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics
    local code_actions = null_ls.builtins.code_actions
    local hover = null_ls.builtins.hover
    local completion = null_ls.builtins.completion

    -- Custom sources from config.none-ls
    local my_formatting = require("config.none-ls.formatting")
    local my_diagnostics = require("config.none-ls.diagnostics")
    local my_code_actions = require("config.none-ls.code_actions")
    
    -- Additional sources from none-ls-shellcheck
    local shellcheck_diagnostics = require("none-ls-shellcheck.diagnostics")
    local shellcheck_code_actions = require("none-ls-shellcheck.code_actions")
    
    -- Build the complete sources list
    local sources = {
        -- ================================================================================
        -- FORMATTERS
        -- ================================================================================
        
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
        
        -- Smart formatter selection (Biome/Deno/PrettierD)
        my_formatting.biome,
        my_formatting.deno_fmt,
        my_formatting.prettierd,
        
        -- Shell formatter - bash/sh/zsh
        formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci" }, -- 2 spaces indent, indent case statements
        }),
        
        -- TOML formatter
        my_formatting.taplo,
        
        -- YAML formatter
        formatting.yamlfmt,
        
        -- SQL formatter (via sqlfluff)
        formatting.sqlfluff.with({
          extra_args = function(params)
            -- Try to detect SQL dialect from filename or project
            local dialect = "postgres" -- default
            if params.bufname:match("mysql") then
              dialect = "mysql"
            elseif params.bufname:match("sqlite") then
              dialect = "sqlite"
            end
            return { "--dialect", dialect }
          end,
        }),
        
        -- Terraform formatter (native terraform fmt via null-ls)
        formatting.terraform_fmt.with({
          filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
        }),
        
        -- ================================================================================
        -- LINTERS / DIAGNOSTICS  
        -- ================================================================================
        
        -- Smart linter selection (Biome/Deno/OXLint/ESLint)
        my_diagnostics.biome,
        my_diagnostics.deno_lint,
        my_diagnostics.oxlint,
        my_diagnostics.eslint,
        
        -- Shell linter - detects common shell script issues
        -- Using none-ls-shellcheck plugin since it was removed from core
        shellcheck_diagnostics,
        
        -- YAML linter
        diagnostics.yamllint.with({
          extra_args = { "-d", "relaxed" }, -- Use relaxed ruleset
        }),
        
        -- Markdown linter (using markdownlint-cli2)
        diagnostics.markdownlint_cli2.with({
          args = { "$FILENAME" },
        }),
        
        -- HTML linter (markuplint)
        diagnostics.markuplint,
        
        -- CSS/SCSS/Less linter
        diagnostics.stylelint,
        
        -- Lua linter
        diagnostics.selene,
        
        -- SQL linter (via sqlfluff)
        diagnostics.sqlfluff.with({
          extra_args = function(params)
            -- Try to detect SQL dialect from filename or project
            local dialect = "postgres" -- default
            if params.bufname:match("mysql") then
              dialect = "mysql"
            elseif params.bufname:match("sqlite") then
              dialect = "sqlite"
            end
            return { "--dialect", dialect }
          end,
        }),
        
        -- Ansible linter (only in Ansible projects)
        diagnostics.ansiblelint.with({
          condition = function(utils)
            return utils.root_has_file({ "ansible.cfg", "playbook.yml", "site.yml", "roles" })
          end,
        }),
        
        -- GitHub Actions linter
        diagnostics.actionlint,
        
        -- Dockerfile linter
        diagnostics.hadolint.with({
          filetypes = { "dockerfile" },
          -- Force hadolint to run on any file that looks like a Dockerfile
          runtime_condition = function(params)
            -- Run on any file that contains "Dockerfile" in the name
            return params.bufname:match("Dockerfile") ~= nil
              or params.bufname:match("dockerfile") ~= nil
              or params.bufname:match("Containerfile") ~= nil
              or vim.bo.filetype == "dockerfile"
          end,
        }),
        
        -- Terraform linter (only in Terraform projects)
        -- NOTE: tflint is not available as a built-in in none-ls
        -- You can use terraform-ls for diagnostics or run tflint externally
        -- TODO: Consider using tflint as an external command source
        -- diagnostics.tflint.with({
        --   condition = function(utils)
        --     return utils.root_has_file({ "*.tf", "*.tfvars", ".terraform" })
        --   end,
        -- }),
        my_diagnostics.tflint,
        
        -- Security scanners
        -- Temporarily disabled due to Python deprecation warnings
        -- diagnostics.semgrep.with({
        --   extra_args = { "--config", "auto" }, -- Use automatic ruleset detection
        -- }),
        
        diagnostics.trivy,
        
        -- ================================================================================
        -- CODE ACTIONS
        -- ================================================================================
        
        -- Smart code actions selection (loaded from separate files)
        my_code_actions.eslint,
        
        -- Shell script code actions
        -- Using none-ls-shellcheck plugin since it was removed from core
        shellcheck_code_actions,
        
        -- ================================================================================
        -- HOVER
        -- ================================================================================
        
        -- Dictionary hover for word definitions
        hover.dictionary,
        
        -- ================================================================================
        -- GO TOOLS (TODO: Enable later)
        -- ================================================================================
        -- formatting.gofumpt,          -- Stricter Go formatter
        -- formatting.goimports,         -- Go import formatter
        -- formatting.golines,           -- Go line wrapper
        -- diagnostics.golangci_lint,   -- Go meta-linter
        
        -- ================================================================================
        -- SMART TOOL SELECTION NOTES
        -- ================================================================================
        -- The following tools are now automatically selected based on project config:
        -- 1. Deno projects: deno_fmt + deno_lint (if deno.json exists)
        -- 2. Biome projects: biome formatter + linter (if biome.json exists)
        -- 3. OXLint projects: oxlint linter (if oxlint.json exists)
        -- 4. ESLint projects: prettierd + eslint (if .eslintrc exists)
        -- 5. Default: prettierd + eslint (if no specific config found)
        
        -- ================================================================================
        -- TOOLS NOT AVAILABLE IN NONE-LS (installed via Mason but used differently)
        -- ================================================================================
        -- kube-linter     -- Kubernetes/Helm linter (use via external command/integration)
        -- trufflehog      -- Secret scanner (use via pre-commit hooks or CI)
      }

    -- Setup none-ls with our sources
    null_ls.setup({
      sources = sources,
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
                  -- Use null-ls for formatting, but allow certain LSPs as fallback
                  return c.name == "null-ls" 
                    or c.name == "rust_analyzer"  -- Rust has excellent built-in formatting
                    or c.name == "gopls"           -- Go fmt is standard
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
              -- Use null-ls for formatting, but allow certain LSPs as fallback
              return c.name == "null-ls" 
                or c.name == "rust_analyzer"  -- Rust has excellent built-in formatting
                or c.name == "gopls"           -- Go fmt is standard
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
        virtual_text = false,     -- DISABLED: Using tiny-inline-diagnostic instead
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
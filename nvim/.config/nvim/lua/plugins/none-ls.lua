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
    local completion = null_ls.builtins.completion
    
    -- Additional sources from none-ls-extras
    local require_eslint = require("none-ls.diagnostics.eslint_d")
    local require_eslint_actions = require("none-ls.code_actions.eslint_d")
    
    null_ls.setup({
      -- Sources define what tools none-ls will use
      sources = {
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
        
        -- Prettier Daemon - Fast formatter for HTML/CSS/JS/TS/JSON/MD/YAML etc.
        formatting.prettierd.with({
          -- Will use .prettierrc if it exists in project
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc.json"),
          },
          filetypes = {
            "javascript", 
            "javascriptreact", 
            "typescript", 
            "typescriptreact",
            "vue",
            "css", 
            "scss",
            "less", 
            "html",
            "json",
            "jsonc", 
            "yaml", 
            "markdown",
            "markdown.mdx",
            "graphql", 
            "handlebars",
          },
        }),
        
        -- Shell formatter - bash/sh/zsh
        formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci" }, -- 2 spaces indent, indent case statements
        }),
        
        -- TOML formatter
        formatting.taplo,
        
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
        
        -- ESLint Daemon - JavaScript/TypeScript linter (from none-ls-extras)
        require_eslint.with({
          condition = function(utils)
            -- Only enable if ESLint config exists in the project
            return utils.root_has_file({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc.json",
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs",
            })
          end,
        }),
        
        -- Shell linter - detects common shell script issues
        diagnostics.shellcheck,
        
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
          -- Will auto-detect Dockerfile, Containerfile, *.Dockerfile
        }),
        
        -- Terraform linter (only in Terraform projects)
        diagnostics.tflint.with({
          condition = function(utils)
            return utils.root_has_file({ "*.tf", "*.tfvars", ".terraform" })
          end,
        }),
        
        -- Security scanners
        diagnostics.semgrep.with({
          extra_args = { "--config", "auto" }, -- Use automatic ruleset detection
        }),
        
        diagnostics.trivy.with({
          args = {
            "fs",
            "--scanners",
            "vuln,secret,misconfig",
            "--format",
            "json",
            "--quiet",
            "$DIRNAME",
          },
        }),
        
        -- ================================================================================
        -- CODE ACTIONS
        -- ================================================================================
        
        -- ESLint code actions (from none-ls-extras)
        require_eslint_actions.with({
          condition = function(utils)
            -- Only enable if ESLint config exists in the project
            return utils.root_has_file({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc.json",
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs",
            })
          end,
        }),
        
        -- Shell script code actions
        code_actions.shellcheck,
        
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
        -- BIOME (TODO: Enable later - JS/TS/JSON/HTML/CSS all-in-one)
        -- ================================================================================
        -- formatting.biome,            -- Fast formatter
        -- diagnostics.biome,           -- Fast linter
        
        -- ================================================================================
        -- TOOLS NOT AVAILABLE IN NONE-LS (installed via Mason but used differently)
        -- ================================================================================
        -- kube-linter     -- Kubernetes/Helm linter (use via external command/integration)
        -- trufflehog      -- Secret scanner (use via pre-commit hooks or CI)
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
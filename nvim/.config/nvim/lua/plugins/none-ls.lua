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

    null_ls.setup({
      sources = {
        -- ===========================
        -- FORMATTING
        -- ===========================

        -- Web Development (JS/TS/HTML/CSS/JSON/YAML/Markdown)
        formatting.prettierd.with({
          filetypes = {
            "css",
            "graphql",
            "html",
            "javascript",
            "javascriptreact",
            "json",
            "markdown",
            "typescript",
            "typescriptreact",
            "yaml",
          },
          extra_args = { "--no-semi", "--single-quote" }, -- Optional: Configure prettier options
        }),

        -- Shell Scripts
        formatting.shfmt.with({
          filetypes = { "sh", "bash", "zsh" },
          extra_args = { "-i", "2", "-ci" }, -- 2 spaces indent, indent case labels
        }),

        -- Lua
        formatting.stylua.with({
          extra_args = {
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
            "--quote-style",
            "AutoPreferDouble",
          },
        }),

        -- Go (using gofumpt which is stricter than gofmt)
        formatting.gofumpt,
        formatting.goimports, -- Organize imports

        -- SQL
        formatting.sqlformat.with({
          extra_args = {
            "--reindent",
            "--indent_width",
            "2",
            "--keywords",
            "upper",
          },
        }),

        -- Python (if needed in future)
        -- formatting.black,
        -- formatting.isort, -- Python import sorting

        -- ===========================
        -- DIAGNOSTICS (LINTING)
        -- ===========================

        -- JavaScript/TypeScript (from none-ls-extras)
        require("none-ls.diagnostics.eslint_d").with({
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
          condition = function(utils)
            return utils.root_has_file({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.yml",
              ".eslintrc.yaml",
              "eslint.config.js",
            })
          end,
        }),

        -- Shell Scripts (shellcheck is only available as code_actions, not diagnostics)
        -- diagnostics.shellcheck is not available in null-ls builtins

        -- CSS/SCSS/LESS
        diagnostics.stylelint.with({
          filetypes = { "css", "scss", "sass", "less" },
          extra_args = { "--formatter", "json" },
        }),

        -- Docker
        diagnostics.hadolint.with({
          filetypes = { "dockerfile" },
        }),

        -- Lua
        diagnostics.selene.with({
          condition = function(utils)
            return utils.root_has_file({ "selene.toml", ".selene.toml" })
          end,
        }),

        -- Markdown
        diagnostics.markdownlint.with({
          filetypes = { "markdown" },
          extra_args = { "--config", ".markdownlint.json" },
        }),

        -- YAML
        diagnostics.yamllint.with({
          filetypes = { "yaml", "yml" },
          extra_args = { "-f", "parsable" },
        }),

        -- Ansible (if ansible-lint is installed)
        diagnostics.ansiblelint.with({
          filetypes = { "yaml.ansible" },
          condition = function(utils)
            return utils.root_has_file({ "ansible.cfg", ".ansible-lint" })
          end,
        }),

        -- Go
        diagnostics.golangci_lint.with({
          extra_args = { "--fast" },
        }),

        -- Terraform
        diagnostics.terraform_validate,
        diagnostics.tfsec, -- Security scanner for Terraform

        -- GitHub Actions
        diagnostics.actionlint.with({
          filetypes = { "yaml" },
          condition = function(utils)
            local path = vim.fn.expand("%:p")
            return path:match(".github/workflows/") ~= nil
          end,
        }),

        -- JSON (jsonlint is not available as a diagnostic source in null-ls builtins)
        -- diagnostics.jsonlint is not available in null-ls builtins

        -- ===========================
        -- CODE ACTIONS
        -- ===========================

        -- Shell Scripts (shellcheck code_actions not available in null-ls builtins)
        -- code_actions.shellcheck is not available in null-ls builtins

        -- JavaScript/TypeScript (from none-ls-extras)
        require("none-ls.code_actions.eslint_d"),

        -- Git
        code_actions.gitsigns, -- Git staging hunks, etc.

        -- ===========================
        -- HOVER (Documentation)
        -- ===========================

        -- Dictionary definitions
        null_ls.builtins.hover.dictionary,
      },

      -- Format on save configuration
      on_attach = function(client, bufnr)
        -- Format on save
        if client.supports_method("textDocument/formatting") then
          local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
                timeout_ms = 2000,
                filter = function(c)
                  -- Only use null-ls for formatting (avoid conflicts with other LSPs)
                  return c.name == "null-ls"
                end,
              })
            end,
          })
        end

        -- Set up keymaps
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

        -- Trigger linting manually
        vim.keymap.set("n", "<leader>ll", function()
          -- Force diagnostics refresh
          vim.diagnostic.reset()
          vim.cmd("edit")
        end, vim.tbl_extend("force", opts, { desc = "Trigger linting for current file" }))

        -- Show hover documentation
        vim.keymap.set(
          "n",
          "K",
          vim.lsp.buf.hover,
          vim.tbl_extend("force", opts, { desc = "Show hover documentation" })
        )
      end,

      -- Performance optimization
      debounce = 150, -- Debounce diagnostics
      default_timeout = 5000, -- Default timeout for sources
      diagnostic_config = {
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
      },

      -- Debug mode (set to true for troubleshooting)
      debug = false,
    })

    -- Additional configuration for specific tools

    -- Configure prettierd to use project config if available
    local prettierd = require("null-ls.builtins.formatting.prettierd")
    prettierd._opts.cwd = function(params)
      return vim.fn.fnamemodify(params.bufname, ":h")
    end

    -- Log output for debugging (when debug = true)
    vim.keymap.set("n", "<leader>nl", function()
      vim.cmd("NullLsLog")
    end, { desc = "Open null-ls log" })

    -- Info about null-ls sources
    vim.keymap.set("n", "<leader>ni", function()
      vim.cmd("NullLsInfo")
    end, { desc = "Show null-ls info" })
  end,
}

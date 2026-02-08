-- Linting and formatting via none-ls (null-ls fork).
-- Injects diagnostics, formatting, code actions into the LSP pipeline.
--
-- Available setup() options:
--   sources              — table of diagnostic/formatting/code_action sources
--   on_attach            — callback on buffer attach (client, bufnr)
--   debounce             — default: 250 — ms between buffer change and diagnostic update
--   default_timeout      — default: 5000 — ms before sources timeout (-1 = no timeout)
--   debug                — default: false — verbose logging (performance impact)
--   diagnostics_format   — default: "#{m}" — format string: #{m}=message, #{s}=source, #{c}=code
--   root_dir             — default: root_pattern(".null-ls-root", "Makefile", ".git")
--   update_in_insert     — default: false — run diagnostics in insert mode
--   log_level            — default: "warn" — off/error/warn/info/debug/trace
--   temp_dir             — default: nil — directory for temp files
--   should_attach        — default: nil — function(bufnr) to filter buffers
--   notify_format        — default: "[null-ls] %s"
--   fallback_severity    — default: ERROR
--   border               — default: nil — :NullLsInfo window border
--   diagnostic_config    — default: {} — vim.diagnostic.config() overrides
--   on_init / on_exit    — default: nil — lifecycle callbacks
return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvimtools/none-ls-extras.nvim", -- Additional sources like eslint_d
        "gbprod/none-ls-shellcheck.nvim", -- Shellcheck diagnostics and code actions
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics
        local hover = null_ls.builtins.hover

        -- Custom sources from config.none-ls
        local my_formatting = require("config.none-ls.formatting")
        local my_diagnostics = require("config.none-ls.diagnostics")
        local my_code_actions = require("config.none-ls.code_actions")

        -- Additional sources from none-ls-shellcheck
        local shellcheck_diagnostics = require("none-ls-shellcheck.diagnostics")
        local shellcheck_code_actions = require("none-ls-shellcheck.code_actions")

        -- Build the complete sources list organized by language (alphabetically)
        local sources = {
            -- Ansible

            -- Ansible linter (only in Ansible projects)
            diagnostics.ansiblelint.with({
                condition = function(utils)
                    return utils.root_has_file({ "ansible.cfg", "playbook.yml", "site.yml", "roles" })
                end,
            }),

            -- CSS/SCSS/LESS

            -- CSS/SCSS/Less linter
            diagnostics.stylelint,

            -- Docker

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

            -- GitHub Actions

            -- GitHub Actions linter
            diagnostics.actionlint,

            -- Go

            -- Go formatters
            formatting.gofumpt.with({
                filetypes = { "go" },
            }),

            formatting.goimports_reviser.with({
                filetypes = { "go" },
                extra_args = {
                    "-rm-unused", -- Remove unused imports
                    "-set-alias", -- Set alias for long import names
                    "-format", -- Format imports
                },
            }),

            formatting.golines.with({
                filetypes = { "go" },
                extra_args = {
                    "--max-len", "100", -- Maximum line length
                    "--tab-len", "4", -- Tab length
                    "--reformat-tags", -- Reformat struct tags
                },
            }),

            -- Go linter (comprehensive meta-linter)
            diagnostics.golangci_lint.with({
                filetypes = { "go" },
                condition = function(utils)
                    -- Only run in Go projects
                    return utils.root_has_file({ "go.mod", "go.work", "main.go" })
                end,
            }),

            -- HTML

            -- HTML linter (markuplint)
            diagnostics.markuplint,

            -- JavaScript/TypeScript (Smart Selection)

            -- Smart formatter selection (Biome/Deno/PrettierD)
            my_formatting.biome,
            my_formatting.deno_fmt,
            my_formatting.prettierd,

            -- Smart linter selection (Biome/Deno/OXLint/ESLint)
            my_diagnostics.biome,
            my_diagnostics.deno_lint,
            my_diagnostics.oxlint,
            my_diagnostics.eslint,

            -- Smart code actions selection (loaded from separate files)
            my_code_actions.eslint,

            -- Kubernetes/Helm

            -- Kubernetes/Helm linter (only in K8s projects)
            my_diagnostics.kube_linter,

            -- Lua

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

            -- Lua linter
            diagnostics.selene,

            -- Markdown

            -- Markdown linter (using markdownlint-cli2)
            diagnostics.markdownlint_cli2.with({
                args = { "$FILENAME" },
            }),

            -- Security

            -- Security scanners
            diagnostics.trivy,

            -- Secret scanner (only in git repositories)
            my_diagnostics.trufflehog,

            -- Shell Scripts

            -- Shell formatter - bash/sh/zsh
            formatting.shfmt.with({
                extra_args = { "-i", "2", "-ci" }, -- 2 spaces indent, indent case statements
            }),

            -- Shell linter - detects common shell script issues
            -- Using none-ls-shellcheck plugin since it was removed from core
            shellcheck_diagnostics,

            -- Shell script code actions
            -- Using none-ls-shellcheck plugin since it was removed from core
            shellcheck_code_actions,

            -- SQL

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

            -- Terraform

            -- Terraform formatter (native terraform fmt via null-ls)
            formatting.terraform_fmt.with({
                filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
            }),

            -- Terraform linter
            my_diagnostics.tflint,

            -- TOML

            -- TOML formatter
            my_formatting.taplo,

            -- YAML

            -- YAML formatter
            formatting.yamlfmt,

            -- YAML linter
            diagnostics.yamllint.with({
                extra_args = { "-d", "relaxed" }, -- Use relaxed ruleset
            }),

            -- General Utilities

            -- Dictionary hover for word definitions
            hover.dictionary,

            -- ================================================================================
            -- SMART TOOL SELECTION NOTES
            -- ================================================================================
            -- The following tools are now automatically selected based on project config:
            -- 1. Deno projects: deno_fmt + deno_lint (if deno.json exists)
            -- 2. Biome projects: biome formatter + linter (if biome.json exists)
            -- 3. OXLint projects: oxlint linter (if oxlint.json exists)
            -- 4. ESLint projects: prettierd + eslint (if .eslintrc exists)
            -- 5. Default: prettierd + eslint (if no specific config found)
        }

        -- Setup none-ls with our sources
        null_ls.setup({
            sources = sources,

            -- Format-on-save and formatting keymaps
            on_attach = function(client, bufnr)
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
                                timeout_ms = 2000, -- 2 second timeout
                                filter = function(c)
                                    -- Use null-ls for formatting, but allow certain LSPs as fallback
                                    return c.name == "null-ls"
                                        or c.name == "rust_analyzer" -- Rust has excellent built-in formatting
                                        or c.name == "gopls" -- Go fmt is standard
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
                                or c.name == "rust_analyzer"
                                or c.name == "gopls"
                        end,
                    })
                end, vim.tbl_extend("force", opts, { desc = "Format file or range" }))

                -- ================================================================================
                -- NONE-LS SPECIFIC KEYMAPS
                -- Note: General LSP keymaps (K, ]d, [d, code_action, rename) are defined
                -- centrally in lspconfig.lua via LspAttach. Do NOT duplicate them here.
                -- ================================================================================

                -- Toggle none-ls diagnostics
                vim.keymap.set("n", "<leader>ld", function()
                    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
                end, vim.tbl_extend("force", opts, { desc = "Toggle diagnostics" }))

                -- Show diagnostics in floating window
                vim.keymap.set("n", "<leader>lD", vim.diagnostic.open_float,
                    vim.tbl_extend("force", opts, { desc = "Show diagnostics in float" })
                )

                -- Clear diagnostics
                vim.keymap.set("n", "<leader>lc", function()
                    vim.diagnostic.reset()
                end, vim.tbl_extend("force", opts, { desc = "Reset diagnostics" }))
            end,

            -- Debounce diagnostics to avoid too frequent updates
            debounce = 150, -- default: 250 — faster feedback

            -- Default timeout for all sources
            default_timeout = 5000, -- default: 5000

            -- Show source name in diagnostic messages
            diagnostics_format = "#{m} (#{s})", -- default: "#{m}" — appends source name

            -- Skip attaching to files in node_modules
            should_attach = function(bufnr)
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                return not bufname:match("node_modules")
            end,

            -- Diagnostic display: configured centrally in lspconfig.lua
            -- none-ls inherits the global vim.diagnostic.config() automatically.

            -- Debug mode - set to true when troubleshooting
            debug = false, -- default: false
        })

        -- ==============================================================================
        -- Utility Commands (global, not buffer-local)
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

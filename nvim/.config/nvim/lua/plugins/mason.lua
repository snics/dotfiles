return {
    "williamboman/mason.nvim",
    priority = 100, -- High priority to ensure Mason loads first
    build = ":MasonUpdate",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "b0o/schemastore.nvim", -- JSON schemas for yamlls and jsonls
    },
    config = function()
        -- import mason
        local mason = require("mason")

        -- import mason-lspconfig
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "",
                    package_pending = "󰜉",
                    package_uninstalled = "",
                },
            },
        })

        mason_lspconfig.setup({
            -- list of servers for mason to install
            ensure_installed = {
                -- Core Language Servers
                "ansiblels",                       -- Ansible-YAML (Playbooks/Roles/Inventory); *.yml, *.yaml
                "bashls",                          -- Shell scripts (bash/sh; zsh has no dedicated LS); *.sh
                "cssls",                           -- CSS/SCSS/LESS; *.css, *.scss, *.less
                "css_variables",                   -- CSS Variables/Custom Properties; CSS :root, var()
                "denols",                          -- Deno (TS/JS runtime & tooling); *.ts, *.tsx, *.js, *.jsx (deno projects)
                "docker_compose_language_service", -- Docker-Compose YAML (Compose v2); docker-compose.yml, compose.yml/.yaml
                "dockerls",                        -- Dockerfile; Dockerfile, Containerfile, *.Dockerfile
                "emmet_ls",                        -- Emmet for HTML/CSS; quick snippets
                "gopls",                           -- Go; *.go, go.mod, go.work
                "graphql",                         -- GraphQL schemas/operations; *.graphql, *.gql (+ gql tagged templates)
                "helm_ls",                         -- Helm charts (Kubernetes); *.yaml templates
                "html",                            -- HTML; *.html
                -- rust_analyzer: managed by rustaceanvim (not mason-lspconfig)
                "jsonls",                          -- JSON/JSONC (e.g. tsconfig); *.json, *.jsonc
                "lua_ls",                          -- Lua (incl. Neovim Lua); *.lua
                "marksman",                        -- Markdown; *.md
                "mdx_analyzer",                    -- MDX (Markdown + JSX/TSX); *.mdx
                "sqlls",                           -- SQL Language Server; *.sql
                "tailwindcss",                     -- Tailwind IntelliSense (classes in HTML/JS/TS/JSX/TSX)
                "terraformls",                     -- Terraform (HCL); *.tf, *.tfvars
                "tofu_ls",                         -- OpenTofu (HCL); *.tf, *.tfvars (works alongside terraformls)
                "ts_ls",                           -- TypeScript/JavaScript/React; *.ts, *.tsx, *.js, *.jsx
                "yamlls",                          -- YAML (incl. K8s/KYAML via schemas); *.yml, *.yaml
                -- TODO: add pkl-ls after mason_lspconfig supports it (mason has pkl-lsp but no lspconfig mapping).
            },
            -- Disable auto enable. This will be done by the lspconfig plugin.
            automatic_enable = false,
        })

        -- Setup all LSP servers using modular configuration
        require("config.lsp").setup()

        mason_tool_installer.setup({
            ensure_installed = {
                -- Security & Secret Scanning
                "trivy",      -- Vulnerability/misconfig/secrets scanner: containers, FS, IaC (Terraform/K8s/Dockerfile/Helm), SBOM
                "trufflehog", -- Secret scanner with online verification; Git/GitHub/FS; pre-commit/CI

                -- Linting Tools (used by none-ls)
                "actionlint",        -- Linter for GitHub Actions; files: .github/workflows/*.yml; CI guard
                "ansible-lint",      -- Ansible YAML linter/best practices; files: ansible/**/*.yml (playbooks, roles)
                "biome",             -- All-in-one JS/TS/JSON/HTML/CSS linter+formatter; files: *.js, *.ts, *.json, *.html, *.css; config: biome.json
                "eslint_d",          -- ESLint daemon (faster than eslint); for none-ls JS/TS linting
                "hadolint",          -- Dockerfile linter (incl. inline bash via ShellCheck); files: Dockerfile*
                "markdownlint-cli2", -- Markdown/MDX lint (extended version); files: *.md, *.mdx (rules via .markdownlint.json)
                "markuplint",        -- HTML linter (semantics/accessibility/attribute checks); files: *.html
                "oxlint",            -- Fast Rust-based JS/TS linter; files: *.js, *.ts, *.jsx, *.tsx; config: oxlint.json
                "selene",            -- Lua linter (for none-ls); files: *.lua; requires selene.toml
                "shellcheck",        -- Shell linter; files: *.sh, bash/zsh; also inside Dockerfiles
                "sqlfluff",          -- SQL linter/formatter (dialects, incl. Jinja); files: *.sql
                "stylelint",         -- CSS/Sass/Less linter; files: *.css/*.scss; Tailwind rules possible too
                "tflint",            -- Terraform linter (HCL); files: *.tf; Terraform & OpenTofu
                "yamllint",          -- YAML linter (syntax only, schema-free); files: *.yml/*.yaml
                -- kube-linter and trufflehog already listed above in Security section

                -- Go-specific Tools
                "golangci-lint",     -- Go meta-linter (bundles many rules/tools); files: *.go
                "gofumpt",           -- Go formatter (stricter gofmt); files: *.go
                "goimports-reviser", -- Go import formatter (for none-ls); files: *.go
                "golines",           -- Go line wrapping/reflow; files: *.go (complements gofumpt)

                -- Go Tools for gopher.nvim plugin
                "gomodifytags", -- Add/remove struct tags; for gopher.nvim
                "impl",         -- Generate interface implementations; for gopher.nvim
                "gotests",      -- Generate Go tests; for gopher.nvim
                "iferr",        -- Generate if err != nil blocks; for gopher.nvim

                -- Formatters (used by none-ls and standalone)
                -- Biome is also a formatter
                "prettierd", -- Prettier as a daemon (fast); files: HTML/CSS/JS/TS/JSON/MD/etc
                "shfmt",     -- Shell formatter; files: *.sh (bash/zsh/sh)
                "stylua",    -- Lua formatter; files: *.lua
                "taplo",     -- TOML lint/format; files: *.toml (e.g. taplo.toml, Cargo.toml)
                "yamlfmt",   -- YAML formatter; files: *.yml/*.yaml
            },
        })
    end,
}

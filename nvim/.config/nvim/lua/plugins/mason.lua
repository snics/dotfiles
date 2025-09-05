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
        "ansiblels",                         -- Ansible-YAML (Playbooks/Roles/Inventory); *.yml, *.yaml
        "bashls",                            -- Shellscript (bash/sh; zsh ohne eigenen LS); *.sh
        "cssls",                             -- CSS/SCSS/LESS; *.css, *.scss, *.less
        "css_variables",                     -- CSS Variables/Custom Properties; CSS :root, var()
        "denols",                            -- Deno (TS/JS-Runtime & Tooling); *.ts, *.tsx, *.js, *.jsx (deno-Projekte)
        "docker_compose_language_service",   -- Docker-Compose YAML (Compose v2); docker-compose.yml, compose.yml/.yaml
        "dockerls",                          -- Dockerfile; Dockerfile, Containerfile, *.Dockerfile
        "emmet_ls",                          -- Emmet für HTML/CSS; Schnelle Snippets
        "gopls",                             -- Go; *.go, go.mod, go.work
        "graphql",                           -- GraphQL Schemas/Operations; *.graphql, *.gql (+ gql-Tagged Templates)
        "helm_ls",                           -- Helm Charts (Kubernetes); *.yaml Templates
        "html",                              -- HTML; *.html
        "rust_analyzer",                     -- Rust; *.rs, Cargo.toml, Cargo.lock
        "jsonls",                            -- JSON/JSONC (z. B. tsconfig); *.json, *.jsonc
        "lua_ls",                            -- Lua (inkl. Neovim Lua); *.lua
        "marksman",                          -- Markdown; *.md
        "mdx_analyzer",                      -- MDX (Markdown + JSX/TSX); *.mdx
        "sqlls",                             -- SQL Language Server; *.sql
        "tailwindcss",                       -- Tailwind IntelliSense (Klassen in HTML/JS/TS/JSX/TSX)
        "taplo",                             -- TOML (Taplo); *.toml (z. B. Cargo.toml)
        "terraformls",                       -- Terraform (HCL); *.tf, *.tfvars
        "ts_ls",                             -- TypeScript/JavaScript/React; *.ts, *.tsx, *.js, *.jsx
        "yamlls",                            -- YAML (inkl. K8s/KYAML via Schemas); *.yml, *.yaml
        
        -- Additional LSPs for enhanced support
        "eslint",                            -- ESLint Language Server für JS/TS Linting (mit none-ls)
        "biome",                             -- Biome (moderne Alternative zu ESLint/Prettier, mit none-ls)

        -- TODO: add pkl-ls and tofu-ls after mason_lspconfig supports it.
      },
      -- Disable auto enable. This will be done by the lspconfig plugin.
      automatic_enable = false,
    })

    -- Setup all LSP servers using modular configuration
    require("config.lsp").setup()

    mason_tool_installer.setup({
      ensure_installed = {
        -- Security & Secret Scanning
        "gitleaks",          -- Secret-Scanner (API-Keys, Tokens) in Repo/FS; alle Sprachen; pre-commit/CI
        "semgrep",           -- SAST Multi-Lang (JS/TS/Go/Python/…); Framework-Regeln (React, Node); CI/pre-commit
        "trivy",             -- Vulnerability/Misconfig/Secrets Scanner: Container, FS, IaC (Terraform/K8s/Dockerfile/Helm), SBOM
        "trufflehog",        -- Secret-Scanner mit Online-Verifikation; Git/GitHub/FS; pre-commit/CI

        -- Linting Tools
        "actionlint",        -- Linter für GitHub Actions; Dateien: .github/workflows/*.yml; CI-Guard
        "ansible-lint",      -- Ansible YAML Linter/Best Practices; Dateien: ansible/**/*.yml (Playbooks, Rollen)
        "hadolint",          -- Dockerfile-Linter (auch Inline-Bash via ShellCheck); Dateien: Dockerfile*
        "kube-linter",       -- Kubernetes/Helm Manifest-Linter (Best Practices); Dateien: k8s/*.yaml, charts/**; IaC
        "markdownlint-cli2", -- Markdown/MDX Lint; Dateien: *.md, *.mdx (Regelbar per .markdownlint.json)
        "markuplint",        -- HTML Linter (Semantik/Barrierefreiheit/Attr-Checks); Dateien: *.html
        "shellcheck",        -- Shell Linter; Dateien: *.sh, bash/zsh; auch in Dockerfiles
        "sqlfluff",          -- SQL Linter/Formatter (Dialekte, auch Jinja); Dateien: *.sql
        "stylelint",         -- CSS/Sass/Less Linter; Dateien: *.css/*.scss; auch Tailwind-Regeln möglich
        "tflint",            -- Terraform Linter (HCL); Dateien: *.tf; Terraform & OpenTofu
        "yamllint",          -- YAML Linter (Syntax/Schema-frei); Dateien: *.yml/*.yaml

        -- Go-specific Tools
        "golangci-lint",     -- Go Meta-Linter (viele Regeln/Tools gebündelt); Dateien: *.go; Projekte: Go
        "gofumpt",           -- Go Formatter (strenger gofmt); Dateien: *.go
        "golines",           -- Go Zeilenumbruch/Reflow; Dateien: *.go (ergänzt gofumpt)

        -- Formatters
        "biome",             -- JS/TS/JSON/HTML/CSS: Lint+Format+LSP in einem; Frameworks: React, Deno, Bun, Node
        "prettierd",         -- Prettier als Daemon (schnell); Dateien: HTML/CSS/JS/TS/JSON/MD/etc
        "shfmt",             -- Shell Formatter; Dateien: *.sh (bash/zsh/sh)
        "stylua",            -- Lua Formatter; Dateien: *.lua
        "taplo",             -- TOML Lint/Format; Dateien: *.toml (z. B. taplo.toml, Cargo.toml)
        "yamlfmt",           -- YAML Formatter; Dateien: *.yml/*.yaml
        "yamlfix",           -- YAML Formatter (struktur-bewusst, Sortierung/Normalisierung)

        -- Legacy/Utilities (keeping existing)
        "jq",                -- JSON processor
        "yq",                -- YAML processor
      },
    })
  end,
}

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
        "pkl",                               -- Pkl (Apple); *.pkl
        "sqlls",                             -- SQL Language Server; *.sql
        "tailwindcss",                       -- Tailwind IntelliSense (Klassen in HTML/JS/TS/JSX/TSX)
        "taplo",                             -- TOML (Taplo); *.toml (z. B. Cargo.toml)
        "terraformls",                       -- Terraform (HCL); *.tf, *.tfvars
        "tofu_ls",                           -- OpenTofu (HCL); *.tf, *.tfvars (OpenTofu)
        "ts_ls",                             -- TypeScript/JavaScript/React; *.ts, *.tsx, *.js, *.jsx
        "yamlls",                            -- YAML (inkl. K8s/KYAML via Schemas); *.yml, *.yaml
        
        -- Additional LSPs for enhanced support
        "eslint",                            -- ESLint Language Server für JS/TS Linting (mit none-ls)
        "biome",                             -- Biome (moderne Alternative zu ESLint/Prettier, mit none-ls)
      },
      -- Automatically install ensure_installed servers
      automatic_installation = true,
    })

    -- Setup all LSP servers using modular configuration
    require("config.lsp").setup()

    mason_tool_installer.setup({
      ensure_installed = {
        -- Linting tools
        "ansible-lint", -- Ansible Lint
        "eslint_d", -- ESLint Daemon
        "hadolint", -- Dockerfile linter, validate inline bash
        "htmlhint", -- A Static Code Analysis Tool for HTML
        "jsonlint", -- JSON Lint
        "markdownlint-cli2", -- Markdown linting and style checking
        "shellcheck", -- sh, bash, ksk and zsh script analysis and linting
        "sqlfluff", -- A SQL linter and auto-formatter for Humans
        "stylelint", -- A mighty, modern CSS linter
        "tflint", -- TFLint is a Terraform linter focused on possible errors, best practices, etc.
        "trivy", -- A Simple and Comprehensive Vulnerability Scanner for Containers and other Artifacts
        "vint", -- Fast and Highly Extensible Vim script Language Lint
        "yamllint", -- A linter for YAML files

        -- Formatting tools
        "bibtex-tidy", -- A tool to tidy up BibTeX files
        "jq", -- A lightweight and flexible command-line JSON processor
        "latexindent", -- A Perl script to indent and reformat .tex and .bib files
        "prettierd", -- Prettier Daemon for JavaScript, TypeScript, CSS, HTML, JSON, YAML, Markdown, etc.
        "rustywind", -- A Rustywind is a Rust implementation of TailwindCSS JIT
        "selene", -- Lua linter and formatter
        "shellharden", -- A tool to help improve shell scripts
        "shfmt", -- A shell script formatter
        "sqlfmt", -- SQL Formatter
        "stylua", -- A Lua formatter for Lua source code
        "xmlformatter", -- XML formatter
        "yq", -- yq is a lightweight and portable command-line YAML processor
      },
    })
  end,
}

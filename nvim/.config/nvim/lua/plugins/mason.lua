return {
  "williamboman/mason.nvim",
  priority = 100, -- High priority to ensure Mason loads first
  build = ":MasonUpdate",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
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
        -- LSP servers
        "ansiblels", -- Ansible Language Server
        "bashls", -- Bash Language Server
        "biome", -- Biome Language Server
        "cssls", -- CSS Language Server
        "css_variables", -- CSS Variables Language Server
        "cssmodules_ls", -- CSS Modules Language Server
        "denols", -- Deno Language Server
        "docker_compose_language_service", -- Docker Compose Language Service
        "dockerls", -- Docker Language Server
        "eslint", -- ESLint Language Server
        "graphql", -- GraphQL Language Server
        "gopls", -- Go Language Server
        "html", -- HTML Language Server
        "htmx", -- HTMX Language Server
        "helm_ls", -- Helm Language Server
        "jsonls", -- JSON Language Server
        "lua_ls",  -- Lua Language Server
        "ltex",  -- LaTeX Language Server
        "mdx_analyzer", -- MDX Analyzer Language Server
        "marksman", -- Markdown Language Server
        "nginx_language_server", -- Nginx Language Server
        "powershell_es", -- PowerShell Language Server
        "sqlls", -- SQL Language Server
        "taplo", -- Toolkit for TOML
        "tailwindcss", -- Tailwind CSS Language Server
        "terraformls", -- Terraform Language Server
        "ts_ls",  -- TypeScript Language Server
        "yamlls", -- YAML Language Server
        "vimls", -- Vim Language Server
        "lemminx", -- XML Language Server
      },
      -- Automatically install ensure_installed servers
      automatic_installation = true,
    })

    -- Get default capabilities
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Setup individual LSP servers with lspconfig
    local lspconfig = require("lspconfig")

    -- Default setup for most servers
    local servers = {
      "ansiblels", "bashls", "biome", "cssls", "css_variables", "cssmodules_ls",
      "denols", "docker_compose_language_service", "dockerls", "eslint",
      "html", "htmx", "helm_ls", "jsonls", "ltex", "mdx_analyzer", "marksman",
      "nginx_language_server", "powershell_es", "sqlls", "taplo", "tailwindcss",
      "terraformls", "ts_ls", "vimls", "lemminx"
    }

    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end

    -- Special configuration for Lua
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
        },
      },
    })

    -- Special configuration for Go
    lspconfig.gopls.setup({
      capabilities = capabilities,
      cmd = {"gopls"},
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = { unusedparams = true },
        },
      },
    })

    -- Special configuration for GraphQL
    lspconfig.graphql.setup({
      capabilities = capabilities,
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    -- Special configuration for YAML with Kubernetes support
    lspconfig.yamlls.setup({
      capabilities = capabilities,
      settings = {
        yaml = {
          schemaStore = {
            -- Enable built-in schemaStore support
            enable = true,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = "",
          },
          schemas = {
            kubernetes = "*.{yaml,yml}",
            ["https://json.schemastore.org/github-workflow"] = ".github/workflows/*",
            ["https://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
            ["https://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
            ["https://json.schemastore.org/helm-chart"] = "Chart.{yml,yaml}",
            ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
            ["https://json.schemastore.org/ansible-playbook"] = "playbook*.{yml,yaml}",
            ["https://json.schemastore.org/ansible-inventory"] = "inventory*.{yml,yaml}",
          },
          format = { enable = true },
          validate = true,
          completion = true,
          hover = true,
        }
      }
    })

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

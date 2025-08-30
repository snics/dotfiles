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
            -- Disable built-in schemaStore support since we use SchemaStore.nvim
            enable = false,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = "",
          },
          schemas = (function()
            -- 1. SchemaStore.nvim for all standard schemas (highest priority)
            local schemas = require('schemastore').yaml.schemas()
            
            -- 2. Kubernetes Schema - Smart Loading (overrides SchemaStore Kubernetes if needed)
            local k8s_ok, kubernetes = pcall(require, 'kubernetes')
            if k8s_ok then
              local schema_path = kubernetes.yamlls_schema()
              if schema_path then
                -- Use kubernetes.nvim for all YAML files when available
                schemas[schema_path] = "*.{yaml,yml}"
                vim.notify("[yamlls] Using kubernetes.nvim schema for live cluster support", vim.log.levels.INFO)
              end
            else
              -- Fallback to static Kubernetes schema for specific patterns
              schemas["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.0-standalone-strict/all.json"] = {
                -- Core Workload Resources
                "*pod*.{yaml,yml}", "*po*.{yaml,yml}",
                "*service*.{yaml,yml}", "*svc*.{yaml,yml}",
                "*deployment*.{yaml,yml}", "*deploy*.{yaml,yml}",
                "*replicaset*.{yaml,yml}", "*rs*.{yaml,yml}",
                "*daemonset*.{yaml,yml}", "*ds*.{yaml,yml}",
                "*statefulset*.{yaml,yml}", "*sts*.{yaml,yml}",
                "*job*.{yaml,yml}",
                "*cronjob*.{yaml,yml}", "*cj*.{yaml,yml}",
                
                -- Config & Storage
                "*configmap*.{yaml,yml}", "*cm*.{yaml,yml}",
                "*secret*.{yaml,yml}",
                "*persistentvolume*.{yaml,yml}", "*pv*.{yaml,yml}",
                "*persistentvolumeclaim*.{yaml,yml}", "*pvc*.{yaml,yml}",
                "*storageclass*.{yaml,yml}", "*sc*.{yaml,yml}",
                
                -- Networking
                "*ingress*.{yaml,yml}", "*ing*.{yaml,yml}",
                "*networkpolicy*.{yaml,yml}", "*netpol*.{yaml,yml}",
                "*endpoints*.{yaml,yml}", "*ep*.{yaml,yml}",
                "*endpointslice*.{yaml,yml}",
                
                -- Security & Access
                "*serviceaccount*.{yaml,yml}", "*sa*.{yaml,yml}",
                "*role*.{yaml,yml}",
                "*rolebinding*.{yaml,yml}",
                "*clusterrole*.{yaml,yml}",
                "*clusterrolebinding*.{yaml,yml}",
                "*podsecuritypolicy*.{yaml,yml}", "*psp*.{yaml,yml}",
                
                -- Advanced Workloads
                "*horizontalpodautoscaler*.{yaml,yml}", "*hpa*.{yaml,yml}",
                "*verticalpodautoscaler*.{yaml,yml}", "*vpa*.{yaml,yml}",
                "*poddisruptionbudget*.{yaml,yml}", "*pdb*.{yaml,yml}",
                
                -- API & Custom Resources
                "*customresourcedefinition*.{yaml,yml}", "*crd*.{yaml,yml}",
                "*apiservice*.{yaml,yml}",
                "*mutatingwebhookconfiguration*.{yaml,yml}",
                "*validatingwebhookconfiguration*.{yaml,yml}",
                
                -- Nodes & Cluster
                "*node*.{yaml,yml}", "*no*.{yaml,yml}",
                "*namespace*.{yaml,yml}", "*ns*.{yaml,yml}",
                "*resourcequota*.{yaml,yml}", "*quota*.{yaml,yml}",
                "*limitrange*.{yaml,yml}", "*limits*.{yaml,yml}",
                
                -- Events & Monitoring
                "*event*.{yaml,yml}", "*ev*.{yaml,yml}",
                "*componentstatus*.{yaml,yml}", "*cs*.{yaml,yml}",
                
                -- Special patterns
                "*.k8s.{yaml,yml}",
                "*kubernetes*.{yaml,yml}",
                "k8s/**/*.{yaml,yml}",
                "kubernetes/**/*.{yaml,yml}",
                "manifests/**/*.{yaml,yml}",
              }
            end
            
            return schemas
          end)(),
          format = { 
            enable = true,
            singleQuote = false,
            bracketSpacing = true,
          },
          validate = true,
          completion = true,
          hover = true,
          -- Kubernetes support now handled by kubernetes.nvim plugin
        }
      },
                -- Improved file type detection
      filetypes = { 
        "yaml", 
        "yml", 
        "yaml.docker-compose",
        "yaml.gitlab",
        "yaml.ansible"
      },
      -- Root directory detection
      root_dir = require("lspconfig/util").root_pattern(
        ".git",
        "docker-compose.yml",
        "docker-compose.yaml",
        "Chart.yaml",
        "values.yaml",
        "ansible.cfg",
        ".gitlab-ci.yml"
      ),
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

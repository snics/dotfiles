return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "",
          package_pending = "➜",
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
        "tsserver",  -- TypeScript Language Server
        "yamlls", -- YAML Language Server
        "vimls", -- Vim Language Server
        "lemminx", -- XML Language Server
      },
    })
  end,
}
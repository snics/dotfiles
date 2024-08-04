local options = require "nvchad.configs.mason"

options.ensure_installed = {
  -- LSP servers
  "ansible-language-server", -- Ansible Language Server
  "bash-language-server", -- Bash Language Server
  "biome", -- Biome Language Server
  "css-lsp", -- CSS Language Server
  "css-variables-language-server", -- CSS Variables Language Server
  "cssmodules-language-server", -- CSS Modules Language Server
  "deno", -- Deno Language Server
  "docker-compose-language-service", -- Docker Compose Language Service
  "dockerfile-language-server", -- Docker Language Server
  "eslint-lsp", -- ESLint Language Server
  "html-lsp", -- HTML Language Server
  "htmx-lsp", -- HTMX Language Server
  "json-lsp", -- JSON Language Server
  "lua-language-server", -- Lua Language Server
  "mdx-analyzer", -- MDX Analyzer Language Server
  "kotlin-language-server", -- Kotlin Language Server
  "tailwindcss-language-server", -- Tailwind CSS Language Server
  "terraform-ls", -- Terraform Language Server
  "typescript-language-server", -- TypeScript Language Server
  "yaml-language-server", -- YAML Language Server

  -- DAP servers

  -- Formatters
  "prettier", -- Prettier: A code formatter for various languages including JavaScript, TypeScript, CSS, HTML, JSON, and more
  "stylua", -- StyLua: An opinionated code formatter for Lua
  "black", -- Black: The uncompromising Python code formatter
  "shfmt", -- shfmt: Formatter for shell scripts
  "clang-format", -- ClangFormat: A formatter for C, C++, and other languages
  "stylelint", -- Stylelint: A formatter and linter for CSS, SCSS, and other CSS-like syntaxes
  "jq", -- jq: A lightweight and flexible command-line JSON processor

  -- Linters
  --"eslint",         -- ESLint: A linter for JavaScript and TypeScript (This already comes with the LSP server)
  "flake8", -- Flake8: A linter for Python
  "shellcheck", -- ShellCheck: A linter for shell scripts
  "tflint", -- TFLint: A linter for Terraform files
  "markdownlint", -- MarkdownLint: A linter for Markdown files
  "luacheck", -- Luacheck: A linter for Lua
  "yamllint", -- Yamllint: A linter for YAML files
  "hadolint", -- Hadolint: A linter for Dockerfiles
  "htmlhint", -- HTMLHint: A linter for HTML files
  "jsonlint", -- JSONLint: A linter for JSON files
}

return options

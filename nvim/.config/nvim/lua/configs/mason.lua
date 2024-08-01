local options = require("nvchad.configs.mason")

options.ensure_installed = {
    -- LSP servers
    "ansible-language-server",
    "bash-language-server",
    "biome",
    "css-lsp",
    "css-variables-language-server",
    "cssmodules-language-server",
    "deno",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "eslint-lsp",
    "html-lsp",
    "htmx-lsp",
    "json-lsp",
    "lua-language-server",
    "mdx-analyzer",
    "kotlin-language-server",
    "tailwindcss-language-server",
    "terraform-ls",
    "typescript-language-server",
    "yaml-language-server",
    -- Formatters
    -- Linters
}

return options

local options = {
  formatters_by_ft = {
    lua = { "stylua" }, -- Lua formatter
    css = { "prettier", "stylelint" }, -- CSS formatter
    scss = { "prettier", "stylelint" }, -- SCSS formatter
    html = { "prettier" }, -- HTML formatter
    json = { "prettier", "jq" }, -- JSON formatter
    yaml = { "prettier" }, -- YAML formatter
    markdown = { "prettier" }, -- Markdown formatter
    sh = { "shfmt" }, -- Shell script formatter
    bash = { "shfmt" }, -- Bash script formatter
    c = { "clang-format" }, -- C formatter
    cpp = { "clang-format" }, -- C++ formatter
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)

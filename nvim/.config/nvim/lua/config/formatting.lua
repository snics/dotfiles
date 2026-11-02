-- Prefer none-ls when a formatter exists; otherwise use the language server.
local M = {}

function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local methods = require("null-ls.methods")
  local has_source = #require("null-ls.sources").get_available(vim.bo[bufnr].filetype, methods.internal.FORMATTING) > 0
  vim.lsp.buf.format({
    bufnr = bufnr,
    timeout_ms = 2000,
    filter = function(client)
      return has_source and client.name == "null-ls" or not has_source and client.name ~= "null-ls"
    end,
  })
end

return M

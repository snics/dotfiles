-- Run after loading init.lua: nvim --headless '+luafile nvim/tests/regression.lua'
local function run()
  local errors = {}
  local notify = vim.notify
  vim.notify = function(message, level, opts)
    if level == vim.log.levels.ERROR then
      table.insert(errors, tostring(message))
    end
    notify(message, level, opts)
  end
  local plugins = vim.tbl_keys(require("lazy.core.config").plugins)
  require("lazy").load({ plugins = plugins })
  local config_dir = vim.fn.stdpath("config")
  for _, path in ipairs(vim.fn.glob(config_dir .. "/**/*.lua", false, true)) do
    assert(loadfile(path))
  end

  local cc = require("codecompanion.config")
  assert(cc.interactions.chat.adapter == "codex")
  assert(cc.interactions.inline.adapter == "anthropic")
  assert(type(cc.adapters.http.anthropic) == "function")
  local codex = require("codecompanion.adapters").resolve("codex")
  assert(codex.type == "acp" and codex.defaults.auth_method == "chat-gpt")

  assert(type(require("config.lsp.servers.yamlls").config.root_markers) == "table")

  local function utils(files)
    return {
      root_has_file = function(patterns)
        for _, pattern in ipairs(patterns) do
          if files[pattern] then
            return true
          end
        end
        return false
      end,
    }
  end
  local prettier = require("config.none-ls.formatters.prettierd")
  assert(prettier.condition(utils({ [".oxlintrc.json"] = true })))
  assert(not prettier.condition(utils({ ["biome.json"] = true })))
  assert(not prettier.condition(utils({ ["deno.json"] = true })))
  local deno_fmt = require("config.none-ls.formatters.deno_fmt")
  assert(vim.tbl_contains(deno_fmt._opts.args({ ft = "typescriptreact" }), "--ext=tsx"))
  assert(not deno_fmt.condition(utils({ ["deno.json"] = true, ["biome.json"] = true })))

  local biome = require("config.none-ls.diagnostics.biome")
  local diagnostics = biome._opts.on_output({
    output = {
      diagnostics = {
        { severity = "warning", description = "Formatting", location = { span = vim.NIL, sourceCode = "abc" } },
        {
          severity = "error",
          description = "Unexpected token",
          category = "parse",
          location = { span = { 5, 6 }, sourceCode = "abc\nxyz" },
        },
      },
    },
  })
  assert(#diagnostics == 2 and diagnostics[2].row == 2 and diagnostics[2].col == 2)

  local deno = require("config.none-ls.diagnostics.deno_lint")
  diagnostics = deno._opts.on_output({
    output = {
      diagnostics = {
        {
          range = { start = { line = 1, col = 4 }, ["end"] = { line = 1, col = 10 } },
          message = "Unused variable",
          code = "no-unused-vars",
        },
      },
    },
  })
  assert(#diagnostics == 1 and diagnostics[1].row == 1 and diagnostics[1].col == 5)

  local tflint = require("config.none-ls.diagnostics.tflint")
  diagnostics = tflint._opts.on_output({
    output = {
      issues = {
        {
          message = "Unused declaration",
          rule = { name = "unused", severity = "WARNING" },
          range = { start = { line = 2, column = 1 } },
        },
      },
    },
  })
  assert(#diagnostics == 1 and diagnostics[1].row == 2)

  local kubeconform = require("config.none-ls.diagnostics.kubeconform")
  diagnostics = kubeconform._opts.on_output({
    output = {
      resources = {
        { status = "statusInvalid", msg = "Missing required property", filename = "deployment.yaml" },
      },
    },
  })
  assert(#diagnostics == 1 and diagnostics[1].message == "Missing required property")

  local original_format = vim.lsp.buf.format
  local sources = require("null-ls.sources")
  local original_available = sources.get_available
  local formatting = require("config.formatting")
  for _, available in ipairs({ true, false }) do
    sources.get_available = function()
      return available and { {} } or {}
    end
    vim.lsp.buf.format = function(opts)
      assert(opts.filter({ name = "null-ls" }) == available)
      assert(opts.filter({ name = "gopls" }) == not available)
    end
    formatting.format(0)
  end
  sources.get_available = original_available
  vim.lsp.buf.format = original_format
  assert(#errors == 0, table.concat(errors, "\n"))
  vim.notify = notify
  print("PASS: plugin loading, Lua syntax, ACP config, formatter selection, diagnostic parsers")
end
local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end

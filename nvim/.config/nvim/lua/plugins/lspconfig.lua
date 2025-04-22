return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- set keybinds
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", { desc = "Show LSP references", buffer = ev.buf, silent = true }) -- show definition, references§
        keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration",  buffer = ev.buf, silent = true }) -- go to declaration§
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Show LSP definitions",  buffer = ev.buf, silent = true }) -- show lsp definitions§
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "Show LSP implementations",  buffer = ev.buf, silent = true }) -- show lsp implementations§
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Show LSP type definitions",  buffer = ev.buf, silent = true }) -- show lsp type definitions§
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "See available code actions",  buffer = ev.buf, silent = true }) -- see available code actions, in visual mode will apply to selection§
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Smart rename",  buffer = ev.buf, silent = true }) -- smart rename
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show buffer diagnostics",  buffer = ev.buf, silent = true }) -- show  diagnostics for file§
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics",  buffer = ev.buf, silent = true }) -- show diagnostics for line§
        keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic",  buffer = ev.buf, silent = true }) -- jump to previous diagnostic in buffer§
        keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic",  buffer = ev.buf, silent = true }) -- jump to next diagnostic in buffer§
        keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show documentation for what is under cursor",  buffer = ev.buf, silent = true }) -- show documentation for what is under cursor§
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP",  buffer = ev.buf, silent = true }) -- mapping to restart lsp if necessary
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["graphql"] = function()
        -- configure graphql language server
        lspconfig["graphql"].setup({
          capabilities = capabilities,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,

      -- Spezielle Konfiguration für YAML LSP
      ["yamlls"] = function()
          lspconfig.yamlls.setup({
            capabilities = capabilities,
            settings = {
              yaml = {
                schemas = {
                  kubernetes = "globPattern",
                  -- Nutze ein externes Schema für Kubernetes
                  ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/all.json"] = "globPattern",
                  -- Falls du Kustomize-Dateien hast:
                  ["http://json.schemastore.org/kustomization"] = "*.kustomization.yaml",
                },
                format = { enable = true },
                validate = true,
                completion = true,
                hover = true,
              }
            }
          })
      end,
    })
  end,
}

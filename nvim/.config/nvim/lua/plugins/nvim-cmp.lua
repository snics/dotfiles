return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
    "Exafunction/windsurf.nvim" -- Windsurf/Codeium completion source
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip") -- snippet engine
    local lspkind = require("lspkind") -- vs-code like pictograms

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load() -- lazy load to prevent startup lag

    -- Define AI-themed colors for Codeium
    vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#DA70D6", bg = "NONE" }) -- Lila/Orchid für AI
    vim.api.nvim_set_hl(0, "CmpItemMenuCodeium", { fg = "#DA70D6", bg = "NONE" }) -- Lila/Orchid für AI Menu

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect", -- completion options
      },
      
      -- Window styling with borders for LSP hints
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Pmenu,FloatBorder:VertSplit,CursorLine:PmenuSel,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Pmenu,FloatBorder:VertSplit,CursorLine:PmenuSel,Search:None",
        }),
      },
      
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body) -- expand the snippet
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- scroll documentation up
        ["<C-f>"] = cmp.mapping.scroll_docs(4), -- scroll documentation down
        ["<C-S-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm completion
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "codeium", group_index = 2, entry_filter = function(entry, ctx) 
          -- Only show in CMP when virtual text is disabled OR not available
          return not vim.g.windsurf_virtual_text_enabled
        end }, -- Windsurf/Codeium Source
        { name = "nvim_lsp"}, -- language server protocol
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }),

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
          symbol_map = { 
            Codeium = "󰘦", -- Brain icon für AI/Windsurf/Codeium
          },
          before = function(entry, vim_item)
            -- Set AI-like color for Codeium entries
            if entry.source.name == "codeium" then
              vim_item.kind_hl_group = "CmpItemKindCodeium"
              vim_item.menu_hl_group = "CmpItemMenuCodeium"
            end
            return vim_item
          end,
        }),
      },
    })
  end,
}

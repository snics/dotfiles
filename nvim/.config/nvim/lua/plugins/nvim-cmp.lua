return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    "hrsh7th/cmp-nvim-lsp", -- LSP capabilities for cmp
    "hrsh7th/cmp-cmdline", -- cmdline completion (':', '/', '?')
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
    "Exafunction/windsurf.nvim", -- Windsurf/Codeium completion source
    -- Optional but highly recommended:
    -- "windwp/nvim-autopairs",             -- autopairs integration with cmp
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip") -- snippet engine
    local lspkind = require("lspkind") -- vs-code like pictograms

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
      region_check_events = "InsertEnter",
      delete_check_events = "TextChanged",
    })

    -- Define AI-themed colors for Codeium
    vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { link = "Statement" })
    vim.api.nvim_set_hl(0, "CmpItemMenuCodeium", { link = "Statement" })
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment" })

    -- Smart helper function
    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      if col == 0 then return false end
      local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
      return text:sub(col, col):match("%s") == nil
    end

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
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),

        -- Super-Tab: navigate list or jump in snippet, otherwise trigger completion
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "codeium", group_index = 2, entry_filter = function(entry, ctx) 
          -- Only show in CMP when virtual text is disabled OR not available
          return not vim.g.windsurf_virtual_text_enabled
        end }, -- Windsurf/Codeium Source
        { name = "nvim_lsp"}, -- language server protocol
        { name = "luasnip" }, -- snippets
        {
          name = "buffer",
          keyword_length = 3,
          get_bufnrs = function()
            -- nur geladene, sichtbare, nicht-terminal Buffers
            local bufs = {}
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                table.insert(bufs, buf)
              end
            end
            return bufs
          end,
        },
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

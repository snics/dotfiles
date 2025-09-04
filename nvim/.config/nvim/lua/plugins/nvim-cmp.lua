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

    -- Smart helper functions
    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      if col == 0 then return false end
      local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
      return text:sub(col, col):match("%s") == nil
    end

    local is_in_comment = function()
      local context = require("cmp.config.context")
      return context.in_treesitter_capture("comment") or context.in_syntax_group("Comment")
    end

    local get_loaded_buffers = function()
      local bufs = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
          table.insert(bufs, buf)
        end
      end
      return bufs
    end

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect", -- completion options
      },

      -- Disable in prompts and for very large files (but allow AI in comments!)
      enabled = function()
        if vim.bo.buftype == "prompt" then return false end
        local ok, stat = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stat and stat.size and stat.size > 1024 * 1024 then
          return false
        end
        return true
      end,
      
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
        { 
          name = "codeium", 
          group_index = 2, 
          entry_filter = function() return not vim.g.windsurf_virtual_text_enabled end -- AI everywhere!
        },
        { name = "nvim_lsp", entry_filter = function() return not is_in_comment() end },
        { name = "luasnip",  entry_filter = function() return not is_in_comment() end },
        { 
          name = "buffer", 
          keyword_length = 3,
          entry_filter = function() return not is_in_comment() end,
          get_bufnrs = get_loaded_buffers,
        },
        { name = "path", entry_filter = function() return not is_in_comment() end },
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

      -- Advanced sorting (LSP before snippets)
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          -- deprioritize snippets
          function(e1, e2)
            local t = require("cmp.types").lsp.CompletionItemKind
            if e1:get_kind() == t.Snippet and e2:get_kind() ~= t.Snippet then return false end
            if e2:get_kind() == t.Snippet and e1:get_kind() ~= t.Snippet then return true end
          end,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },

      performance = {
        debounce = 60,
        fetching_timeout = 200,
        max_view_entries = 120,
      },
    })

    -- Cmdline completion (':', '/', '?')
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })
  end,
}

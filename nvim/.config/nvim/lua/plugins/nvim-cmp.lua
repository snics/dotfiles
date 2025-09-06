-- Advanced completion engine with LSP, AI, snippets, and smart filtering
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  
  -- Dependencies grouped by functionality for clarity
  dependencies = {
    -- Core LSP integration - provides the main completion data
    "hrsh7th/cmp-nvim-lsp", -- LSP capabilities for cmp
    "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signature help
    
    -- Snippet system - enables code templates and expansions
    "saadparwaiz1/cmp_luasnip", -- LuaSnip integration
    "rafamadriz/friendly-snippets", -- Pre-built snippets for common languages
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp", -- Required for advanced snippet features
    },
    
    -- Essential completion sources
    "hrsh7th/cmp-buffer", -- Words from current buffer
    "hrsh7th/cmp-path", -- File system paths
    "hrsh7th/cmp-cmdline", -- Command line completion
    
    -- Context-aware sources - only activate in specific situations
    "petertriho/cmp-git", -- Git commit types and branches
    "f3fora/cmp-spell", -- Spell checking suggestions
    "hrsh7th/cmp-emoji", -- Emoji completion
    
    -- Visual enhancements
    "onsails/lspkind.nvim", -- Icons for completion items
    "roobert/tailwindcss-colorizer-cmp.nvim", -- Tailwind color previews in completion
    
    -- AI-powered completion
    "Exafunction/windsurf.nvim", -- Codeium/Windsurf AI suggestions
    
    -- TODO: Language-specific completions that will be added later
    -- "Saecki/crates.nvim", -- Rust: Cargo.toml dependencies
    -- "ray-x/go.nvim", -- Go development enhancements
  },
  
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    
    -- Setup Tailwind CMP colorizer
    require("tailwindcss-colorizer-cmp").setup({
      color_square_width = 2,
    })

    -- Theme integration: Link AI completion colors to Catppuccin theme
    vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { link = "Statement" })
    vim.api.nvim_set_hl(0, "CmpItemMenuCodeium", { link = "Statement" })

    -- LuaSnip configuration: Enhanced snippet behavior
    require("luasnip.loaders.from_vscode").lazy_load() -- Load VSCode-style snippets
    luasnip.config.set_config({
      history = true,                    -- Remember last snippet for re-expansion
      updateevents = "TextChanged,TextChangedI", -- Update snippets dynamically
      enable_autosnippets = true,        -- Enable automatic snippet triggers
      region_check_events = "InsertEnter", -- When to validate snippet regions
      delete_check_events = "TextChanged", -- When to clean up old snippets
    })

    -- Helper functions for smart completion behavior
    
    -- Check if cursor has text before it (prevents completion in empty space)
    local function has_words_before()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      if col == 0 then return false end
      local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
      return text:sub(col, col):match("%s") == nil
    end

    -- Detect if cursor is in comment context using treesitter
    local function is_in_comment()
      local context = require("cmp.config.context")
      return context.in_treesitter_capture("comment") or context.in_syntax_group("Comment")
    end

    -- Get only loaded buffers for buffer completion (performance optimization)
    local function get_loaded_buffers()
      local bufs = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
          table.insert(bufs, buf)
        end
      end
      return bufs
    end

    -- Smart filtering functions: Control when different sources should be active
    
    -- AI completion: Always available except when virtual text is showing
    local function codeium_filter()
      return not vim.g.windsurf_virtual_text_enabled
    end

    -- Standard sources: Block in comments to let AI handle documentation
    local function non_comment_filter()
      return not is_in_comment()
    end

    -- Git completion: Only in git-related files and contexts
    local function git_filter()
      local bufname = vim.api.nvim_buf_get_name(0)
      local filetype = vim.bo.filetype
      return filetype == "gitcommit" 
        or filetype == "gitrebase" 
        or filetype == "gitconfig"
        or bufname:match("COMMIT_EDITMSG")
        or bufname:match("MERGE_MSG")
        or bufname:match("/.git/")
    end

    -- Text-focused completion: Enable in documentation and comments
    local function text_and_comment_filter()
      local filetype = vim.bo.filetype
      return filetype == "gitcommit" 
        or filetype == "markdown" 
        or filetype == "text" 
        or filetype == "txt"
        or is_in_comment()
    end

    -- Main completion engine setup
    cmp.setup({
      -- Don't pre-select items - let user choose explicitly
      preselect = cmp.PreselectMode.None,
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },

      -- Performance: Disable in prompts and huge files
      enabled = function()
        if vim.bo.buftype == "prompt" then return false end
        local ok, stat = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stat and stat.size and stat.size > 1024 * 1024 then -- 1MB limit
          return false
        end
        return true
      end,
      
      -- Visual styling: Rounded borders for modern look
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
      
      -- Snippet expansion integration
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      
      -- Key mappings with intelligent Tab behavior
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-S-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),

        -- Smart Tab: Navigate completion → expand/jump snippets → trigger completion
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback() -- Normal Tab behavior
          end
        end, { "i", "s" }),

        -- Smart Shift-Tab: Reverse navigation
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
      
      -- Completion sources with smart filtering
      sources = cmp.config.sources({
        { name = "codeium", group_index = 2, entry_filter = codeium_filter }, -- AI suggestions
        { name = "nvim_lsp", entry_filter = non_comment_filter }, -- Language server
        { name = "nvim_lsp_signature_help" }, -- Function signatures (always active)
        { name = "git", entry_filter = git_filter }, -- Git-specific completion
        { name = "spell", entry_filter = text_and_comment_filter }, -- Spell check
        { name = "emoji", entry_filter = text_and_comment_filter }, -- Emojis
        { name = "luasnip", entry_filter = non_comment_filter }, -- Snippets
        { name = "buffer", keyword_length = 3, entry_filter = non_comment_filter, get_bufnrs = get_loaded_buffers },
        { name = "path", entry_filter = non_comment_filter }, -- File paths
      }),

      -- Visual formatting with icons and Tailwind color previews
      formatting = {
        fields = { "kind", "abbr", "menu" }, -- Show icon, text, source
        format = function(entry, vim_item)
          -- First apply Tailwind colorizer
          local tailwind_item = require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
          
          -- Then apply lspkind formatting
          local formatted = lspkind.cmp_format({
            mode = "symbol_text", -- Icon + text mode
            maxwidth = 50,
            ellipsis_char = "...",
            symbol_map = { 
              Codeium = "󰘦", -- AI brain icon
              git = "󰊢",     -- Git branch
              spell = "󰓆",   -- Spell check
              emoji = "󰞅",   -- Emoji
            },
            before = function(entry, vim_item)
              -- Apply special colors to AI completion
              if entry.source.name == "codeium" then
                vim_item.kind_hl_group = "CmpItemKindCodeium"
                vim_item.menu_hl_group = "CmpItemMenuCodeium"
              end
              return vim_item
            end,
          })(entry, tailwind_item)
          
          return formatted
        end,
      },

      -- Intelligent sorting: LSP first, then usage, snippets last
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          -- Custom: Prefer LSP over snippets (snippets can be noisy)
          function(e1, e2)
            local types = require("cmp.types").lsp.CompletionItemKind
            if e1:get_kind() == types.Snippet and e2:get_kind() ~= types.Snippet then
              return false
            end
            if e2:get_kind() == types.Snippet and e1:get_kind() ~= types.Snippet then
              return true
            end
          end,
          cmp.config.compare.recently_used, -- Prefer recently used items
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },

      -- Performance tuning for responsive completion
      performance = {
        debounce = 60,           -- Wait 60ms before triggering
        fetching_timeout = 200,  -- Timeout after 200ms
        max_view_entries = 120,  -- Limit visible items
      },
    })

    -- Git completion: Configure conventional commit types
    require("cmp_git").setup({
      enableRemoteUrlRewrites = false,
      remotes = { "upstream", "origin" },
      commit_types = {
        { "feat", "A new feature" },
        { "fix", "A bug fix" },
        { "docs", "Documentation changes" },
        { "style", "Code style changes (formatting, missing semi colons, etc)" },
        { "refactor", "Code refactoring" },
        { "perf", "Performance improvements" },
        { "test", "Adding missing tests" },
        { "chore", "Changes to build process or auxiliary tools" },
        { "ci", "CI/CD changes" },
        { "build", "Build system changes" },
        { "revert", "Revert previous commit" },
      },
    })

    -- Spell check: Configure for German and English
    vim.opt.spell = false -- Manual activation only
    vim.opt.spelllang = { "de", "en" }
    vim.opt.spellsuggest = "best,3" -- Show top 3 suggestions
    
    -- Auto-enable spell check in text-heavy file types
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "gitcommit", "markdown", "text", "txt" },
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "de_de", "en_us" } -- Specific locales
      end,
    })

    -- Command line completion for search and commands
    cmp.setup.cmdline({ "/", "?" }, { -- Search mode
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })
    
    cmp.setup.cmdline(":", { -- Command mode
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })
  end,
}
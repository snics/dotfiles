return {
  -- 🌳 TREESITTER CORE (Basis-Features)
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
      "apple/pkl-neovim",  -- PKL support by Apple
    },
    config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter.configs")

      -- configure treesitter
      treesitter.setup({
        auto_install = true, -- auto install language parsers
        highlight = {
          enable = true,
        },
        -- enable indentation
        indent = { enable = true },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = {
          enable = true,
        },
        -- ensure these language parsers are installed
        ensure_installed = {
            -- Core Neovim languages
            "lua",                    -- Lua language; *.lua (Neovim config)
            "luadoc",                 -- Lua documentation; --- comments in Lua
            "printf",                 -- Printf format strings; format specifiers
            "vim",                    -- Vim script; *.vim
            "vimdoc",                 -- Vim help documentation; *.txt help files

            -- Programming & Markup Languages
            "bash",                   -- Bash shell scripts; *.sh, *.bash
            "c",                      -- C language; *.c, *.h
            "cpp",                    -- C++ language; *.cpp, *.hpp, *.cc
            "c_sharp",                -- C# language; *.cs
            "css",                    -- CSS stylesheets; *.css
            "csv",                    -- CSV data files; *.csv
            "dart",                   -- Dart language (Flutter); *.dart
            "diff",                   -- Diff/patch files; *.diff, *.patch
            "dockerfile",             -- Docker files; Dockerfile, *.dockerfile
            "go",                     -- Go language; *.go
            "goctl",                  -- Go-zero goctl templates; goctl files
            "gomod",                  -- Go modules; go.mod
            "gosum",                  -- Go checksums; go.sum
            "gotmpl",                 -- Go templates; *.gotmpl, *.tmpl
            "gowork",                 -- Go workspaces; go.work
            "graphql",                -- GraphQL schemas/queries; *.graphql, *.gql
            "helm",                   -- Helm charts (Kubernetes); Chart.yaml, templates/*
            "html",                   -- HTML markup; *.html, *.htm
            "http",                   -- HTTP requests; *.http, REST client files
            "javascript",             -- JavaScript; *.js, *.mjs, *.cjs
            "jq",                     -- jq JSON processor; *.jq
            "jsdoc",                  -- JSDoc comments; /** */ in JavaScript
            "json",                   -- JSON data; *.json
            "json5",                  -- JSON5 (extended JSON); *.json5
            "markdown",               -- Markdown; *.md, *.markdown
            "markdown_inline",        -- Inline markdown; code blocks in markdown
            "nginx",                  -- Nginx config; nginx.conf, sites-available/*
            "php",                    -- PHP language; *.php
            "pkl",                    -- PKL config language (Apple); *.pkl
            "powershell",             -- PowerShell scripts; *.ps1, *.psm1
            "python",                 -- Python language; *.py, *.pyw
            "regex",                  -- Regular expressions; regex patterns
            "rust",                   -- Rust language; *.rs, Cargo.toml
            "scss",                   -- SCSS/Sass stylesheets; *.scss, *.sass
            "sql",                    -- SQL queries; *.sql
            "toml",                   -- TOML config files; *.toml, Cargo.toml
            "tsx",                    -- TypeScript React; *.tsx
            "typescript",             -- TypeScript; *.ts
            "yaml",                   -- YAML data/config; *.yml, *.yaml

            -- Utility parsers
            "comment",                -- Generic comments; comment syntax
            "tmux",                   -- Tmux config; .tmux.conf

            -- Git-related parsers
            "git_config",             -- Git config; .gitconfig
            "git_rebase",             -- Git rebase; rebase-merge files
            "gitattributes",          -- Git attributes; .gitattributes
            "gitcommit",              -- Git commit messages; COMMIT_EDITMSG
            "gitignore",              -- Git ignore; .gitignore
        },
        -- 🚀 INCREMENTAL SELECTION (part of textobjects)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-enter>",    -- Start incremental selection
            node_incremental = "<C-enter>",  -- Expand selection to next node
            scope_incremental = false,     -- Expand selection to next scope
            node_decremental = "<C-backspace>", -- Shrink selection to previous node
          },
        },
      })
    end,
  },

  -- 🎯 TEXTOBJECTS & SELECTION (zusammen!)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("nvim-treesitter.configs").setup({    
        -- 📝 TEXTOBJECTS
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj
            keymaps = {
              -- 🔥 THE ESSENTIAL CORE (you use these daily)
              ["af"] = "@function.outer",    -- around function
              ["if"] = "@function.inner",    -- inside function
              ["ac"] = "@class.outer",       -- around class  
              ["ic"] = "@class.inner",       -- inside class
              ["aa"] = "@parameter.outer",   -- around argument
              ["ia"] = "@parameter.inner",   -- inside argument
              
              -- 🎯 CONTROL FLOW (very useful)
              ["ai"] = "@conditional.outer", -- around if
              ["ii"] = "@conditional.inner", -- inside if
              ["al"] = "@loop.outer",        -- around loop
              ["il"] = "@loop.inner",        -- inside loop
              
              -- 📦 PRACTICAL ADDITIONS (daily use)
              ["ab"] = "@block.outer",       -- around block
              ["ib"] = "@block.inner",       -- inside block
              ["aC"] = "@call.outer",        -- around call
              ["iC"] = "@call.inner",        -- inside call
              
              -- 🗂️ YAML-SPECIFIC (Kubernetes/Helm workflow)
              ["as"] = "@assignment.outer",   -- around assignment (key: value)
              ["is"] = "@assignment.inner",   -- inside assignment (value only)
              ["ak"] = "@assignment.lhs",     -- assignment key (left side)
              ["av"] = "@assignment.rhs",     -- assignment value (right side)
              ["an"] = "@number.inner",       -- around number values
              ["at"] = "@comment.outer",      -- around comments
              ["it"] = "@comment.inner",      -- inside comments
              ["aS"] = "@statement.outer",    -- around YAML statements
            },
            
            -- Set selection modes for different textobjects
            selection_modes = {
              ['@parameter.outer'] = 'v',    -- charwise for parameters
              ['@function.outer'] = 'V',     -- linewise for functions
              ['@class.outer'] = 'V',        -- linewise for classes
              ['@conditional.outer'] = 'V',  -- linewise for conditionals
              ['@loop.outer'] = 'V',         -- linewise for loops
              ['@block.outer'] = 'V',        -- linewise for blocks
              ['@call.outer'] = 'v',         -- charwise for function calls
              
              -- YAML-specific selection modes
              ['@assignment.outer'] = 'V',   -- linewise for complete assignments
              ['@assignment.inner'] = 'v',   -- charwise for values only
              ['@assignment.lhs'] = 'v',     -- charwise for keys
              ['@assignment.rhs'] = 'v',     -- charwise for values  
              ['@number.inner'] = 'v',       -- charwise for numbers
              ['@comment.outer'] = 'V',      -- linewise for comments
              ['@comment.inner'] = 'v',      -- charwise for comment content
              ['@statement.outer'] = 'V',    -- linewise for YAML statements
            },
            
            include_surrounding_whitespace = false, -- false for precise selection
          },
          
          move = {
            enable = true,
            set_jumps = true, -- Add movements to jumplist (can use <C-o>/<C-i> to navigate back/forward)
            goto_next_start = {
              ["]m"] = "@function.outer",    -- Go to next method/function start
              ["]c"] = "@class.outer",       -- Go to next class start
              ["]i"] = "@conditional.outer", -- Go to next if/conditional start
              ["]l"] = "@loop.outer",        -- Go to next loop start
            },
            goto_next_end = {
              ["]M"] = "@function.outer",    -- Go to next method/function end
              ["]C"] = "@class.outer",       -- Go to next class end
              ["]I"] = "@conditional.outer", -- Go to next if/conditional end
              ["]L"] = "@loop.outer",        -- Go to next loop end
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",    -- Go to previous method/function start
              ["[c"] = "@class.outer",       -- Go to previous class start
              ["[i"] = "@conditional.outer", -- Go to previous if/conditional start
              ["[l"] = "@loop.outer",        -- Go to previous loop start
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",    -- Go to previous method/function end
              ["[C"] = "@class.outer",       -- Go to previous class end
              ["[I"] = "@conditional.outer", -- Go to previous if/conditional end
              ["[L"] = "@loop.outer",        -- Go to previous loop end
            },
          },
          
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner", -- Swap parameter with next
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner", -- Swap parameter with previous
            },
          },
        },
      })
    end,
  },
}
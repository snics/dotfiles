return {
    -- 🌳 TREESITTER CORE (Basis-Features)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- main branch does not support lazy-loading
        build = ":TSUpdate",
        dependencies = {
            "apple/pkl-neovim", -- PKL support by Apple
        },
        config = function()
            require("nvim-treesitter").setup({
                -- auto_install is handled by the install call below
            })

            -- Parsers to ensure are installed
            local ensure_installed = {
                -- Core Neovim languages
                "lua", "luadoc", "printf", "vim", "vimdoc",
                -- Programming & Markup Languages
                "bash", "c", "cpp", "c_sharp", "css", "csv", "dart", "diff",
                "dockerfile", "go", "goctl", "gomod", "gosum", "gotmpl", "gowork",
                "graphql", "helm", "html", "http", "javascript", "jq", "jsdoc",
                "json", "json5", "markdown", "markdown_inline", "nginx", "php",
                "pkl", "powershell", "python", "regex", "rust", "scss", "sql",
                "toml", "tsx", "typescript", "yaml",
                -- Utility parsers
                "comment", "tmux",
                -- Git-related parsers
                "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
            }

            -- Install missing parsers
            local installed = require("nvim-treesitter").get_installed()
            local to_install = vim.iter(ensure_installed)
                :filter(function(p) return not vim.tbl_contains(installed, p) end)
                :totable()
            if #to_install > 0 then
                require("nvim-treesitter").install(to_install)
            end

            -- Enable treesitter highlighting and indentation via FileType autocmd
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
                callback = function()
                    if pcall(vim.treesitter.start) then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            -- Native incremental selection (0.12): an/in/]n/[n are default mappings.
            -- No config needed — they work automatically.
            -- Optional: add <C-Enter>/<C-Backspace> aliases for muscle memory
            vim.keymap.set("x", "<C-Enter>", function()
                require("vim.treesitter._select").select_parent(vim.v.count1)
            end, { desc = "Expand treesitter selection" })
            vim.keymap.set("x", "<C-Backspace>", function()
                require("vim.treesitter._select").select_child(vim.v.count1)
            end, { desc = "Shrink treesitter selection" })
        end,
    },

    -- nvim-ts-autotag — auto close/rename HTML tags
    -- NOTE: configuring via treesitter.setup({ autotag = ... }) is deprecated
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            opts = {
                enable_close = true,           -- default: true
                enable_rename = true,          -- default: true
                enable_close_on_slash = false, -- default: false
            },
        },
    },

    -- Treesitter textobjects & selection
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
                            ["af"] = "@function.outer",  -- around function
                            ["if"] = "@function.inner",  -- inside function
                            ["ac"] = "@class.outer",     -- around class
                            ["ic"] = "@class.inner",     -- inside class
                            ["aa"] = "@parameter.outer", -- around argument
                            ["ia"] = "@parameter.inner", -- inside argument

                            -- 🎯 CONTROL FLOW (very useful)
                            ["ai"] = "@conditional.outer", -- around if
                            ["ii"] = "@conditional.inner", -- inside if
                            ["al"] = "@loop.outer",        -- around loop
                            ["il"] = "@loop.inner",        -- inside loop

                            -- 📦 PRACTICAL ADDITIONS (daily use)
                            ["ab"] = "@block.outer", -- around block
                            ["ib"] = "@block.inner", -- inside block
                            ["aC"] = "@call.outer",  -- around call
                            ["iC"] = "@call.inner",  -- inside call

                            -- 🗂️ YAML-SPECIFIC (Kubernetes/Helm workflow)
                            ["as"] = "@assignment.outer", -- around assignment (key: value)
                            ["is"] = "@assignment.inner", -- inside assignment (value only)
                            ["ak"] = "@assignment.lhs",   -- assignment key (left side)
                            ["av"] = "@assignment.rhs",   -- assignment value (right side)
                            ["an"] = "@number.inner",     -- around number values
                            ["at"] = "@comment.outer",    -- around comments
                            ["it"] = "@comment.inner",    -- inside comments
                            ["aS"] = "@statement.outer",  -- around YAML statements
                        },

                        -- Set selection modes for different textobjects
                        selection_modes = {
                            ['@parameter.outer'] = 'v',   -- charwise for parameters
                            ['@function.outer'] = 'V',    -- linewise for functions
                            ['@class.outer'] = 'V',       -- linewise for classes
                            ['@conditional.outer'] = 'V', -- linewise for conditionals
                            ['@loop.outer'] = 'V',        -- linewise for loops
                            ['@block.outer'] = 'V',       -- linewise for blocks
                            ['@call.outer'] = 'v',        -- charwise for function calls

                            -- YAML-specific selection modes
                            ['@assignment.outer'] = 'V', -- linewise for complete assignments
                            ['@assignment.inner'] = 'v', -- charwise for values only
                            ['@assignment.lhs'] = 'v',   -- charwise for keys
                            ['@assignment.rhs'] = 'v',   -- charwise for values
                            ['@number.inner'] = 'v',     -- charwise for numbers
                            ['@comment.outer'] = 'V',    -- linewise for comments
                            ['@comment.inner'] = 'v',    -- charwise for comment content
                            ['@statement.outer'] = 'V',  -- linewise for YAML statements
                        },

                        include_surrounding_whitespace = false, -- false for precise selection
                    },

                    move = {
                        enable = true,
                        set_jumps = true,                  -- Add movements to jumplist (can use <C-o>/<C-i> to navigate back/forward)
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
                            ["]a"] = "@parameter.inner", -- Swap parameter with next
                        },
                        swap_previous = {
                            ["[a"] = "@parameter.inner", -- Swap parameter with previous
                        },
                    },
                },
            })
        end,
    },
}

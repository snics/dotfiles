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

    -- nvim-ts-autotag — auto close HTML tags (rename handled by native linked editing)
    -- NOTE: configuring via treesitter.setup({ autotag = ... }) is deprecated
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            opts = {
                enable_close = true,           -- default: true
                enable_rename = false,         -- native linked editing handles tag rename
                enable_close_on_slash = false, -- default: false
            },
        },
    },

    -- Treesitter textobjects & selection
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false, -- must match nvim-treesitter loading
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                    include_surrounding_whitespace = false,
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "V",
                        ["@conditional.outer"] = "V",
                        ["@loop.outer"] = "V",
                        ["@block.outer"] = "V",
                        ["@call.outer"] = "v",
                        ["@assignment.outer"] = "V",
                        ["@assignment.inner"] = "v",
                        ["@assignment.lhs"] = "v",
                        ["@assignment.rhs"] = "v",
                        ["@number.inner"] = "v",
                        ["@comment.outer"] = "V",
                        ["@comment.inner"] = "v",
                        ["@statement.outer"] = "V",
                    },
                },
                move = {
                    set_jumps = true,
                },
            })

            local ts_select = require("nvim-treesitter-textobjects.select")
            local ts_move = require("nvim-treesitter-textobjects.move")
            local ts_swap = require("nvim-treesitter-textobjects.swap")

            local function sel(key, query, desc)
                vim.keymap.set({ "x", "o" }, key, function()
                    ts_select.select_textobject(query, "textobjects")
                end, { desc = desc })
            end

            -- 🔥 THE ESSENTIAL CORE
            sel("af", "@function.outer", "around function")
            sel("if", "@function.inner", "inside function")
            sel("ac", "@class.outer", "around class")
            sel("ic", "@class.inner", "inside class")
            sel("aa", "@parameter.outer", "around argument")
            sel("ia", "@parameter.inner", "inside argument")

            -- 🎯 CONTROL FLOW
            sel("ai", "@conditional.outer", "around if")
            sel("ii", "@conditional.inner", "inside if")
            sel("al", "@loop.outer", "around loop")
            sel("il", "@loop.inner", "inside loop")

            -- 📦 PRACTICAL ADDITIONS
            sel("ab", "@block.outer", "around block")
            sel("ib", "@block.inner", "inside block")
            sel("aC", "@call.outer", "around call")
            sel("iC", "@call.inner", "inside call")

            -- 🗂️ YAML-SPECIFIC (Kubernetes/Helm)
            sel("as", "@assignment.outer", "around assignment")
            sel("is", "@assignment.inner", "inside assignment")
            sel("ak", "@assignment.lhs", "assignment key")
            sel("av", "@assignment.rhs", "assignment value")
            sel("aN", "@number.inner", "around number") -- remapped from "an" to free native selection
            sel("at", "@comment.outer", "around comment")
            sel("it", "@comment.inner", "inside comment")
            sel("aS", "@statement.outer", "around statement")

            -- MOVE: goto next/prev start/end
            local function move_map(key, fn, query, desc)
                vim.keymap.set({ "n", "x", "o" }, key, function()
                    fn(query, "textobjects")
                end, { desc = desc })
            end

            move_map("]m", ts_move.goto_next_start, "@function.outer", "Next function start")
            move_map("]c", ts_move.goto_next_start, "@class.outer", "Next class start")
            move_map("]i", ts_move.goto_next_start, "@conditional.outer", "Next if start")
            move_map("]l", ts_move.goto_next_start, "@loop.outer", "Next loop start")

            move_map("]M", ts_move.goto_next_end, "@function.outer", "Next function end")
            move_map("]C", ts_move.goto_next_end, "@class.outer", "Next class end")
            move_map("]I", ts_move.goto_next_end, "@conditional.outer", "Next if end")
            move_map("]L", ts_move.goto_next_end, "@loop.outer", "Next loop end")

            move_map("[m", ts_move.goto_previous_start, "@function.outer", "Prev function start")
            move_map("[c", ts_move.goto_previous_start, "@class.outer", "Prev class start")
            move_map("[i", ts_move.goto_previous_start, "@conditional.outer", "Prev if start")
            move_map("[l", ts_move.goto_previous_start, "@loop.outer", "Prev loop start")

            move_map("[M", ts_move.goto_previous_end, "@function.outer", "Prev function end")
            move_map("[C", ts_move.goto_previous_end, "@class.outer", "Prev class end")
            move_map("[I", ts_move.goto_previous_end, "@conditional.outer", "Prev if end")
            move_map("[L", ts_move.goto_previous_end, "@loop.outer", "Prev loop end")

            -- SWAP: swap parameters
            vim.keymap.set("n", "]a", function()
                ts_swap.swap_next("@parameter.inner")
            end, { desc = "Swap parameter with next" })
            vim.keymap.set("n", "[a", function()
                ts_swap.swap_previous("@parameter.inner")
            end, { desc = "Swap parameter with previous" })
        end,
    },
}

-- Swiss-army knife plugin with many modules (dashboard, picker, explorer, etc.).
--
-- Enabled modules (setup/opts):
--   bigfile, dashboard, explorer, indent, input, notifier, picker, quickfile,
--   scroll, statuscolumn, words, image
--
-- On-demand modules (keys/init, no setup needed):
--   zen, scratch, debug, terminal, lazygit, gitbrowse, bufdelete, rename,
--   toggle, dim, animate, profiler, gh
--
-- Not used but available:
--   scope     — treesitter-aware text objects (ii/ai) — conflicts with treesitter-textobjects
--   keymap    — enhanced vim.keymap.set with ft/lsp awareness — LspAttach autocmd is sufficient
--   layout    — programmatic window layouts
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,

    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        dashboard = {
            preset = {
                header = [[____            _   ___         _
         / __ \___ _   __/ | / (_)___    (_)___  _____
        / / / / _ \ | / /  |/ / / __ \  / / __ `/ ___/
       / /_/ /  __/ |/ / /|  / / / / / / / /_/ (__  )
     /_____/\___/|___/_/ |_/_/_/ /_/_/ /\__,_/____/
                     /___/
                  ]]
            },
            sections = {
                { section = "header" },
                { section = "keys",   gap = 1, padding = 1 },
                { section = "startup" },

            },
        },
        explorer = {
            enabled = true,
            hidden = true,   -- default: true — show hidden files (consistent with picker)
            ignored = false, -- default: false — hide .gitignored files
        },
        image = { enabled = true },
        indent = {
            enabled = true,
            indent = {
                char = "┊",
            },
            scope = {
                enabled = true,
                char = "┊",
            },
            animate = {
                easing = "outQuad", -- default: "linear" — smoother scope highlight transitions
            },
        },
        input = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000, -- default: 5000 — faster dismiss
        },
        picker = {
            enabled = true,
            sources = {
                files = {
                    hidden = true,
                    ignored = true,
                },
            },
        },
        quickfile = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
            notification = {
                -- wo = { wrap = true } -- Wrap notifications
            }
        }
    },
    keys = {
        -- Top Pickers & Explorer
        { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
        { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
        { "<leader>/",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
        { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
        { "<leader>e",       function() Snacks.explorer() end,                                       desc = "File Explorer" },
        -- find
        { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
        { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
        { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
        { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
        { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
        -- git
        { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
        { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
        { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
        { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
        { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
        { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
        { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
        -- Grep
        { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
        { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
        { "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "Grep" },
        { "<leader>sw",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word",                mode = { "n", "x" } },
        -- Additional search shortcuts
        { "<leader>fs",      function() Snacks.picker.grep() end,                                    desc = "Find string in current working directory" },
        { "<leader>fw",      function() Snacks.picker.grep_word() end,                               desc = "Find word under cursor" },
        { "<leader>ft",      function() Snacks.picker.todo_comments() end,                           desc = "Find all todos" },
        -- search
        { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "Registers" },
        { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = "Search History" },
        { "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds" },
        -- Note: <leader>sb (Buffer Lines) is defined above in the Grep section
        { "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
        { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
        { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
        { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
        { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
        { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
        { "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "Icons" },
        { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
        {
            "<leader>sk",
            function()
                Snacks.picker.keymaps({
                    layout = { hidden = { "preview" } },
                    win = {
                        input = {
                            keys = {
                                ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } },
                            }
                        }
                    },
                })
            end,
            desc = "Keymaps"
        },
        { "<leader>sl", function() Snacks.picker.loclist() end,                                                desc = "Location List" },
        { "<leader>sm", function() Snacks.picker.marks() end,                                                  desc = "Marks" },
        { "<leader>sM", function() Snacks.picker.man() end,                                                    desc = "Man Pages" },
        { "<leader>sp", function() Snacks.picker.lazy() end,                                                   desc = "Search for Plugin Spec" },
        { "<leader>sq", function() Snacks.picker.qflist() end,                                                 desc = "Quickfix List" },
        { "<leader>sP", function() Snacks.picker.resume() end,                                                 desc = "Resume" },
        { "<leader>su", function() Snacks.picker.undo() end,                                                   desc = "Undo History" },
        { "<leader>st", function() Snacks.picker.todo_comments() end,                                          desc = "Todo Comments" },
        { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
        { "<leader>uC", function() Snacks.picker.colorschemes() end,                                           desc = "Colorschemes" },
        -- LSP
        { "gd",         function() Snacks.picker.lsp_definitions() end,                                        desc = "Goto Definition" },
        { "gD",         function() Snacks.picker.lsp_declarations() end,                                       desc = "Goto Declaration" },
        { "gr",         function() Snacks.picker.lsp_references() end,                                         nowait = true,                      desc = "References" },
        { "gI",         function() Snacks.picker.lsp_implementations() end,                                    desc = "Goto Implementation" },
        { "gy",         function() Snacks.picker.lsp_type_definitions() end,                                   desc = "Goto T[y]pe Definition" },
        { "<leader>ss", function() Snacks.picker.lsp_symbols() end,                                            desc = "LSP Symbols" },
        { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,                                  desc = "LSP Workspace Symbols" },
        -- GitHub (gh CLI integration)
        { "<leader>gi", function() Snacks.picker.gh_issue() end,                                               desc = "GitHub Issues (open)" },
        { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end,                              desc = "GitHub Issues (all)" },
        { "<leader>gp", function() Snacks.picker.gh_pr() end,                                                  desc = "GitHub PRs (open)" },
        { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end,                                 desc = "GitHub PRs (all)" },
        -- Profiler
        { "<leader>dP", function() Snacks.profiler.toggle() end,                                               desc = "Toggle Profiler" },
        { "<leader>dO", function() Snacks.profiler.highlight() end,                                            desc = "Toggle Profiler Highlights" },
        { "<leader>dS", function() Snacks.profiler.scratch() end,                                              desc = "Profiler Scratch Buffer" },
        -- Other
        { "<leader>z",  function() Snacks.zen() end,                                                           desc = "Toggle Zen Mode" },
        { "<leader>Z",  function() Snacks.zen.zoom() end,                                                      desc = "Toggle Zoom" },
        { "<leader>.",  function() Snacks.scratch() end,                                                       desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end,                                                desc = "Select Scratch Buffer" },
        { "<leader>n",  function() Snacks.notifier.show_history() end,                                         desc = "Notification History" },
        { "<leader>bd", function() Snacks.bufdelete() end,                                                     desc = "Delete Buffer" },
        { "<leader>bo", function() Snacks.bufdelete.other() end,                                               desc = "Delete Other Buffers" },
        { "<leader>cR", function() Snacks.rename.rename_file() end,                                            desc = "Rename File" },
        { "<leader>gB", function() Snacks.gitbrowse() end,                                                     desc = "Git Browse",                mode = { "n", "v" } },
        { "<leader>gg", function() Snacks.lazygit() end,                                                       desc = "Lazygit" },
        { "<leader>un", function() Snacks.notifier.hide() end,                                                 desc = "Dismiss All Notifications" },
        { "<c-/>",      function() Snacks.terminal() end,                                                      desc = "Toggle Terminal" },
        { "<c-_>",      function() Snacks.terminal() end,                                                      desc = "which_key_ignore" },
        { "]]",         function() Snacks.words.jump(vim.v.count1) end,                                        desc = "Next Reference",            mode = { "n", "t" } },
        { "[[",         function() Snacks.words.jump(-vim.v.count1) end,                                       desc = "Prev Reference",            mode = { "n", "t" } },
        {
            "<leader>N",
            desc = "Neovim News",
            function()
                Snacks.win({
                    file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                    width = 0.6,
                    height = 0.6,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = "yes",
                        statuscolumn = " ",
                        conceallevel = 3,
                    },
                })
            end,
        }
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command

                -- Create some toggle mappings
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                Snacks.toggle.diagnostics():map("<leader>ud")
                Snacks.toggle.line_number():map("<leader>ul")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                    :map("<leader>uc")
                Snacks.toggle.treesitter():map("<leader>uT")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map(
                    "<leader>ub")
                Snacks.toggle.inlay_hints():map("<leader>uh")
                Snacks.toggle.indent():map("<leader>ug")
                Snacks.toggle.animate():map("<leader>ua")
                Snacks.toggle.dim():map("<leader>uD")
            end,
        })
    end,
}

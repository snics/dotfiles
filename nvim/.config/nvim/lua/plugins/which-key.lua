return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        preset = "modern",
    },
    config = function(_, opts)
        require("which-key").setup(opts)

        local wk = require("which-key")
        wk.add({

            ---------------------------------------------------------------
            -- LEADER GROUPS (top-level which-key popup entries)
            ---------------------------------------------------------------
            { "<leader>a", group = "AI", icon = "󰚩" },
            { "<leader>b", group = "Buffer", icon = "󰈔" },
            { "<leader>c", group = "Code", icon = "󰌵" },
            { "<leader>d", group = "Debug", icon = "󰃤" },
            { "<leader>f", group = "Find", icon = "󰈞" },
            { "<leader>g", group = "Git", icon = { cat = "filetype", name = "git" } },
            { "<leader>G", group = "Go", icon = { cat = "filetype", name = "go" } },
            { "<leader>l", group = "LSP/Lint", icon = "󰒕" },
            { "<leader>m", group = "Markdown", icon = { cat = "filetype", name = "markdown" } },
            { "<leader>q", group = "Quit", icon = "󰗼" },
            { "<leader>r", group = "Refactor", icon = "󰣪" },
            { "<leader>R", group = "Rust", icon = { cat = "filetype", name = "rust" } },
            { "<leader>s", group = "Search", icon = "󰍉" },
            { "<leader>t", group = "Test", icon = "󰙨" },
            { "<leader><Tab>", group = "Tabs", icon = "󰓩" },
            { "<leader>u", group = "UI", icon = "󰙵" },
            -- NOTE: <leader>w is an instant action (Save), not a group.
            -- Session subkeys (<leader>wr/ws/wd/wf) appear automatically as which-key discovers them.
            { "<leader>x", group = "Trouble", icon = "󰔫" },
            { "<leader>y", group = "YAML/K8s", icon = { cat = "filetype", name = "yaml" } },

            -- Subgroups
            { "<leader>gh", group = "Hunks", icon = "󰊢" },
            { "<leader>gv", group = "Diffview", icon = "󰦓" },
            { "<leader>Gt", group = "Tags", icon = "󰓹" },
            { "<leader>Gm", group = "Go Mod", icon = "󰏗" },
            { "<leader>Gi", group = "Generate", icon = "󰐊" },
            { "<leader>k", group = "Kustomize", icon = "󱃾" },
            { "<leader>Rc", group = "Crates", icon = { cat = "filetype", name = "toml" } },

            ---------------------------------------------------------------
            -- INSTANT ACTIONS (no submenu)
            ---------------------------------------------------------------
            { "<leader>w", desc = "Save file", icon = "󰆓" },
            { "<leader>W", desc = "Save and close", icon = "󰗼" },
            { "<leader>e", desc = "File Explorer", icon = "󰙅" },
            { "<leader>n", desc = "Notification History", icon = "󰂚" },
            { "<leader>N", desc = "Neovim News", icon = "󰎟" },
            { "<leader>z", desc = "Zen Mode", icon = "󰅺" },
            { "<leader>Z", desc = "Zoom", icon = "󰁌" },
            { "<leader>.", desc = "Scratch Buffer", icon = "󰟃" },
            { "<leader>S", desc = "Select Scratch Buffer", icon = "󰟃" },
            { "<leader>+", desc = "Increment number", icon = "󰐕" },
            { "<leader>-", desc = "Decrement number", icon = "󰍴" },

            ---------------------------------------------------------------
            -- AI — <leader>a (CodeCompanion + Windsurf)
            ---------------------------------------------------------------
            -- CodeCompanion
            { "<leader>aa", desc = "Toggle chat", icon = "󰭹" },
            { "<leader>aA", desc = "New chat", icon = "󰻞" },
            { "<leader>ap", desc = "Action palette", icon = "󰏪", mode = { "n", "v" } },
            { "<leader>ai", desc = "Inline edit", icon = "󰏫", mode = { "n", "v" } },
            { "<leader>ae", desc = "Explain code", icon = "󰋼", mode = "v" },
            { "<leader>af", desc = "Fix code", icon = "󰁨", mode = "v" },
            { "<leader>at", desc = "Generate tests", icon = "󰙨", mode = "v" },
            { "<leader>ar", desc = "Review code", icon = "󰯂", mode = "v" },
            { "<leader>ad", desc = "Document code", icon = "󰈙" },
            { "<leader>ac", desc = "Commit message", icon = { cat = "filetype", name = "git" } },
            -- Windsurf/Codeium (completions)
            { "<leader>av", desc = "Toggle virtual text", icon = "󰄛" },
            { "<leader>aV", desc = "Virtual text ON", icon = "󰄛" },
            { "<leader>ax", desc = "Virtual text OFF", icon = "󰄛" },

            ---------------------------------------------------------------
            -- BUFFER — <leader>b
            ---------------------------------------------------------------
            { "<leader>bd", desc = "Delete buffer", icon = "󰅖" },
            { "<leader>bo", desc = "Delete other buffers", icon = "󰱝" },
            { "<leader>bp", desc = "Pick buffer", icon = "󰈔" },

            ---------------------------------------------------------------
            -- CODE — <leader>c (LSP operations)
            ---------------------------------------------------------------
            { "<leader>ca", desc = "Code actions", icon = "󰌵", mode = { "n", "v" } },
            { "<leader>cr", desc = "Rename symbol", icon = "󰑕" },
            { "<leader>cR", desc = "Rename file", icon = "󰑫" },
            { "<leader>cd", desc = "Line diagnostics", icon = "󱖫" },
            { "<leader>cD", desc = "Toggle diagnostics", icon = "󰔫" },
            { "<leader>cf", desc = "Format file", icon = "󰉢", mode = { "n", "v" } },

            ---------------------------------------------------------------
            -- DEBUG — <leader>d (DAP)
            ---------------------------------------------------------------
            { "<leader>db", desc = "Toggle breakpoint", icon = "󰃤" },
            { "<leader>dB", desc = "Conditional breakpoint", icon = "󰯯" },
            { "<leader>dc", desc = "Continue", icon = "󰐊" },
            { "<leader>dr", desc = "Open REPL", icon = "󰞷" },
            { "<leader>dl", desc = "Run last", icon = "󰑮" },
            { "<leader>dh", desc = "Hover variables", icon = "󰂠" },
            { "<leader>dp", desc = "Preview", icon = "󰁌" },
            { "<leader>df", desc = "Frames", icon = "󰜎" },
            { "<leader>ds", desc = "Scopes", icon = "󰙅" },
            { "<leader>dq", desc = "Quit debug", icon = "󰅗" },
            { "<leader>du", desc = "Toggle UI", icon = "󰍉" },
            { "<leader>de", desc = "Eval", icon = "󰘧", mode = { "n", "v" } },
            { "<leader>dP", desc = "Toggle Profiler", icon = "󰈸" },
            { "<leader>dO", desc = "Toggle Profiler Highlights", icon = "󰸱" },
            { "<leader>dS", desc = "Profiler Scratch Buffer", icon = "󰟃" },

            ---------------------------------------------------------------
            -- FIND — <leader>f (Snacks picker)
            ---------------------------------------------------------------
            { "<leader>ff", desc = "Find files", icon = "󰈞" },
            { "<leader>fg", desc = "Git files", icon = { cat = "filetype", name = "git" } },
            { "<leader>fr", desc = "Recent files", icon = "󰋚" },
            { "<leader>fs", desc = "Find string (grep)", icon = "󰑑" },
            { "<leader>fw", desc = "Find word under cursor", icon = "󱎸" },
            { "<leader>fc", desc = "Config files", icon = "󰒓" },
            { "<leader>fb", desc = "Buffers", icon = "󰈔" },
            { "<leader>fp", desc = "Projects", icon = "󰉋" },
            { "<leader>ft", desc = "Todos", icon = "󰄲" },

            ---------------------------------------------------------------
            -- GIT — <leader>g (Snacks + Gitsigns + Diffview)
            ---------------------------------------------------------------
            -- Top-level
            { "<leader>gg", desc = "Lazygit", icon = { cat = "filetype", name = "git" } },
            { "<leader>gb", desc = "Branches", icon = "󰘬" },
            { "<leader>gl", desc = "Log", icon = "󰜘" },
            { "<leader>gL", desc = "Log (current line)", icon = "󰷐" },
            { "<leader>gs", desc = "Status", icon = "󱖫" },
            { "<leader>gS", desc = "Stash", icon = "󰆓" },
            { "<leader>gd", desc = "Diff", icon = "󰦓" },
            { "<leader>gf", desc = "Log file", icon = "󰈙" },
            { "<leader>gB", desc = "Git Browse", icon = "󰖟", mode = { "n", "v" } },
            { "<leader>gi", desc = "GitHub Issues (open)", icon = "󰌷" },
            { "<leader>gI", desc = "GitHub Issues (all)", icon = "󰌷" },
            { "<leader>gp", desc = "GitHub PRs (open)", icon = "󰘬" },
            { "<leader>gP", desc = "GitHub PRs (all)", icon = "󰘬" },
            -- Hunks subgroup — <leader>gh*
            { "<leader>ghs", desc = "Stage hunk", icon = "󰐕", mode = { "n", "v" } },
            { "<leader>ghr", desc = "Reset hunk", icon = "󰜺", mode = { "n", "v" } },
            { "<leader>ghS", desc = "Stage buffer", icon = "󰐗" },
            { "<leader>ghR", desc = "Reset buffer", icon = "󰦛" },
            { "<leader>ghu", desc = "Undo stage", icon = "󰕌" },
            { "<leader>ghp", desc = "Preview hunk", icon = "󰁌" },
            { "<leader>ghi", desc = "Preview inline", icon = "󰏪" },
            { "<leader>ghb", desc = "Blame line", icon = "󰍷" },
            { "<leader>ghB", desc = "Toggle blame", icon = "󰍶" },
            { "<leader>ghd", desc = "Diff this", icon = "󰦓" },
            { "<leader>ghD", desc = "Diff this ~", icon = "󰕚" },
            { "<leader>ghq", desc = "Hunks to quickfix", icon = "󰁨" },
            { "<leader>ghQ", desc = "All hunks to quickfix", icon = "󰁩" },
            -- Diffview subgroup — <leader>gv*
            { "<leader>gvv", desc = "Open diffview", icon = "󰦓" },
            { "<leader>gvx", desc = "Close diffview", icon = "󰅖" },
            { "<leader>gvh", desc = "File history", icon = "󰋚" },
            { "<leader>gvH", desc = "Branch history", icon = "󰜘" },

            ---------------------------------------------------------------
            -- LSP/LINT — <leader>l
            ---------------------------------------------------------------
            { "<leader>ld", desc = "Toggle diagnostics", icon = "󰔫" },
            { "<leader>lD", desc = "Diagnostics float", icon = "󱖫" },
            { "<leader>lc", desc = "Clear diagnostics", icon = "󰅖" },
            { "<leader>ll", desc = "Open none-ls log", icon = "󰌱" },
            { "<leader>li", desc = "Show none-ls info", icon = "󰋽" },
            { "<leader>ls", desc = "Restart LSP", icon = "󰑓" },

            ---------------------------------------------------------------
            -- MARKDOWN — <leader>m (ft=markdown)
            ---------------------------------------------------------------
            { "<leader>mp", desc = "Toggle browser preview", icon = "󰖟" },
            { "<leader>mr", desc = "Toggle render-markdown", icon = { cat = "filetype", name = "markdown" } },

            ---------------------------------------------------------------
            -- QUIT — <leader>q
            ---------------------------------------------------------------
            { "<leader>qq", desc = "Close buffer", icon = "󰩈" },
            { "<leader>QQ", desc = "Force close buffer", icon = "󰩈" },

            ---------------------------------------------------------------
            -- REFACTOR — <leader>r (refactoring.nvim)
            ---------------------------------------------------------------
            { "<leader>rr", desc = "Select refactor", icon = "󰣪", mode = { "n", "x" } },
            { "<leader>re", desc = "Extract Function", icon = "󰊕", mode = "x" },
            { "<leader>rf", desc = "Extract Function To File", icon = "󰈔", mode = "x" },
            { "<leader>rv", desc = "Extract Variable", icon = "󰀫", mode = "x" },
            { "<leader>ri", desc = "Inline Variable", icon = "󰌒", mode = { "n", "x" } },
            { "<leader>rI", desc = "Inline Function", icon = "󰌑", mode = { "n", "x" } },
            { "<leader>rb", desc = "Extract Block", icon = "󰅩" },
            { "<leader>rbf", desc = "Extract Block To File", icon = "󰅪" },
            { "<leader>rp", desc = "Debug Print Variable", icon = "󰆍", mode = { "n", "x" } },
            { "<leader>rP", desc = "Debug Printf", icon = "󰆏" },
            { "<leader>rc", desc = "Debug Cleanup", icon = "󰃢" },

            ---------------------------------------------------------------
            -- SEARCH — <leader>s (Snacks picker + grug-far)
            ---------------------------------------------------------------
            { "<leader>sb", desc = "Buffer Lines", icon = "󰍉" },
            { "<leader>sB", desc = "Grep Open Buffers", icon = "󰈔" },
            { "<leader>sg", desc = "Grep", icon = "󰑑" },
            { "<leader>sw", desc = "Grep word/selection", icon = "󱎸", mode = { "n", "x" } },
            { "<leader>sr", desc = "Search & Replace", icon = "󰛔" },
            { "<leader>sR", desc = "Search & Replace (file)", icon = "󰈔" },
            { "<leader>s\"", desc = "Registers", icon = "󰅍" },
            { "<leader>s/", desc = "Search History", icon = "󰋚" },
            { "<leader>sa", desc = "Autocmds", icon = "󰃤" },
            { "<leader>sc", desc = "Command History", icon = "󰘳" },
            { "<leader>sC", desc = "Commands", icon = "󰘲" },
            { "<leader>sd", desc = "Diagnostics", icon = "󰒡" },
            { "<leader>sD", desc = "Buffer Diagnostics", icon = "󱖫" },
            { "<leader>sh", desc = "Help Pages", icon = "󰋖" },
            { "<leader>sH", desc = "Highlights", icon = "󰸱" },
            { "<leader>si", desc = "Icons", icon = "󰥶" },
            { "<leader>sj", desc = "Jumps", icon = "󰁔" },
            { "<leader>sk", desc = "Keymaps", icon = "󰌌" },
            { "<leader>sl", desc = "Location List", icon = "󰍒" },
            { "<leader>sm", desc = "Marks", icon = "󰃀" },
            { "<leader>sM", desc = "Man Pages", icon = "󰗚" },
            { "<leader>sp", desc = "Plugin Spec", icon = "󰏗" },
            { "<leader>sq", desc = "Quickfix List", icon = "󰁨" },
            { "<leader>ss", desc = "LSP Symbols", icon = "󰅪" },
            { "<leader>sS", desc = "LSP Workspace Symbols", icon = "󰅩" },
            { "<leader>st", desc = "Todo Comments", icon = "󰄲" },
            { "<leader>sT", desc = "Todo/Fix/Fixme", icon = "󰄱" },
            { "<leader>su", desc = "Undo History", icon = "󰕌" },

            ---------------------------------------------------------------
            -- TEST — <leader>t (neotest)
            ---------------------------------------------------------------
            { "<leader>tt", desc = "Run nearest test", icon = "󰐊" },
            { "<leader>tf", desc = "Run file tests", icon = "󰈙" },
            { "<leader>ta", desc = "Run all tests", icon = "󰑮" },
            { "<leader>ts", desc = "Toggle test summary", icon = "󰈈" },
            { "<leader>to", desc = "Show test output", icon = "󰆍" },
            { "<leader>tp", desc = "Toggle output panel", icon = "󰁌" },
            { "<leader>td", desc = "Debug nearest test", icon = "󰃤" },
            { "<leader>tS", desc = "Stop running tests", icon = "󰅖" },
            { "<leader>tl", desc = "Re-run last test", icon = "󰑓" },

            ---------------------------------------------------------------
            -- TABS — <leader><Tab>
            ---------------------------------------------------------------
            { "<leader><Tab><Tab>", desc = "Open new tab", icon = "󰐕" },
            { "<leader><Tab>x", desc = "Close tab", icon = "󰅖" },
            { "<leader><Tab>d", desc = "Close tab", icon = "󰅖" },
            { "<leader><Tab>]", desc = "Next tab", icon = "󰒭" },
            { "<leader><Tab>n", desc = "Next tab", icon = "󰒭" },
            { "<leader><Tab>[", desc = "Previous tab", icon = "󰒮" },
            { "<leader><Tab>p", desc = "Previous tab", icon = "󰒮" },
            { "<leader><Tab>f", desc = "Buffer to new tab", icon = "󰈔" },

            ---------------------------------------------------------------
            -- UI TOGGLES — <leader>u
            ---------------------------------------------------------------
            { "<leader>uH", desc = "Toggle colorizer", icon = "󰙵" },
            { "<leader>ua", desc = "Toggle animations", icon = "󰙵" },
            { "<leader>uh", desc = "Toggle Vim training", icon = "󰗎" },

            ---------------------------------------------------------------
            -- SAVE + SESSION — <leader>w
            ---------------------------------------------------------------
            { "<leader>wr", desc = "Restore session", icon = "󰁯" },
            { "<leader>ws", desc = "Save session", icon = "󰆓" },
            { "<leader>wd", desc = "Delete session", icon = "󰆴" },
            { "<leader>wf", desc = "Find sessions", icon = "󰱼" },

            ---------------------------------------------------------------
            -- TROUBLE — <leader>x
            ---------------------------------------------------------------
            { "<leader>xw", desc = "Workspace diagnostics", icon = "󰅩" },
            { "<leader>xd", desc = "Document diagnostics", icon = "󰈙" },
            { "<leader>xq", desc = "Quickfix list", icon = "󰁨" },
            { "<leader>xl", desc = "Location list", icon = "󰍒" },
            { "<leader>xt", desc = "Todos", icon = "󰄲" },
            { "<leader>xs", desc = "Symbols outline", icon = "󰅪" },
            { "<leader>xL", desc = "LSP references panel", icon = "󰌹" },

            ---------------------------------------------------------------
            -- YAML/K8s — <leader>y (ft=yaml)
            ---------------------------------------------------------------
            { "<leader>yv", desc = "Show path + value", icon = "󰐕" },
            { "<leader>yy", desc = "Yank path + value", icon = "󰆏" },
            { "<leader>yk", desc = "Yank key", icon = "󰌌" },
            { "<leader>yV", desc = "Yank value", icon = "󰅌" },
            { "<leader>yq", desc = "Quickfix (paths)", icon = "󰁨" },
            { "<leader>yh", desc = "Remove highlight", icon = "󰸱" },
            { "<leader>yp", desc = "Path picker (Snacks)", icon = "󰈞" },
            { "<leader>ys", desc = "Select schema", icon = "󰦨" },
            { "<leader>yS", desc = "Show current schema", icon = "󰋽" },
            { "<leader>yd", desc = "Browse Datree CRDs", icon = "󱃾" },
            { "<leader>yc", desc = "Browse cluster CRDs", icon = "󰡨" },
            { "<leader>ym", desc = "Add CRD modelines", icon = "󰏗" },
            { "<leader>yQ", desc = "Keys to quickfix", icon = "󰁩" },
            { "<leader>yK", desc = "Regenerate K8s schema", icon = "󱃾" },

            ---------------------------------------------------------------
            -- LANGUAGE: GO — <leader>G (ft=go only)
            ---------------------------------------------------------------
            { "<leader>Gtj", desc = "Add json tags", icon = { cat = "extension", name = "json" } },
            { "<leader>Gty", desc = "Add yaml tags", icon = { cat = "extension", name = "yaml" } },
            { "<leader>Gtx", desc = "Add xml tags", icon = { cat = "extension", name = "xml" } },
            { "<leader>Gtr", desc = "Remove tags", icon = "󰅖" },
            { "<leader>Gta", desc = "Generate test (func)", icon = "󰙨" },
            { "<leader>GtA", desc = "Generate test (all)", icon = "󰑮" },
            { "<leader>Gte", desc = "Generate test (exported)", icon = "󰈔" },
            { "<leader>Gmt", desc = "go mod tidy", icon = "󰃢" },
            { "<leader>Gmi", desc = "go mod init", icon = "󰐕" },
            { "<leader>Gmg", desc = "go mod get", icon = "󰇚" },
            { "<leader>Gii", desc = "Implement interface", icon = "󰌗" },
            { "<leader>Gie", desc = "Generate if err", icon = "󱖫" },
            { "<leader>Gc", desc = "Doc comment", icon = "󰆉" },
            { "<leader>Gg", desc = "go generate", icon = "󰐊" },
            { "<leader>GG", desc = "go generate (file)", icon = "󰈙" },

            ---------------------------------------------------------------
            -- LANGUAGE: RUST — <leader>R (ft=rust only)
            ---------------------------------------------------------------
            { "<leader>Re", desc = "Expand macro", icon = "󰁌" },
            { "<leader>Rp", desc = "Parent module", icon = "󰁝" },
            { "<leader>Rd", desc = "Render diagnostic", icon = "󱖫" },
            { "<leader>Rr", desc = "Runnables", icon = "󰐊" },
            { "<leader>RD", desc = "Debuggables", icon = "󰃤" },
            { "<leader>Rj", desc = "Join lines", icon = "󰗈" },
            { "<leader>Ra", desc = "Code action", icon = "󰌵" },
            -- Crates (ft=toml)
            { "<leader>Rcu", desc = "Upgrade all crates", icon = "󰁝" },
            { "<leader>Rci", desc = "Crate info", icon = "󰋽" },
            { "<leader>Rcv", desc = "Crate versions", icon = "󰜘" },
            { "<leader>Rcf", desc = "Crate features", icon = "󰐕" },
            { "<leader>Rcd", desc = "Crate dependencies", icon = "󰌗" },

            ---------------------------------------------------------------
            -- NON-LEADER GROUPS (enhance native Vim prefix popups)
            ---------------------------------------------------------------
            { "g", group = "Goto/LSP", icon = "󰈮" },
            { "]", group = "Next", icon = "󰒭" },
            { "[", group = "Previous", icon = "󰒮" },
            { "z", group = "Folds/View", icon = "󰅃" },
            { "a", group = "Around", icon = "󰅩", mode = { "o", "x" } },
            { "i", group = "Inside", icon = "󰅪", mode = { "o", "x" } },

            ---------------------------------------------------------------
            -- NON-LEADER: LSP Navigation (g prefix)
            ---------------------------------------------------------------
            { "gd", desc = "Go to definition", icon = "󰈮" },
            { "gD", desc = "Go to declaration", icon = "󰊕" },
            { "gr", desc = "Find references", icon = "󰌹" },
            { "gI", desc = "Go to implementation", icon = "󰌗" },
            { "gy", desc = "Go to type definition", icon = "󰊄" },
            { "K", desc = "Hover documentation", icon = "󰋽" },

            ---------------------------------------------------------------
            -- NON-LEADER: Bracket Navigation
            ---------------------------------------------------------------
            { "[d", desc = "Previous diagnostic", icon = "󱖫" },
            { "]d", desc = "Next diagnostic", icon = "󱖫" },
            { "[h", desc = "Previous hunk", icon = "󰊢" },
            { "]h", desc = "Next hunk", icon = "󰊢" },
            { "[t", desc = "Previous todo", icon = "󰄲" },
            { "]t", desc = "Next todo", icon = "󰄲" },
            { "[T", desc = "Previous failed test", icon = "󰙨" },
            { "]T", desc = "Next failed test", icon = "󰙨" },
            { "[b", desc = "Previous buffer", icon = "󰈔" },
            { "]b", desc = "Next buffer", icon = "󰈔" },
            { "[q", desc = "Previous quickfix", icon = "󰁨" },
            { "]q", desc = "Next quickfix", icon = "󰁨" },
            { "[e", desc = "Previous error", icon = "󰅙" },
            { "]e", desc = "Next error", icon = "󰅙" },
            { "[w", desc = "Previous warning", icon = "󰀦" },
            { "]w", desc = "Next warning", icon = "󰀦" },
            { "[x", desc = "Jump to context", icon = "󰅩" },
            { "]]", desc = "Next reference", icon = "󰌹" },
            { "[[", desc = "Previous reference", icon = "󰌹" },

            ---------------------------------------------------------------
            -- NON-LEADER: Treesitter Navigation
            ---------------------------------------------------------------
            { "]m", desc = "Next function start", icon = "󰊕" },
            { "]M", desc = "Next function end", icon = "󰊕" },
            { "]c", desc = "Next class start", icon = "󰌗" },
            { "]C", desc = "Next class end", icon = "󰌗" },
            { "]i", desc = "Next conditional start", icon = "󰕷" },
            { "]I", desc = "Next conditional end", icon = "󰕷" },
            { "]l", desc = "Next loop start", icon = "󰑓" },
            { "]L", desc = "Next loop end", icon = "󰑓" },
            { "[m", desc = "Previous function start", icon = "󰊕" },
            { "[M", desc = "Previous function end", icon = "󰊕" },
            { "[c", desc = "Previous class start", icon = "󰌗" },
            { "[C", desc = "Previous class end", icon = "󰌗" },
            { "[i", desc = "Previous conditional start", icon = "󰕷" },
            { "[I", desc = "Previous conditional end", icon = "󰕷" },
            { "[l", desc = "Previous loop start", icon = "󰑓" },
            { "[L", desc = "Previous loop end", icon = "󰑓" },

            ---------------------------------------------------------------
            -- NON-LEADER: Treesitter Swap
            ---------------------------------------------------------------
            { "]a", desc = "Swap parameter with next", icon = "󰓡" },
            { "[a", desc = "Swap parameter with previous", icon = "󰓡" },

            ---------------------------------------------------------------
            -- NON-LEADER: Treesitter Text Objects
            ---------------------------------------------------------------
            { "af", desc = "Around function", icon = "󰊕", mode = { "o", "x" } },
            { "if", desc = "Inside function", icon = "󰊕", mode = { "o", "x" } },
            { "ac", desc = "Around class", icon = "󰌗", mode = { "o", "x" } },
            { "ic", desc = "Inside class", icon = "󰌗", mode = { "o", "x" } },
            { "aa", desc = "Around argument", icon = "󰏪", mode = { "o", "x" } },
            { "ia", desc = "Inside argument", icon = "󰏪", mode = { "o", "x" } },
            { "ai", desc = "Around conditional", icon = "󰕷", mode = { "o", "x" } },
            { "ii", desc = "Inside conditional", icon = "󰕷", mode = { "o", "x" } },
            { "al", desc = "Around loop", icon = "󰑓", mode = { "o", "x" } },
            { "il", desc = "Inside loop", icon = "󰑓", mode = { "o", "x" } },
            { "ab", desc = "Around block", icon = "󰅩", mode = { "o", "x" } },
            { "ib", desc = "Inside block", icon = "󰅩", mode = { "o", "x" } },
            { "aC", desc = "Around call", icon = "󰘧", mode = { "o", "x" } },
            { "iC", desc = "Inside call", icon = "󰘧", mode = { "o", "x" } },
            { "as", desc = "Around assignment", icon = "󰈙", mode = { "o", "x" } },
            { "is", desc = "Inside assignment (value)", icon = "󰈙", mode = { "o", "x" } },
            { "ak", desc = "Assignment key (left)", icon = "󰌌", mode = { "o", "x" } },
            { "av", desc = "Assignment value (right)", icon = "󰅌", mode = { "o", "x" } },
            { "an", desc = "Around number", icon = "󰩥", mode = { "o", "x" } },
            { "at", desc = "Around comment", icon = "󰨱", mode = { "o", "x" } },
            { "it", desc = "Inside comment", icon = "󰨱", mode = { "o", "x" } },
            { "aS", desc = "Around statement", icon = "󰈙", mode = { "o", "x" } },
            { "ih", desc = "Inside hunk", icon = "󰊢", mode = { "o", "x" } },

            ---------------------------------------------------------------
            -- NON-LEADER: Treesitter Incremental Selection
            ---------------------------------------------------------------
            { "<C-Enter>", desc = "Start/Expand selection", icon = "󰒅", mode = { "n", "v" } },
            { "<C-Backspace>", desc = "Shrink selection", icon = "󰒆", mode = "v" },

            ---------------------------------------------------------------
            -- NON-LEADER: Flash Navigation
            ---------------------------------------------------------------
            { "s", desc = "Flash Jump", icon = "⚡", mode = { "n", "x", "o" } },
            { "S", desc = "Flash Treesitter", icon = "⚡", mode = { "n", "x", "o" } },
            { "r", desc = "Remote Flash", icon = "⚡", mode = "o" },
            { "R", desc = "Treesitter Search", icon = "⚡", mode = { "o", "x" } },
            { "<C-s>", desc = "Toggle Flash Search", icon = "⚡", mode = "c" },

            ---------------------------------------------------------------
            -- NON-LEADER: Comment.nvim
            ---------------------------------------------------------------
            { "gc", group = "Comment", icon = "󰆉" },
            { "gcc", desc = "Toggle line comment", icon = "󰆉" },
            { "gbc", desc = "Toggle block comment", icon = "󰆉" },
            { "gco", desc = "Add comment below", icon = "󰆉" },
            { "gcO", desc = "Add comment above", icon = "󰆉" },
            { "gcA", desc = "Add comment at end of line", icon = "󰆉" },
            { "gc", desc = "Line comment selection", icon = "󰆉", mode = "v" },
            { "gb", desc = "Block comment selection", icon = "󰆉", mode = "v" },

            ---------------------------------------------------------------
            -- NON-LEADER: Folds (ufo.nvim)
            ---------------------------------------------------------------
            { "zR", desc = "Open all folds", icon = "󰅀" },
            { "zM", desc = "Close all folds", icon = "󰅃" },
            { "zr", desc = "Open one fold level", icon = "󰅂" },
            { "zm", desc = "Close one fold level", icon = "󰅁" },
            { "zK", desc = "Peek fold preview", icon = "󰁌" },

            ---------------------------------------------------------------
            -- NON-LEADER: Smooth Scroll (Snacks)
            ---------------------------------------------------------------
            { "<C-u>", desc = "Half-page up (smooth)", icon = "󰒭" },
            { "<C-d>", desc = "Half-page down (smooth)", icon = "󰒮" },
            { "<C-b>", desc = "Page up (smooth)", icon = "󰁌" },
            { "<C-f>", desc = "Page down (smooth)", icon = "󰁎" },
            { "<C-y>", desc = "Line up (smooth)", icon = "󰁝" },
            { "<C-e>", desc = "Line down (smooth)", icon = "󰁅" },
            { "zt", desc = "Cursor to top (smooth)", icon = "󰁌" },
            { "zz", desc = "Cursor to center (smooth)", icon = "󰁍" },
            { "zb", desc = "Cursor to bottom (smooth)", icon = "󰁎" },

            ---------------------------------------------------------------
            -- NON-LEADER: Window Navigation & Resize
            ---------------------------------------------------------------
            { "<C-h>", desc = "Go to left pane (tmux-aware)", icon = "󰁍" },
            { "<C-j>", desc = "Go to lower pane (tmux-aware)", icon = "󰁅" },
            { "<C-k>", desc = "Go to upper pane (tmux-aware)", icon = "󰁝" },
            { "<C-l>", desc = "Go to right pane (tmux-aware)", icon = "󰁔" },
            { "<C-Up>", desc = "Increase window height", icon = "󰞙" },
            { "<C-Down>", desc = "Decrease window height", icon = "󰞒" },
            { "<C-Left>", desc = "Decrease window width", icon = "󰞗" },
            { "<C-Right>", desc = "Increase window width", icon = "󰞘" },

            ---------------------------------------------------------------
            -- NON-LEADER: Line Movement
            ---------------------------------------------------------------
            { "<A-j>", desc = "Move line(s) down", icon = "󰜮", mode = { "n", "i", "v" } },
            { "<A-k>", desc = "Move line(s) up", icon = "󰜷", mode = { "n", "i", "v" } },

            ---------------------------------------------------------------
            -- NON-LEADER: Misc
            ---------------------------------------------------------------
            { "jj", desc = "Exit insert mode", icon = "󰉿", mode = "i" },
            { "jk", desc = "Exit insert mode", icon = "󰉿", mode = "i" },
            { "<Esc>", desc = "Clear search highlights", icon = "󰌑" },
            { "<C-s>", desc = "Save file", icon = "󰆓", mode = { "i", "n", "x", "s" } },
            { "<C-/>", desc = "Toggle terminal", icon = "󰆍" },
            { "<", desc = "Unindent selection", icon = "󰉵", mode = "v" },
            { ">", desc = "Indent selection", icon = "󰉶", mode = "v" },

            ---------------------------------------------------------------
            -- NON-LEADER: Debug F-keys
            ---------------------------------------------------------------
            { "<F5>", desc = "Debug: Start/Continue", icon = "󰐊" },
            { "<F10>", desc = "Debug: Step Over", icon = "󰆹" },
            { "<F11>", desc = "Debug: Step Into", icon = "󰆸" },
            { "<F12>", desc = "Debug: Step Out", icon = "󰆺" },

            ---------------------------------------------------------------
            -- INSERT MODE: Windsurf suggestions
            ---------------------------------------------------------------
            { "<C-l>", desc = "Accept completion", icon = "󰄛", mode = "i" },
            { "<M-]>", desc = "Next suggestion", icon = "󰄛", mode = "i" },
            { "<M-[>", desc = "Previous suggestion", icon = "󰄛", mode = "i" },
            { "<M-c>", desc = "Clear suggestion", icon = "󰄛", mode = "i" },

            ---------------------------------------------------------------
            -- INSERT MODE: nvim-cmp + LuaSnip
            ---------------------------------------------------------------
            { "<Tab>", desc = "Smart Tab: completion/snippet/trigger", icon = "⭐", mode = "i" },
            { "<S-Tab>", desc = "Smart S-Tab: prev/jump back", icon = "⭐", mode = "i" },

        })
    end,
}

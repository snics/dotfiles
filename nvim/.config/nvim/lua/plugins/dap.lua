return {
    -- DAP Core
    {
        "mfussenegger/nvim-dap",
        -- Lazy-load: DAP only loads when a debug keymap is pressed
        keys = {
            { "<F5>",       function() require("dap").continue() end,                                       desc = "Debug: Start/Continue" },
            { "<F10>",      function() require("dap").step_over() end,                                      desc = "Debug: Step Over" },
            { "<F11>",      function() require("dap").step_into() end,                                      desc = "Debug: Step Into" },
            { "<F12>",      function() require("dap").step_out() end,                                       desc = "Debug: Step Out" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                              desc = "Debug: Toggle Breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,      desc = "Debug: Conditional Breakpoint" },
            { "<leader>dr", function() require("dap").repl.open() end,                                      desc = "Debug: Open REPL" },
            { "<leader>dl", function() require("dap").run_last() end,                                       desc = "Debug: Run Last" },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end,                               desc = "Debug: Hover Variables" },
            { "<leader>dp", function() require("dap.ui.widgets").preview() end,                             desc = "Debug: Preview" },
            { "<leader>df", function()
                local w = require("dap.ui.widgets"); w.centered_float(w.frames)
            end,                                                                                            desc = "Debug: Frames" },
            { "<leader>ds", function()
                local w = require("dap.ui.widgets"); w.centered_float(w.scopes)
            end,                                                                                            desc = "Debug: Scopes" },
            { "<leader>dq", function() require("dap").close() end,                                          desc = "Debug: Quit" },
            { "<leader>du", function() require("dapui").toggle() end,                                       desc = "Debug: Toggle UI" },
            { "<leader>de", function() require("dapui").eval() end,                                         desc = "Debug: Eval",                  mode = { "n", "v" } },
        },
        dependencies = {
            -- UI for DAP
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
                -- All dap-ui options below are defaults unless noted otherwise.
                -- See: https://github.com/rcarriga/nvim-dap-ui
                opts = {
                    icons = { expanded = "▾", collapsed = "▸", current_frame = "▶" },
                    mappings = { -- defaults
                        expand = { "<CR>", "<2-LeftMouse>" },
                        open = "o",
                        remove = "d",
                        edit = "e",
                        repl = "r",
                        toggle = "t",
                    },
                    expand_lines = true, -- default: true — expand lines larger than window
                    layouts = { -- default layout
                        {
                            elements = {
                                { id = "scopes", size = 0.25 },
                                "breakpoints",
                                "stacks",
                                "watches",
                            },
                            size = 40,
                            position = "left",
                        },
                        {
                            elements = { "repl", "console" },
                            size = 0.25, -- override: default is 10 lines
                            position = "bottom",
                        },
                    },
                    controls = { -- defaults (enabled on nvim 0.8+)
                        enabled = true,
                        element = "repl",
                        icons = {
                            pause = "",
                            play = "",
                            step_into = "",
                            step_over = "",
                            step_out = "",
                            step_back = "",
                            run_last = "↻",
                            terminate = "□",
                        },
                    },
                    floating = { -- defaults
                        max_height = nil,
                        max_width = nil,
                        border = "single",
                        mappings = { close = { "q", "<Esc>" } },
                    },
                    render = { -- defaults
                        indent = 1,
                        max_type_length = nil,
                        max_value_lines = 100,
                    },
                },
            },

            -- Virtual text for DAP — shows variable values inline during debugging
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {
                    -- All defaults. See: https://github.com/theHamsta/nvim-dap-virtual-text
                    enabled = true,              -- default: true
                    enable_commands = true,      -- default: true — :DapVirtualTextEnable/Disable/Toggle
                    highlight_changed_variables = true, -- default: true
                    highlight_new_as_changed = false, -- default: false
                    show_stop_reason = true,     -- default: true
                    commented = false,           -- default: false — prefix with commentstring
                    only_first_definition = true, -- default: true
                    all_references = false,      -- default: false
                    filter_references_pattern = "<module", -- default: "<module"
                    -- display_callback uses the built-in default (collapses multi-line values)
                },
            },

            -- Mason integration for DAP — auto-installs debug adapters
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = "mason.nvim",
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    automatic_installation = true, -- default: false — auto-install adapters
                    handlers = {},
                    ensure_installed = {
                        "delve", -- Go debugger
                    },
                },
            },

            -- Better Go debugging support
            {
                "leoluz/nvim-dap-go",
                ft = "go",
                config = function()
                    require("dap-go").setup({
                        dap_configurations = {
                            {
                                type = "go",
                                name = "Attach remote",
                                mode = "remote",
                                request = "attach",
                            },
                        },
                        -- delve defaults (kept for documentation)
                        delve = {
                            path = "dlv",  -- default: "dlv"
                            initialize_timeout_sec = 20, -- default: 20
                            port = "${port}", -- default: "${port}" — random available port
                            args = {},     -- default: {}
                            build_flags = "", -- default: "" — e.g. "-tags=unit"
                        },
                    })
                end,
            },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Auto open/close DAP UI on debug lifecycle events
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            -- Breakpoint signs
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignWarn", linehl = "Visual" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticSignHint" })
        end,
    },
}

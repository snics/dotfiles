return {
  -- DAP Core
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for DAP
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap = require("dap")
          local dapui = require("dapui")

          -- DAP UI Setup with good defaults
          dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            mappings = {
              -- Use a table to apply multiple mappings
              expand = { "<CR>", "<2-LeftMouse>" },
              open = "o",
              remove = "d",
              edit = "e",
              repl = "r",
              toggle = "t",
            },
            -- Expand lines larger than the window
            expand_lines = true,
            -- Layouts define sections of the screen to place windows
            layouts = {
              {
                elements = {
                  -- Elements can be strings or table with id and size keys
                  { id = "scopes", size = 0.25 },
                  "breakpoints",
                  "stacks",
                  "watches",
                },
                size = 40, -- 40 columns
                position = "left",
              },
              {
                elements = {
                  "repl",
                  "console",
                },
                size = 0.25, -- 25% of total lines
                position = "bottom",
              },
            },
            controls = {
              -- Requires Neovim nightly (or 0.8 when released)
              enabled = true,
              -- Display controls in this element
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
            floating = {
              max_height = nil, -- These can be integers or a float between 0 and 1
              max_width = nil, -- Floats will be treated as percentage of your screen
              border = "single", -- Border style. Can be "single", "double" or "rounded"
              mappings = {
                close = { "q", "<Esc>" },
              },
            },
            windows = { indent = 1 },
            render = {
              max_type_length = nil, -- Can be integer or nil
              max_value_lines = 100, -- Can be integer or nil
            },
          })

          -- Auto open/close DAP UI
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },

      -- Virtual text for DAP
      {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
          require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            all_references = false,
            filter_references_pattern = "<module",
            -- Display mode:
            -- - "inline" (default): displays variable values inline
            -- - "eol": displays variable values at end of line
            display_callback = function(variable, buf, stackframe, node, options)
              if options.virt_text_pos == "inline" then
                return " = " .. variable.value
              else
                return variable.name .. " = " .. variable.value
              end
            end,
          })
        end,
      },

      -- Mason integration for DAP
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          -- Makes a best effort to setup the various debuggers with
          -- reasonable debug configurations
          automatic_installation = true,
          -- You can provide additional configuration to the handlers,
          -- see mason-nvim-dap README for more information
          handlers = {},
          ensure_installed = {
            -- Update this to ensure that you have the debuggers for the langs you want
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
            -- Additional dap configurations can be added
            -- See :help dap-go for more options
            dap_configurations = {
              {
                -- Must be "go" or it will be ignored by the plugin
                type = "go",
                name = "Attach remote",
                mode = "remote",
                request = "attach",
              },
            },
            -- delve configurations
            delve = {
              -- the path to the executable dlv which will be used for debugging
              -- by default, this is the "dlv" executable on your PATH
              path = "dlv",
              -- time to wait for delve to initialize the debug session
              -- default to 20 seconds
              initialize_timeout_sec = 20,
              -- a string that defines the port to start delve debugger
              -- default to string "${port}" which instructs nvim-dap
              -- to start the process in a random available port
              port = "${port}",
              -- additional args to pass to dlv
              args = {},
              -- the build flags that are passed to delve
              -- defaults to empty string, but can be used to provide flags
              -- such as "-tags=unit" to make sure the test suite is
              -- compiled during debugging, for example
              build_flags = "",
            },
          })
        end,
      },
    },
    config = function()
      local dap = require("dap")

      -- DAP Keymaps
      vim.keymap.set("n", "<F5>", function()
        require("dap").continue()
      end, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F10>", function()
        require("dap").step_over()
      end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", function()
        require("dap").step_into()
      end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", function()
        require("dap").step_out()
      end, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", function()
        require("dap").toggle_breakpoint()
      end, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", function()
        require("dap").repl.open()
      end, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dl", function()
        require("dap").run_last()
      end, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>dh", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Debug: Hover Variables" })
      vim.keymap.set("n", "<leader>dp", function()
        require("dap.ui.widgets").preview()
      end, { desc = "Debug: Preview" })
      vim.keymap.set("n", "<leader>df", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
      end, { desc = "Debug: Frames" })
      vim.keymap.set("n", "<leader>ds", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end, { desc = "Debug: Scopes" })
      vim.keymap.set("n", "<leader>dc", function()
        require("dap").continue()
      end, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<leader>dq", function()
        require("dap").close()
      end, { desc = "Debug: Quit" })

      -- DAP UI Keymaps
      vim.keymap.set("n", "<leader>du", function()
        require("dapui").toggle()
      end, { desc = "Debug: Toggle UI" })
      vim.keymap.set("n", "<leader>de", function()
        require("dapui").eval()
      end, { desc = "Debug: Eval" })
      vim.keymap.set("v", "<leader>de", function()
        require("dapui").eval()
      end, { desc = "Debug: Eval" })

      -- DAP Signs for better visibility
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignWarn", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })

      -- Highlight for stopped line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    end,
  },
}

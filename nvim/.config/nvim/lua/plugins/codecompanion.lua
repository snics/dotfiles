return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "MeanderingProgrammer/render-markdown.nvim",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    keys = {
        -- Chat
        { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>",                                          desc = "Toggle AI chat",           mode = "n" },
        { "<leader>aA", "<cmd>CodeCompanionChat<cr>",                                                 desc = "New AI chat",              mode = "n" },

        -- Action palette
        { "<leader>ap", "<cmd>CodeCompanionActions<cr>",                                              desc = "AI action palette",        mode = { "n", "v" } },

        -- Inline edit
        { "<leader>ai", "<cmd>CodeCompanion<cr>",                                                     desc = "AI inline edit",           mode = "n" },
        { "<leader>ai", ":'<,'>CodeCompanion<cr>",                                                    desc = "AI inline edit selection", mode = "v" },

        -- Quick prompts (visual mode)
        { "<leader>ae", ":'<,'>CodeCompanion /explain<cr>",                                           desc = "AI explain code",          mode = "v" },
        { "<leader>af", ":'<,'>CodeCompanion /fix<cr>",                                               desc = "AI fix code",              mode = "v" },
        { "<leader>at", ":'<,'>CodeCompanion /tests<cr>",                                             desc = "AI generate tests",        mode = "v" },
        { "<leader>ar", ":'<,'>CodeCompanion Review this code for potential improvements<cr>",        desc = "AI review code",           mode = "v" },

        -- Quick prompts (normal mode)
        { "<leader>ad", "<cmd>CodeCompanion Add documentation for the function under the cursor<cr>", desc = "AI document code",         mode = "n" },
        { "<leader>ac", "<cmd>CodeCompanion /commit<cr>",                                             desc = "AI commit message",        mode = "n" },
    },
    config = function()
        --- Ensure an npm package is installed, auto-install if missing
        ---@param bin string Binary name to check
        ---@param pkg string npm package to install
        local function ensure_npm(bin, pkg)
            if vim.fn.executable(bin) == 1 then
                return
            end
            vim.notify("CodeCompanion: installing " .. pkg .. "...", vim.log.levels.INFO)
            local result = vim.fn.system("npm install -g " .. pkg .. " 2>&1")
            if vim.v.shell_error ~= 0 then
                vim.notify("CodeCompanion: failed to install " .. pkg .. "\n" .. result, vim.log.levels.ERROR)
            else
                vim.notify("CodeCompanion: " .. pkg .. " installed", vim.log.levels.INFO)
            end
        end

        --- ACP setup handler that auto-installs npm binaries
        ---@param bin string Binary name
        ---@param pkg string npm package name
        ---@return fun(self: table): boolean
        local function acp_setup(bin, pkg)
            return function(self)
                ensure_npm(bin, pkg)
                return vim.fn.executable(bin) == 1
            end
        end

        -- OpenRouter adapter config (openai_compatible base)
        local openrouter_config = function()
            local base = require("codecompanion.adapters.http.openai_compatible")
            return vim.tbl_deep_extend("force", {}, base, {
                name = "openrouter",
                formatted_name = "OpenRouter",
                env = {
                    url = "https://openrouter.ai/api/v1",
                    api_key = "OPENROUTER_API_KEY",
                    chat_url = "/chat/completions",
                },
                schema = {
                    model = {
                        default = "google/gemini-2.5-flash",
                        choices = {
                            -- Free models
                            ["google/gemini-2.5-flash"] = { formatted_name = "Gemini 2.5 Flash (free)" },
                            ["google/gemini-2.5-pro"] = { formatted_name = "Gemini 2.5 Pro (free)" },
                            ["deepseek/deepseek-v3.2-20251201"] = { formatted_name = "DeepSeek V3.2 (free)" },
                            ["openai/gpt-oss-120b"] = { formatted_name = "GPT-OSS 120B (free)" },
                            ["meta-llama/llama-4-scout:free"] = { formatted_name = "Llama 4 Scout (free)" },
                            ["meta-llama/llama-4-maverick:free"] = { formatted_name = "Llama 4 Maverick (free)" },
                            ["qwen/qwen3-235b-a22b:free"] = { formatted_name = "Qwen3 235B (free)" },
                            ["mistralai/mistral-small-3.1-24b-instruct:free"] = { formatted_name = "Mistral Small 3.1 (free)" },
                            ["moonshotai/kimi-k2.5-0127"] = { formatted_name = "Kimi K2.5 (free)" },
                            -- Paid — budget
                            ["deepseek/deepseek-v3.2"] = { formatted_name = "DeepSeek V3.2 ($0.25/M)" },
                            ["google/gemini-3-flash-preview"] = { formatted_name = "Gemini 3 Flash Preview ($0.50/M)" },
                            -- Paid — mid
                            ["openai/gpt-5.2-codex"] = { formatted_name = "GPT-5.2 Codex ($1.75/M)" },
                            ["google/gemini-3-pro-preview"] = { formatted_name = "Gemini 3 Pro Preview ($2/M)" },
                            -- Paid — frontier
                            ["anthropic/claude-sonnet-4.5"] = { formatted_name = "Claude Sonnet 4.5 ($3/M)" },
                            ["anthropic/claude-opus-4.6"] = { formatted_name = "Claude Opus 4.6 ($5/M)" },
                            ["openai/gpt-5.2"] = { formatted_name = "GPT-5.2 ($2/M)" },
                        },
                    },
                },
            })
        end

        require("codecompanion").setup({
            adapters = {
                -- ACP agents (stateful, CLI-based)
                claude_code = function()
                    return require("codecompanion.adapters").resolve("claude_code", {
                        handlers = { setup = acp_setup("claude-code-acp", "@zed-industries/claude-code-acp") },
                    })
                end,
                opencode = function()
                    return require("codecompanion.adapters").resolve("opencode")
                end,
                gemini_cli = function()
                    return require("codecompanion.adapters").resolve("gemini_cli")
                end,
                codex = function()
                    return require("codecompanion.adapters").resolve("codex", {
                        handlers = { setup = acp_setup("codex-acp", "@zed-industries/codex-acp") },
                    })
                end,
                kimi_cli = function()
                    return require("codecompanion.adapters").resolve("kimi_cli")
                end,
                -- HTTP APIs (for inline edits — ACP doesn't support inline)
                anthropic = function()
                    return require("codecompanion.adapters").resolve("anthropic", {
                        schema = {
                            model = {
                                default = "claude-sonnet-4-5-20250929",
                            },
                        },
                    })
                end,
                openrouter = openrouter_config,
            },

            strategies = {
                chat = {
                    adapter = "claude_code",
                },
                inline = {
                    adapter = "openrouter",
                },
                cmd = {
                    adapter = "openrouter",
                },
            },

            display = {
                action_palette = {
                    provider = "snacks",
                    opts = {
                        show_preset_actions = true,
                        show_preset_prompts = true,
                        show_preset_rules = true,
                    },
                },
                chat = {
                    show_token_count = true,
                    render_headers = true,
                },
                diff = {
                    provider = "default",
                },
            },
        })

        -- Register openrouter in the HTTP adapter registry so resolve() can find it
        require("codecompanion.config").adapters.http.openrouter = openrouter_config
    end,
}

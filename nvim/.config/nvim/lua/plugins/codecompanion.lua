-- TODO: Known issues to fix:
-- 1. OpenRouter adapter: inline/cmd strategy fails with "adapter not found" or nil error
--    - extend("openai_compatible") doesn't register in config.adapters.http
--    - Inline strategy resolves adapter by string name, can't find custom adapters
--    - See: https://github.com/olimorris/codecompanion.nvim/discussions/1013
--    - Workaround: switch inline/cmd to "anthropic" (requires ANTHROPIC_API_KEY)
-- 2. claude-code-acp: auth error 401 (needs ANTHROPIC_API_KEY, no OAuth reuse from claude CLI)
-- 3. codex-acp: same pattern, needs OPENAI_API_KEY
-- 4. Model choices in OpenRouter: not testable until adapter resolution works
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
        { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>",   desc = "Toggle AI chat",           mode = "n" },
        { "<leader>aA", "<cmd>CodeCompanionChat<cr>",          desc = "New AI chat",              mode = "n" },

        -- ACP Agent Shortcuts (consistent with Zed: space a c/g/x/o)
        { "<leader>ac", "<cmd>CodeCompanionChat claude_code<cr>", desc = "Chat with Claude (ACP)", mode = "n" },
        { "<leader>ag", "<cmd>CodeCompanionChat gemini_cli<cr>",  desc = "Chat with Gemini (ACP)", mode = "n" },
        { "<leader>ax", "<cmd>CodeCompanionChat codex<cr>",       desc = "Chat with Codex (ACP)",  mode = "n" },
        { "<leader>ao", "<cmd>CodeCompanionChat opencode<cr>",    desc = "Chat with OpenCode (ACP)", mode = "n" },

        -- Action palette
        { "<leader>ap", "<cmd>CodeCompanionActions<cr>",       desc = "AI action palette",        mode = { "n", "v" } },

        -- Inline edit
        { "<leader>ai", "<cmd>CodeCompanion<cr>",              desc = "AI inline edit",           mode = "n" },
        { "<leader>ai", ":'<,'>CodeCompanion<cr>",             desc = "AI inline edit selection", mode = "v" },

        -- Quick prompts (visual mode)
        { "<leader>ae", ":'<,'>CodeCompanion /explain<cr>",    desc = "AI explain code",          mode = "v" },
        { "<leader>af", ":'<,'>CodeCompanion /fix<cr>",        desc = "AI fix code",              mode = "v" },
        { "<leader>at", ":'<,'>CodeCompanion /tests<cr>",      desc = "AI generate tests",        mode = "v" },
        { "<leader>ar", ":'<,'>CodeCompanion Review this code for potential improvements<cr>", desc = "AI review code", mode = "v" },

        -- Quick prompts (normal mode)
        { "<leader>ad", "<cmd>CodeCompanion Add documentation for the function under the cursor<cr>", desc = "AI document code", mode = "n" },
    },
    config = function()
        require("codecompanion").setup({
            adapters = {
                -- ACP agents (stateful, CLI-based)
                claude_code = function()
                    return require("codecompanion.adapters").resolve("claude_code")
                end,
                opencode = function()
                    return require("codecompanion.adapters").resolve("opencode")
                end,
                gemini_cli = function()
                    return require("codecompanion.adapters").resolve("gemini_cli")
                end,
                codex = function()
                    return require("codecompanion.adapters").resolve("codex")
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
                openrouter = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        env = {
                            url = "https://openrouter.ai/api",
                            api_key = "OPENROUTER_API_KEY",
                            chat_url = "/v1/chat/completions",
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
                end,
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
    end,
}

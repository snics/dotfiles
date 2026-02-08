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
        { "<leader>oa", "<cmd>CodeCompanionChat Toggle<cr>",                                          desc = "Toggle AI chat",           mode = "n" },
        { "<leader>oA", "<cmd>CodeCompanionChat<cr>",                                                 desc = "New AI chat",              mode = "n" },

        -- Action palette
        { "<leader>op", "<cmd>CodeCompanionActions<cr>",                                              desc = "AI action palette",        mode = { "n", "v" } },

        -- Inline edit
        { "<leader>oi", "<cmd>CodeCompanion<cr>",                                                     desc = "AI inline edit",           mode = "n" },
        { "<leader>oi", ":'<,'>CodeCompanion<cr>",                                                    desc = "AI inline edit selection", mode = "v" },

        -- Quick prompts (visual mode)
        { "<leader>oe", ":'<,'>CodeCompanion /explain<cr>",                                           desc = "AI explain code",          mode = "v" },
        { "<leader>of", ":'<,'>CodeCompanion /fix<cr>",                                               desc = "AI fix code",              mode = "v" },
        { "<leader>ot", ":'<,'>CodeCompanion /tests<cr>",                                             desc = "AI generate tests",        mode = "v" },
        { "<leader>or", ":'<,'>CodeCompanion Review this code for potential improvements<cr>",        desc = "AI review code",           mode = "v" },

        -- Quick prompts (normal mode)
        { "<leader>od", "<cmd>CodeCompanion Add documentation for the function under the cursor<cr>", desc = "AI document code",         mode = "n" },
        { "<leader>oc", "<cmd>CodeCompanion /commit<cr>",                                             desc = "AI commit message",        mode = "n" },
    },
    config = function()
        require("codecompanion").setup({
            -- Adapters: Claude Code (ACP), OpenCode (ACP), Anthropic API (HTTP)
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
                            url = "https://openrouter.ai/api/v1",
                            api_key = "OPENROUTER_API_KEY",
                            chat_url = "/chat/completions",
                        },
                        schema = {
                            model = {
                                default = "anthropic/claude-sonnet-4",
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
                    adapter = "anthropic",
                },
                cmd = {
                    adapter = "anthropic",
                },
            },

            display = {
                action_palette = {
                    provider = "snacks",
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

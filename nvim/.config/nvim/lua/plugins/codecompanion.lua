-- NOTE on Claude Code: there is deliberately NO claude_code ACP adapter here.
-- The ACP adapter (claude-agent-acp) requires an ANTHROPIC_API_KEY — Anthropic's
-- ToS forbid reusing Pro/Max subscription OAuth outside Claude Code/claude.ai,
-- so the old 401 was policy, not a bug. Claude integration lives in
-- claudecode.lua instead (native IDE WebSocket protocol, subscription auth,
-- agent runs in a herdr pane and connects via /ide).
-- Codex ACP is fine: codex-acp officially supports ChatGPT login (auth_method).
--
-- Only two agents are in use: Codex (chat, here) and Claude Code (claudecode.lua).
-- Inline/cmd strategies need an HTTP adapter (ACP cannot do inline) — they run
-- on the anthropic adapter. The API key is fetched on demand from 1Password
-- (`cmd:op read`), NOT from ANTHROPIC_API_KEY: that env var is deliberately
-- no longer exported anywhere, so headless CLI calls stay on subscription auth.
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "MeanderingProgrammer/render-markdown.nvim",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    keys = {
        -- Chat (default adapter: codex)
        { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>",   desc = "Toggle AI chat",           mode = "n" },
        { "<leader>aA", "<cmd>CodeCompanionChat<cr>",          desc = "New AI chat",              mode = "n" },
        { "<leader>ax", "<cmd>CodeCompanionChat codex<cr>",    desc = "Chat with Codex (ACP)",    mode = "n" },

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
                -- ACP agent (stateful, CLI-based)
                codex = function()
                    -- ChatGPT subscription auth (no OPENAI_API_KEY needed) —
                    -- supported by codex-acp, see codecompanion ACP adapter docs
                    return require("codecompanion.adapters").extend("codex", {
                        defaults = {
                            auth_method = "chatgpt",
                        },
                    })
                end,
                -- HTTP API (for inline edits — ACP doesn't support inline)
                anthropic = function()
                    return require("codecompanion.adapters").resolve("anthropic", {
                        env = {
                            -- On-demand from 1Password; requires an unlocked op
                            -- session (first shell of the day triggers Touch ID).
                            api_key = 'cmd:op read "op://Employee/Anthropic API Key/credential" --no-newline',
                        },
                        schema = {
                            model = {
                                default = "claude-sonnet-4-5-20250929",
                            },
                        },
                    })
                end,
            },

            strategies = {
                chat = {
                    adapter = "codex",
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

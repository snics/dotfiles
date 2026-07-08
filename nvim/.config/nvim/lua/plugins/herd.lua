-- Drive herdr coding agents from within NeoVim (float mode): spawn/toggle
-- an agent per project, send visual selections to it, pick and preview
-- running agents. Requires the herdr server (always running — Ghostty
-- hosts herdr). Picker/dashboard live under the <leader>a AI group; the
-- default <leader>s/<leader>S clash with Search/Scratch.
return {
  "MomePP/herd.nvim",
  event = "VeryLazy",
  opts = {
    tools = {
      claude = { cmd = { "claude" } },
      opencode = { cmd = { "opencode" } },
      codex = { cmd = { "codex" } },
    },
    keys = {
      select = "<leader>ah",
      dashboard = "<leader>aH",
    },
  },
}

-- Incremental LSP rename with live preview.
-- Available config: cmd_name, hl_group, preview_empty_name, show_message,
--   save_in_cmdline_history, input_buffer_type ("dressing"|"snacks"|nil), post_hook
return {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {
        input_buffer_type = "snacks", -- default: nil — use snacks.nvim for rename input UI
    },
}

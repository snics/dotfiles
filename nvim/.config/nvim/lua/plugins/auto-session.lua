return {
    "rmagatti/auto-session",
    cmd = { "SessionRestore", "SessionSave", "SessionDelete", "Autosession" },
    keys = {
        { "<leader>wr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
        { "<leader>ws", "<cmd>SessionSave<cr>",    desc = "Save session" },
    },
    opts = {
        auto_save = true,
        auto_restore = false,
        auto_create = true,
        auto_delete_empty_sessions = true,
        git_use_branch_name = true,
        show_auto_restore_notif = true,
        close_unsupported_windows = true,
        bypass_save_filetypes = { "gitcommit", "gitrebase" },
        suppressed_dirs = {
            "~/",
            "~/Downloads",
            "~/Documents",
            "~/Desktop",
        },
        session_lens = {
            picker = "snacks",
        },
    },
}

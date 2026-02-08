return {
    "rmagatti/auto-session",
    cmd = { "SessionRestore", "SessionSave", "SessionDelete", "Autosession" },
    keys = {
        { "<leader>wr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
        { "<leader>ws", "<cmd>SessionSave<cr>",    desc = "Save session" },
    },
    opts = {
        auto_restore = false,
        git_use_branch_name = true,
        show_auto_restore_notif = true,
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

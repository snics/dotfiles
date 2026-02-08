return {
    "Saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {
        -- In-process LSP server (replaces deprecated completion.cmp and null_ls)
        -- Provides: completion, hover (K), code actions (upgrade, git source, etc.)
        lsp = {
            enabled = true,    -- default: false
            actions = true,    -- default: false — code actions (upgrade crate, open docs, etc.)
            completion = true, -- default: false — version/feature completion via LSP
            hover = true,      -- default: false — crate info on K
        },
    },
    keys = {
        { "<leader>rcu", function() require("crates").upgrade_all_crates() end,      desc = "Update all crates",  ft = "toml" },
        { "<leader>rci", function() require("crates").show_popup() end,              desc = "Crate info popup",   ft = "toml" },
        { "<leader>rcv", function() require("crates").show_versions_popup() end,     desc = "Crate versions",     ft = "toml" },
        { "<leader>rcf", function() require("crates").show_features_popup() end,     desc = "Crate features",     ft = "toml" },
        { "<leader>rcd", function() require("crates").show_dependencies_popup() end, desc = "Crate dependencies", ft = "toml" },
    },
}

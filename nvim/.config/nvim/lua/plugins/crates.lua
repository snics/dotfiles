return {
    "Saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {
        completion = {
            cmp = { enabled = true },
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

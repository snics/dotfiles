return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        -- signs/signs_staged use defaults: ┃ for add/change, ▁ for delete, ▔ for topdelete, ~ for changedelete
        numhl = true, -- default: false — colorize line numbers for changed lines

        on_attach = function(bufnr)
            local gs = require("gitsigns")

            local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
            end

            -- Navigation — diff-mode aware (falls through to native ]c/[c in vimdiff)
            map("n", "]h", function()
                if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
            end, "Next Hunk")
            map("n", "[h", function()
                if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
            end, "Prev Hunk")

            -- Stage / Reset
            map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
            map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
            map("v", "<leader>ghs", function()
                gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Stage hunk")
            map("v", "<leader>ghr", function()
                gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Reset hunk")

            map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
            map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
            map("n", "<leader>ghu", gs.reset_buffer_index, "Unstage buffer")

            -- Preview
            map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
            map("n", "<leader>ghi", gs.preview_hunk_inline, "Preview hunk inline")

            -- Blame
            map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
            map("n", "<leader>ghB", gs.toggle_current_line_blame, "Toggle line blame")

            -- Diff
            map("n", "<leader>ghd", gs.diffthis, "Diff this")
            map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")

            -- Quickfix
            map("n", "<leader>ghq", gs.setqflist, "Hunks to quickfix")
            map("n", "<leader>ghQ", function() gs.setqflist("all") end, "All hunks to quickfix")

            -- Text object: ih = inner hunk (use with operators: dih, yih, vih)
            map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
        end,
    },
}

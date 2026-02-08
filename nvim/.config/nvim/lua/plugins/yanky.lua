return {
    "gbprod/yanky.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        highlight = { timer = 200 },
    },
    keys = {
        { "y",     "<Plug>(YankyYank)",          mode = { "n", "x" },               desc = "Yank" },
        { "p",     "<Plug>(YankyPutAfter)",      mode = { "n", "x" },               desc = "Put after" },
        { "P",     "<Plug>(YankyPutBefore)",     mode = { "n", "x" },               desc = "Put before" },
        { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle yank history (prev)" },
        { "<C-n>", "<Plug>(YankyNextEntry)",     desc = "Cycle yank history (next)" },
    },
}

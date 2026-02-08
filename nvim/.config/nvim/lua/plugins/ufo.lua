return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,               desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end,              desc = "Close all folds" },
        { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
        { "zr", function() require("ufo").openFoldsExceptKinds() end,       desc = "Open one fold level" },
        { "zm", function() require("ufo").closeFoldsWith() end,             desc = "Close one fold level" },
    },
    opts = {
        provider_selector = function()
            return { "treesitter", "indent" }
        end,
    },
}

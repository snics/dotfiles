return {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
        { "<leader>sr", function() require("grug-far").open() end,                                                     desc = "Search and Replace" },
        { "<leader>sr", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search and Replace (word)",        mode = "v" },
        { "<leader>sR", function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end,        desc = "Search and Replace (current file)" },
    },
    opts = {
        headerMaxWidth = 80,
    },
}

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- ensure these language parsers are installed
      ensure_installed = {
          "lua",
          "luadoc",
          "printf",
          "vim",
          "vimdoc",

          -- Make sure to install these parsers
          "bash",
          "c",
          "cpp",
          "c_sharp",
          "css",
          "csv",
          "dart",
          "diff",
          "dockerfile",
          "git_config",
          "git_rebase",
          "gitattributes",
          "gitcommit",
          "gitignore",
          "go",
          "goctl",
          "gomod",
          "gosum",
          "gotmpl",
          "gowork",
          "graphql",
          "html",
          "http",
          "javascript",
          "jq",
          "jsdoc",
          "json",
          "json5",
          "markdown",
          "markdown_inline",
          "nginx",
          "php",
          "powershell",
          "python",
          "regex",
          "rust",
          "scss",
          "sql",
          "comment",
          "tmux",
          "toml",
          "tsx",
          "typescript",
          "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",bs
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
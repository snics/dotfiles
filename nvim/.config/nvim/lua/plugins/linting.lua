return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            ansible = { "ansible-lint" },
            bash = { "shellcheck" },
            css = { "stylelint" },
            dockerfile = { "hadolint", "trivy" },
            html = { "htmlhint" },
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            json = { "jsonlint" },
            lua = { "luacheck" },
            markdown = { "markdownlint-cli2", "vale" },
            rst = { "vale" },
            sh = { "shellcheck" },
            sql = { "sqlfluff" },
            terraform = { "tflint" },
            text = { "vale" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            vim = { "vint" },
            yaml = { "yamllint", "trivy" },
            zsh = { "shellcheck" },
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        -- trigger linting on file open, write, and insert leave
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        -- trigger linting the current file
        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}

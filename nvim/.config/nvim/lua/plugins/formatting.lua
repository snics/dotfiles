return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				bash = { "shfmt", "shellharden" },
				bibtex = { "bibtex-tidy" },
				css = { "prettierd" },
				graphql = { "prettierd" },
				go = { "gopls" },
				html = { "prettierd" },
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" },
				json = { "prettierd", "jq" },
				lua = { "stylua" },
				markdown = { "prettierd" },
				sh = { "shfmt", "shellharden" },
				sql = { "sqlfmt" },
				tex = { "latexindent" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				xml = { "xmlformatter" },
				yaml = { "prettierd", "yq" },
				zsh = { "shfmt", "shellharden" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		-- Format file or range (in visual mode)
		vim.keymap.set({ "n", "v" }, "<leader>pf", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })

		-- Format all files in the current directory
		vim.keymap.set("n", "<leader>pa", function()
			conform.format_all({
				lsp_fallback = true,
				async = false,
				timeout_ms = 000,
			})
		end, { desc = "Format all files in the current directory" })
	end,
}

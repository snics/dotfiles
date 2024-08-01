require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- General Keymaps
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "jk to escape" })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd> q <cr>", { desc = "Quit" })

-- LSP Keymaps
map("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to References" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })

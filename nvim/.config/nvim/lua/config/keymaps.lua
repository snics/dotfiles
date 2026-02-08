vim.g.mapleader = " "

local keymap = vim.keymap

-- General
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" })
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Close / Save
keymap.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "Close buffer" })
keymap.set("n", "<leader>QQ", "<cmd>q!<CR>", { desc = "Force close buffer" })
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" })
keymap.set("n", "<leader>W", "<cmd>wq<CR>", { desc = "Save and close" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Visual mode indentation (preserves selection)
keymap.set("v", "<", "<gv", { desc = "Unindent and keep selection" })
keymap.set("v", ">", ">gv", { desc = "Indent and keep selection" })
keymap.set("v", "<leader><", "<gv", { desc = "Unindent and keep selection" })
keymap.set("v", "<leader>>", ">gv", { desc = "Indent and keep selection" })

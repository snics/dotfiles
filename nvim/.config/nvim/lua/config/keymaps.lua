vim.g.mapleader = " " -- set leader key to space

local keymap = vim.keymap -- for conciseness

-- General
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" }) -- exit insert mode with jj
keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights on search when pressing <Esc> in normal mode

-- Closeing
keymap.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "Close buffers" }) -- close buffers
keymap.set("n", "<leader>QQ", "<cmd>q!<CR>", { desc = "Close force buffer" }) -- close force buffer

-- Save
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" }) -- save buffer
keymap.set("n", "<leader>W", "<cmd>wq<CR>", { desc = "Save buffer and close" }) -- save buffer and close

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- Visual Mode Indentation (preserves visual mode)
keymap.set("v", "<", "<gv", { desc = "Unindent selection and keep visual mode" }) -- unindent and stay in visual mode
keymap.set("v", ">", ">gv", { desc = "Indent selection and keep visual mode" }) -- indent and stay in visual mode

-- Visual Mode Indentation with leader keys (alternative)
keymap.set("v", "<leader><", "<gv", { desc = "Unindent selection and keep visual mode" }) -- unindent with leader
keymap.set("v", "<leader>>", ">gv", { desc = "Indent selection and keep visual mode" }) -- indent with leader

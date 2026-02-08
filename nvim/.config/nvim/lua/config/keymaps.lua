vim.g.mapleader = " "

local keymap = vim.keymap

-- General
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" })
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Close / Save
keymap.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "Close buffer" })
keymap.set("n", "<leader>QQ", "<cmd>q!<CR>", { desc = "Force close buffer" })
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" })
keymap.set("n", "<leader>W", "<cmd>wq<CR>", { desc = "Save and close" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window navigation (Ctrl+hjkl — standard in LazyVim/AstroNvim/NvChad)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Window resize (Ctrl+Arrow)
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Tab management (<leader><Tab> prefix — LazyVim convention)
keymap.set("n", "<leader><Tab><Tab>", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader><Tab>x", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader><Tab>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader><Tab>]", "<cmd>tabn<CR>", { desc = "Next tab" })
keymap.set("n", "<leader><Tab>n", "<cmd>tabn<CR>", { desc = "Next tab" })
keymap.set("n", "<leader><Tab>[", "<cmd>tabp<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader><Tab>p", "<cmd>tabp<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader><Tab>f", "<cmd>tabnew %<CR>", { desc = "Buffer to new tab" })

-- Visual mode indentation (preserves selection)
keymap.set("v", "<", "<gv", { desc = "Unindent and keep selection" })
keymap.set("v", ">", ">gv", { desc = "Indent and keep selection" })

-- Save with Ctrl+S (universal editor muscle memory)
keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Move lines with Alt+j/k
keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
keymap.set("n", "<A-k>", "<cmd>execute 'move .-1-' . v:count1<cr>==", { desc = "Move line up" })
keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move selection down" })
keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-1-\" . v:count1<cr>gv=gv", { desc = "Move selection up" })

-- Bracket navigation extensions
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap.set("n", "[b", "<cmd>bprev<cr>", { desc = "Prev buffer" })
keymap.set("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })
keymap.set("n", "[q", "<cmd>cprev<cr>zz", { desc = "Prev quickfix" })
keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
    { desc = "Next error" })
keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
    { desc = "Prev error" })
keymap.set("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end,
    { desc = "Next warning" })
keymap.set("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end,
    { desc = "Prev warning" })

-- Insert-mode undo breakpoints
keymap.set("i", ",", ",<C-g>u")
keymap.set("i", ".", ".<C-g>u")
keymap.set("i", ";", ";<C-g>u")

-- Smart j/k on wrapped lines
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

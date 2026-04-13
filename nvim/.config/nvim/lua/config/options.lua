local opt = vim.opt

-- File explorer
vim.g.netrw_liststyle = 3 -- default: 0 (thin) — use tree view

-- Line numbers
opt.relativenumber = true -- default: false
opt.number = true         -- default: false

opt.showmode = false      -- default: true — redundant with lualine statusline
opt.undofile = true       -- default: false — persist undo history across sessions

-- Tabs & indentation
opt.tabstop = 2      -- default: 8
opt.shiftwidth = 2   -- default: 8
opt.expandtab = true -- default: false — use spaces instead of tabs

opt.wrap = false     -- default: true

-- Search
opt.ignorecase = true -- default: false
opt.smartcase = true  -- default: false — case-sensitive when uppercase is used

opt.cursorline = true -- default: false

-- Colors
opt.signcolumn = "yes"       -- default: "auto" — always show to prevent text shifting

-- Floating window borders (0.11+) — consistent rounded borders for all float windows
vim.o.winborder = "rounded"

-- Whitespace visualization
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split" -- default: "" — live preview of :s substitutions

-- Clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard

-- Split windows
opt.splitright = true -- default: false
opt.splitbelow = true -- default: false

-- Folding (nvim-ufo)
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

opt.swapfile = false -- default: true

vim.cmd("let g:netrw_liststyle = 3") -- netrw list style

local opt = vim.opt -- to set options

-- line numbers
opt.relativenumber = true -- relative line numbers
opt.number = true -- show line numbers

opt.showmode = false -- don't show mode in command line because it's already shown in statusline

opt.undofile = true -- Save undo history

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.expandtab = true -- convert tabs to spaces

opt.wrap = false -- don't wrap lines

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true -- highlight current line

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true -- true color support
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true -- show some invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- show tabs, trailing spaces, and non-breaking spaces
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!


-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false -- don't create swapfile

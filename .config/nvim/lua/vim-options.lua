-- Set leader key (before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Indentation: tabs insert spaces, two spaces per level
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.wrap = false

-- Line numbers & cursor context
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Files / persistent undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'

-- UI / editing quality-of-life
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
--vim.opt.colorcolumn = '80'
vim.opt.showmode = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = 'a'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Use the system clipboard for yank/paste
vim.opt.clipboard = 'unnamedplus'

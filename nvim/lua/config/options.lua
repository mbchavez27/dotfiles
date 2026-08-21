-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Cursor
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- Indentation
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true

-- UI
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.showmode = false
vim.o.showcmd = true
vim.o.wrap = true
vim.o.foldenable = false
vim.o.foldmethod = "manual"

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true

-- Splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Clipboard
vim.o.clipboard = "unnamedplus"

-- Misc
vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.mouse = "a"

-- Transparent background
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")

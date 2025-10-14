-- General editor options
vim.o.number = true -- line numbers
vim.o.relativenumber = true -- relative numbers like VSCode
vim.o.cursorline = true -- highlight current line
vim.o.wrap = true -- word wrap
vim.o.scrolloff = 8 -- VSCode-like scroll padding
vim.o.sidescrolloff = 8
vim.o.showmode = false -- no mode display
vim.o.clipboard = "unnamedplus" -- system clipboard

-- Tabs and indentation
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true

-- UI
vim.o.cursorline = true
vim.o.cursorcolumn = false
vim.o.showcmd = true
vim.o.signcolumn = "yes" -- like gutter
vim.o.termguicolors = true
vim.o.background = "dark"

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true

-- VSCode cursor settings
vim.o.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25,r-cr-o:hor20"

-- Misc
vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.mouse = "a"
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"

vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")

-- Minimap style options can go here if using plugins

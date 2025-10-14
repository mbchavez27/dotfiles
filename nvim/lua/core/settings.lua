-- General editor settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.wrap = true
vim.o.termguicolors = true
vim.o.clipboard = "unnamedplus"
vim.o.scrolloff = 8
vim.o.updatetime = 300
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.mouse = "a"

-- Font & theme
vim.opt.guifont = "JetBrains Mono:h14"
vim.cmd([[colorscheme gruvbox]])

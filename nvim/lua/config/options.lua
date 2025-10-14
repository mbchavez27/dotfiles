-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

opt.number = true
opt.relativenumber = true -- "editor.lineNumbers": "relative"
opt.wrap = true -- "editor.wordWrap": "on"
opt.scrolloff = 5
opt.signcolumn = "yes"
opt.cursorline = true -- "editor.renderLineHighlight": "all"
opt.termguicolors = true
opt.guifont = "JetBrainsMono:h14" -- "editor.fontFamily": "JetBrains Mono"
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- for system clipboard support

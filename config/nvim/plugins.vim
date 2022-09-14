call plug#begin('~/AppData/Local/nvim/plugged')
"Home Page
Plug 'goolord/alpha-nvim'
"Icons 
Plug 'kyazdani42/nvim-web-devicons'
"Buffers and Status Lines 
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
Plug 'nvim-lualine/lualine.nvim'
"Color Scheme
Plug 'ellisonleao/gruvbox.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
"Colors
Plug 'ziontee113/color-picker.nvim'
"File Explorer 
Plug 'kyazdani42/nvim-tree.lua'
"Fuzzy Finder 
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
"Visualize Colors
Plug 'norcalli/nvim-colorizer.lua'
"Discord Prescence 
Plug 'andweeb/presence.nvim'
"Comments Lines
Plug 'numToStr/Comment.nvim'
"Highlights Words and Lines 
Plug 'yamatsum/nvim-cursorline'
"TreeSitters
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Errors 
Plug 'folke/trouble.nvim'
"LSP and Auto Complete
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'
"Format on Save 
Plug 'jose-elias-alvarez/null-ls.nvim'
"Markdown 
Plug 'iamcco/markdown-preview.nvim'
Plug 'mzlogin/vim-markdown-toc'
"Terminal
Plug 'akinsho/toggleterm.nvim', {'tag' : 'v2.*'}
"Git
Plug 'kdheepak/lazygit.nvim'
Plug 'lewis6991/gitsigns.nvim'
"ZenMode
Plug 'folke/zen-mode.nvim'
"Ascii Image
Plug 'samodostal/image.nvim'
call plug#end()

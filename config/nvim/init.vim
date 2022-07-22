"  = = = = = =   = = = =  =       =
"  =   = =   =   =     =    =   =
"  =   = =   =   = = = =      = 
"  =         =   =     =    =   =
"  =         =   =     =  =       =

"Plugins
source C:\Users\mbchavez\AppData\Local\nvim\plugins.vim

"VimScript Configs
"Markdown
let g:mkdp_auto_start = 1  
"Choose color Scheme 
colorscheme gruvbox

"Enables Syntax
syntax enable  

"Autocmds
"Close Vim when NVIM Tree is Only Open
autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
"Allows background image in neovim
augroup user_colors
  autocmd!
  autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
augroup END

lua <<EOF
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]
EOF

"Lua Configs
lua dofile('C:\\Users\\mbchavez\\AppData\\Local\\nvim\\configs.lua')


"KeyBinds
"Map Leader
let mapleader = " "
"NvimTree
nnoremap <silent> <C-b> :NvimTreeToggle<CR> 
"Use to Switch Panels
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
"Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
"Color Picker
nnoremap <silent> <C-c> <cmd>PickColor <CR> 
inoremap <silent> <C-c> <cmd>PickColorInsert <CR> 
"Changing Tabs 
nnoremap <silent> H :bnext <CR>
nnoremap <silent> L :bprevious <CR>
nnoremap <silent> T :tabnew <CR>
nnoremap <silent> W :bdelete!<CR>
"Trouble Errors
nnoremap <leader>tb <cmd>TroubleToggle <CR>
"Toggle Terminal
nnoremap <leader>tt <cmd>ToggleTerm direction=float<CR>
"Git
nnoremap <leader>lg <cmd>:LazyGit<CR>

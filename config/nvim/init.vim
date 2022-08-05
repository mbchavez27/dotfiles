"  = = = = = =   = = = =  =       =
"  =   = =   =   =     =    =   =
"  =   = =   =   = = = =      = 
"  =         =   =     =    =   =
"  =         =   =     =  =       =

"Plugins
source C:\Users\mbchavez\AppData\Local\nvim\plugins.vim

"VimScript Configs
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
"Open a Notes and To-Do List 
nnoremap <silent>mt <cmd>:vs F:\Max's Files\Productivity Files\Managament Files\OrgFiles_mbchavez\TASKS.md<CR> 
nnoremap <silent>mn <cmd>:vs F:\Max's Files\Productivity Files\Managament Files\OrgFiles_mbchavez\NOTES.md<CR> 
nnoremap <silent>mr <cmd>:vs F:\Max's Files\Productivity Files\Managament Files\OrgFiles_mbchavez\README.md<CR> 
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
nnoremap <leader>hp <cmd>:Gitsigns preview_hunk<CR>
nnoremap <silent><C-n> <cmd>:Gitsigns prev_hunk<CR>
nnoremap <silent><C-p> <cmd>:Gitsigns next_hunk<CR>
"LSP Saga
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent>gs <Cmd>Lspsaga signature_help<CR>
nnoremap <silent> gh <Cmd>Lspsaga lsp_finder<CR>
nnoremap <leader> ca<Cmd>Lspsaga code_action<CR>
vnoremap <leader> ca <Cmd><C-U>Lspsaga code_action<CR>
nnoremap <silent> gd <Cmd>Lspsaga preview_definition<CR>
nnoremap <silent> gr <Cmd>Lspsaga rename<CR>
nnoremap <silent> cd <Cmd>Lspsaga show_line_diagnostics<CR>
nnoremap <silent> [e<Cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> ]e<Cmd>Lspsaga diagnostic_jump_prev<CR>
lua <<EOF
local action = require("lspsaga.action")
-- scroll down hover doc or scroll in definition preview
vim.keymap.set("n", "<C-n>", function()
    action.smart_scroll_with_saga(1)
end, { silent = true })
-- scroll up hover doc
vim.keymap.set("n", "<C-p>", function()
    action.smart_scroll_with_saga(-1)
end, { silent = true })
EOF

"Zen Mode 
nnoremap <silent> zz <CMD>:ZenMode<CR>

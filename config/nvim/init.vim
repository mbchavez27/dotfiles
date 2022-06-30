set number
call plug#begin('~/AppData/Local/nvim/plugged')
Plug 'andweeb/presence.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mhinz/vim-startify'
Plug 'scrooloose/nerdtree'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
Plug 'ryanoasis/vim-devicons'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'tiagovla/tokyodark.nvim'
Plug 'dikiaap/minimalist'
Plug 'KabbAmine/vCoolor.vim'
Plug 'miyakogi/conoline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = ['coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver']
call plug#end()

set number
set mouse=a

augroup user_colors
  autocmd!
  autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
augroup END

if (has("termguicolors"))
 set termguicolors
lua << EOF
require("bufferline").setup{}
EOF
endif
syntax enable
colorscheme gruvbox

let g:conoline_color_normal_dark = 'guibg=#333333 guifg=#dddddd gui=None '
                           \. 'ctermbg=grey ctermfg=white'
let g:conoline_color_insert_dark = 'guibg=black guifg=white gui=bold '
                           \. 'ctermbg=black ctermfg=white'


autocmd BufNewFile *.html 0r ~/.config/nvim/templates/html.skel

let g:NERDTreeWinPos = "right"
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Toggle
nnoremap <silent> <C-b> :NERDTreeToggle<CR>


" open new split panes to right and below
set splitright
set splitbelow
" turn terminal to normal mode with escape
tnoremap <Esc> <C-\><C-n>
" start terminal in insert mode
au BufEnter * if &buftype == 'terminal' | :startinsert | endif
" open terminal on ctrl+n
function! OpenTerminal()
  split term://powershell
  resize 10
endfunction
nnoremap <c-n> :call OpenTerminal()<CR>


" use alt+hjkl to move between split/vsplit panels
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

nnoremap <C-p> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

lua << END
require('lualine').setup()
options = { theme = 'gruvbox' }
END

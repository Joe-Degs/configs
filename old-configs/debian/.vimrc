syntax on
set number
set ruler
set encoding=utf-8
set fileencoding=utf-8
set noswapfile
set mouse=a
set colorcolumn=80
set formatoptions=tcqrn1
set ttyfast
set backspace=indent,eol,start
filetype plugin indent on

" copy/paste to/from system clipboard
set clipboard=unnamedplus

" spacing for all file types
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
"set noshiftround

set undofile
set undodir=~/.vim/undodir

" from the kernel guidelines.
autocmd Filetype c setlocal shiftwidth=8 tabstop=8 softtabstop=8 noexpandtab cindent cc=80 | %retab | autocmd BufWritePre * %s/\s\+$//e

autocmd Filetype yaml setlocal ts=2 sw=2 sts=2 et

" Hardcore mode, disable arrow keys.
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" sane splits
set splitright
set splitbelow

" wild menus
set wildmenu
set wildmode=list:longest
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor

" changing tabs
nnoremap <C-J> <C-w><C-J>
nnoremap <C-K> <C-w><C-K>
nnoremap <C-L> <C-w><C-L>
nnoremap <C-H> <C-W><C-H>

" better searching
nnoremap / /\v
vnoremap / /\v
set hlsearch
set smartcase
set ignorecase
set incsearch
set showmatch

" terminal
set t_Co=256
set background=dark
colo habamax
hi Normal guibg=NONE ctermbg=NONE

" golang commands
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1

" fuzzy searching and things
set rtp+=~/.fzf
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>
nnoremap <silent> <Leader>/ :BLines<CR>
nnoremap <silent> <Leader>g :Commits<CR>
nnoremap <silent> <Leader>H :Helptags<CR>
nnoremap <silent> <Leader>hh :History<CR>
nnoremap <silent> <Leader>h: :History:<CR>
nnoremap <silent> <Leader>h/ :History/<CR>

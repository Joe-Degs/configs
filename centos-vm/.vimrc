"set nocompatible
set number
syntax on
set ruler
set encoding=utf-8
set fileencoding=utf-8
set colorcolumn=80

" whitespace and filetypes
set wrap
set textwidth=80
set formatoptions=tcqrn1
autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd Filetype c setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8
autocmd Filetype go setlocal tabstop=4 shiftwidth=4 softtabstop=4
set tabstop=4 
set softtabstop=4
set shiftwidth=4
set expandtab
set noshiftround
set noswapfile
"set undodir
"set undodir=~/.vim/undodir
filetype plugin indent on

" Cursor motion
set backspace=eol,start,indent
"set scrolloff
set ttyfast
"set showmode
"set showcmd

" golang configs
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1

" use generics in peace without gofmt bitching about it every second
let g:go_fmt_fail_silently = 0

" sane splits and resizing
set splitright
set splitbelow
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-[> :resize +5<cr>
nnoremap <C-\> :resize -5<cr>


" Decent wildmenu
set wildmenu
set wildmode=list:longest
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor

nnoremap / /\v
vnoremap / /\v
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" colorscheme
set t_Co=256
set background=dark
colo desert

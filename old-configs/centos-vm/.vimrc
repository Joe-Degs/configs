"set nocompatible
set number
syntax on
set ruler
set title
set encoding=utf-8
set fileencoding=utf-8
set colorcolumn=80
set relativenumber

" whitespace and filetypes
set wrap
set textwidth=80
set formatoptions=tcqrn1
autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd Filetype c setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab cindent cc=80
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
"let g:go_fmt_fail_silently = 0

" sane splits and resizing
set splitright
set splitbelow
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
"nnoremap <C-[> :resize +5<cr>
"nnoremap <C-\> :resize -5<cr>


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
colo pablo

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

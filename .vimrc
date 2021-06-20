"set nocompatible
set number
syntax on
set ruler
set encoding=utf-8
set fileencoding=utf-8

" whitespace and filetypes
set wrap
set textwidth=80
set formatoptions=tcqrn1
autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd Filetype go setlocal tabstop=4 shiftwidth=4 softtabstop=4
set shiftwidth=4
set expandtab
set noshiftround
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

" nerdtree specific commands
:nnoremap <C-g> :NERDTreeToggle<CR>

" search
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

" gruvbox colorscheme configs
"autocmd vimenter * ++nested colorscheme gruvbox
colo desert

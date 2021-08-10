set number

" Change how vim represents characters on the screen
set encoding=utf-8

autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd Filetype go setlocal tabstop=4 shiftwidth=4 softtabstop=4
" Control all other files
set shiftwidth=8
set tabstop=8
set softtabstop=8
set noexpandtab


" Hardcore mode, disable arrow keys.
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Allow backspace to delete indentation and inserted text
set backspace=indent,eol,start

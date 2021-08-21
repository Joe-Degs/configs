set number

" Change how vim represents characters on the screen
set encoding=utf-8


" Control all other files
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" from the kernel guidelines.
autocmd Filetype c setlocal shiftwidth=8 tabstop=8 softtabstop=8 noexpandtab

" Hardcore mode, disable arrow keys.
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Allow backspace to delete indentation and inserted text
set backspace=indent,eol,start

" basic editor settings
syntax on
set ruler
set encoding=utf-8
set fileencoding=utf-8
set number
set clipboard^=unnamed,unnamedplus
set scrolloff=10


" vim plugin that first caught mon eyes https://jdhao.github.io/2018/11/15/neovim_configuration_windows/
" most of the config is copy pasta from https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim
" because i find it hard to think for myself.
call plug#begin('~/.config/nvim/plugged')

" Load plugins
" VIM enhancements
Plug 'ciaranm/securemodelines'
Plug 'editorconfig/editorconfig-vim'
Plug 'justinmk/vim-sneak'

" autopairs
Plug 'jiangmiao/auto-pairs'

" colorscheme
Plug 'chriskempson/base16-vim'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'

" Fuzzy finder
Plug 'airblade/vim-rooter'

" Syntactic language support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'rhysd/vim-clang-format'
Plug 'fatih/vim-go'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

"because long yaml files hurt brain
Plug 'Yggdroot/indentLine'

" solidity for smart contracts
Plug 'TovarishFin/vim-solidity'
call plug#end()

" Base 16 colorscheme
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard


" rust
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" golang
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
let g:go_bin_path = expand("~/go/bin")

" yaml
autocmd Filetype yaml let b:indentLine_char = '¦'

" vim signify
set updatetime=100

" =============================================================================
" # Editor settings
" =============================================================================
filetype plugin indent on
set autoindent
set timeoutlen=300 " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set encoding=utf-8
set scrolloff=2
set noshowmode
set hidden
set nowrap
set noswapfile
set nojoinspaces
let g:sneak#s_next = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_frontmatter = 1
set printfont=:h10
set printencoding=utf-8
set printoptions=paper:letter
" Always draw sign column. Prevent buffer moving when adding/deleting sign.
set signcolumn=yes

" Sane splits
set splitright
set splitbelow
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Permanent undo
set undodir=~/.vimdid
set undofile

" hardcore mode - disable arrow keys
noremap <UP> <NOP>
noremap <DOWN> <NOP>
noremap <RIGHT> <NOP>
noremap <LEFT> <NOP>

" Decent wildmenu
set wildmenu
set wildmode=list:longest
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor

" Use wide tabs
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
filetype plugin indent on

" linux kernel dev configs.
autocmd Filetype c setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab

" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines

" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
"nnoremap <C-]> :Sex<cr>
"vnoremap <C-]> :Sex<cr>

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault
set nohlsearch

" Ctrl+h to stop searching
"vnoremap <C-h> :nohlsearch<cr>
"nnoremap <C-h> :nohlsearch<cr>

" Suspend with Ctrl+f
inoremap <C-f> :sus<cr>
vnoremap <C-f> :sus<cr>
nnoremap <C-f> :sus<cr>

" Telescope:
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" disable telescope for some finding for some files
:lua require('telescope').setup{ defaults = { file_ignore_patterns = { "node_modules", ".git", "__pycache__", "Lib", "Scripts" } } }

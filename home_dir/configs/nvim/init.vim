set number           " Show line numbers
set relativenumber   " Show relative numbers (great for jumping: '10j' to go down 10 lines)
set cursorline       " Highlight the current line
set showcmd          " Show partial commands in the bottom line
set laststatus=2     " Always show the status bar
set mouse=a          " Enable mouse support for scrolling/resizing


set hlsearch         " Highlight all search results
set incsearch        " Highlight as you type your search
set smartcase        " ...unless you use a capital letter


set expandtab        " Convert tabs to spaces
set shiftwidth=4     " Number of spaces for auto-indent
set tabstop=4        " Number of spaces a <Tab> counts for
set smartindent      " Do smart auto-indenting when starting a new line

set clipboard=unnamedplus

set undodir=~/.vim/undodir
set undofile

call plug#begin()
    Plug 'scrooloose/nerdtree'        " File explorer
    Plug 'tpope/vim-surround'       " Quoting/parenthesizing made simple
    Plug 'tpope/vim-commentary'  " Toggle comments
    Plug 'justinmk/vim-snipe'    " 2-character search/jum
call plug#end()

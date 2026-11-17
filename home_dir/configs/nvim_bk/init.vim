set number           " Show line numbers
set relativenumber   " Show relative numbers (great for jumping: '10j' to go down 10 lines)
set cursorline       " Highlight the current line
set showcmd          " Show partial commands in the bottom line
set laststatus=2     " Always show the status bar
set mouse=a          " Enable mouse support for scrolling/resizing
set ff=unix

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
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-commentary'  " Toggle comments
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
call plug#end()

nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")

nnoremap <C-m> I- <Esc>
vnoremap <C-m> :norm I- <Esc>

vnoremap <C-t> :s/\v[.;]\s*\r?$//e<CR>
vnoremap <C-b> :s/\v^- \zs([^.:;]*[.:;])/**\1**/e<CR>
" nnoremap j jzz
" nnoremap k kzz

vmap s S

let g:VM_mouse_mappings = 1
let g:surround_{char2nr('b')} = "**\r**"

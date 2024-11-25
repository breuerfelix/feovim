"
" NATIVE CONFIG
"

"mappings
let mapleader = ' '
let maplocalleader = '\\'
inoremap jk <Esc>

"file handling
nmap <silent> <C-e> :q<CR>
nmap <silent> <C-y> :update<CR>

"jump back to and forth
noremap <leader>o <C-o>zz
noremap <leader>i <C-i>zz

"removes any highlight group
nmap <leader>ln :noh<CR>
"prints path of current file
nmap <leader>lp :echo expand('%:p')<CR>

"buffer TODO find new ones
"nmap <C-n> :bnext<CR>
"nmap <C-p> :bprevious<CR>
"nmap <C-y> :bdelete<CR>

"save
set autowrite
set autowriteall

"save undo / redo across sessions
set undofile
set undodir=~/.vim/undo

"splits
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr())
    if (match(a:key,'[jk]'))
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction

noremap <silent> <C-h> :call WinMove('h')<CR>
noremap <silent> <C-j> :call WinMove('j')<CR>
noremap <silent> <C-k> :call WinMove('k')<CR>
noremap <silent> <C-l> :call WinMove('l')<CR>

"signcolumn
set timeoutlen=300
set signcolumn=yes

" TODO remove since auto detected
"true colors
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"batch ui updates
set termsync
" TODO stop remove

"vim update delay in ms
set updatetime=250

"useful for resizing panes
set mouse=a

"syntax
syntax on

"is not useful in screenshare
"use :set number to disable
set number relativenumber

set autoread
set encoding=UTF-8
"set foldmethod=syntax

"uses system clipboard
set clipboard=unnamedplus

"toggle invisible characters
"set list
"set listchars=tab:→\ ,eol:¬,trail:~,extends:❯,precedes:❮,space:␣
"set listchars=eol:¬,trail:~,extends:❯,precedes:❮
"set showbreak=↪

"default for vim sleuth
set expandtab
set tabstop=2
set shiftwidth=2

"split
set splitbelow
set splitright

"searching
set ignorecase
set smartcase
set hlsearch

"highlight current line after timeout
set cursorline
set scrolloff=8

"autosave files
augroup save_when_leave
  au BufLeave * silent! wall
augroup END

set hidden
set nobackup
set nowritebackup
set noswapfile

"filetypes
au BufRead,BufNewFile *.libsonnet set filetype=jsonnet

"remove "how to disable mouse" menu
aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-1-

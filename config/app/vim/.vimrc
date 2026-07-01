" ~/.vimrc — minimal pure-vim config, no plugins.
" The universal editor floor for servers/VPS that ship vim/vi but not nvim.
" Mirrors the ethos of nvim-minimal: sane defaults, zero dependencies.

set nocompatible
filetype plugin indent on
syntax on

" Leader
let mapleader = " "
let maplocalleader = " "

" UI
set number
set relativenumber
set cursorline
set signcolumn=yes
set ruler
set laststatus=2
set showcmd
set wildmenu
set mouse=a
if has('termguicolors')
  set termguicolors
endif

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase
nnoremap <silent> <Esc> :nohlsearch<CR>

" Indent / wrap
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set breakindent
set linebreak
set wrap

" Whitespace hints (matches nvim-minimal listchars)
set list
set listchars=tab:»\ ,trail:·,nbsp:␣

" Behaviour
set hidden
set backspace=indent,eol,start
set updatetime=300
set scrolloff=4

" Clipboard: use system clipboard when vim is built with it, else stay local
if has('clipboard')
  set clipboard=unnamedplus
endif

" Persistent undo under ~/.vim/undo (created on demand)
if has('persistent_undo')
  let s:undodir = expand('~/.vim/undo')
  if !isdirectory(s:undodir)
    call mkdir(s:undodir, 'p', 0700)
  endif
  let &undodir = s:undodir
  set undofile
endif

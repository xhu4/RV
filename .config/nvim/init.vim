" Use a more POSIX compatible shell for vim
if &shell =~# 'fish$'
  set shell=/usr/bin/zsh
endif

set exrc
set secure
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
set softtabstop=0
set autoindent
set smartindent
set number
set foldlevel=99

syntax enable
filetype on
filetype plugin indent on

let mapleader = " "
inoremap jk <Esc>
inoremap <C-a> <Home>
inoremap <C-e> <End>
noremap H 0
noremap L $
nnoremap ; zA

command Erc split $MYVIMRC
command Src source $MYVIMRC

" Install plug.vim automatically
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !sh -c "curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Plugins
call plug#begin(stdpath('data') . '/plugged')

if exists('g:vscode')
  Plug 'asvetliakov/vim-easymotion'
else
  Plug 'easymotion/vim-easymotion'
endif

Plug 'tpope/vim-surround'
Plug 'chaoren/vim-wordmotion'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'wlemuel/vim-tldr'
Plug 'dag/vim-fish'
Plug 'mileszs/ack.vim'

call plug#end()

" ag for ack.vim
let g:ackprg = 'ag --vimgrep'

" easymotion
map <Leader><Leader> <Plug>(easymotion-prefix)
let g:wordmotion_prefix = '<Leader>'


if !exists('g:vscode')
  set ttyfast
  set wildmenu
else
  " av related
  nnoremap gb <Cmd>call VSCodeNotify('aurora-vscode.jumpToBuild')<CR>
  command Build call VSCodeCall('workbench.action.tasks.runTask', 'build_dbg_program')
  command BuildDebug call VSCodeNotify('workbench.action.tasks.runTask', 'build_program')
  command Test call VsCodeNotify('workbench.action.tasks.runTask', 'Run this test')
  command TestFolder call VSCodeNotify('workbench.action.tasks.runTask', 'Run folder test')
  command Run call VSCodeNotify('workbench.action.tasks.runTask', 'Run this executable')
endif

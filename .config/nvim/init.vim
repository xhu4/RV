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
set textwidth=95

syntax on
filetype on

let mapleader = " "

inoremap jk <Esc>
inoremap <C-a> <Home>
inoremap <C-e> <End>
noremap H 0
noremap L $

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

call plug#end()


" easymotion
map <Leader> <Plug>(easymotion-prefix)
let g:wordmotion_prefix = ','


if !exists('g:vscode')
  set ttyfast
  set wildmenu
else
  " av related
  nnoremap gb <Cmd>call VSCodeNotify('aurora-vscode.jumpToBuild')<CR>
  ab cprt Aurora Innovation, Inc. Proprietary and Confidential. Copyright .<Left>
  command Build call VSCodeNotify('workbench.action.tasks.runTask', 'build_dbg_program')
  command BuildDebug call VsCodeNotify('workbench.action.tasks.runTask', 'build_program')
  command Test call VsCodeNotify('workbench.action.tasks.runTask', 'Run this test')
  command TestFolder call VsCodeNotify('workbench.action.tasks.runTask', 'Run folder test')
  command Run call VsCodeNotify('workbench.action.tasks.runTask', 'Run this executable')
endif

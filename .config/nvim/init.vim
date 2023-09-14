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
noremap <C-_> :Commentary<CR>

command Erc e $MYVIMRC
command Src source $MYVIMRC

" Install plug.vim automatically
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !sh -c "curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Plugins
function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

call plug#begin(stdpath('data') . '/plugged')

Plug 'asvetliakov/vim-easymotion', Cond(exists('g:vscode'))
Plug 'easymotion/vim-easymotion', Cond(!exists('g:vscode'), { 'as': 'vsc-easymotion' })
Plug 'tpope/vim-surround'
Plug 'chaoren/vim-wordmotion'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
" Plug 'wlemuel/vim-tldr'
Plug 'dag/vim-fish'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-commentary'

call plug#end()

" ag for ack.vim
let g:ackprg = 'ag --vimgrep'

" easymotion
map ; <Plug>(easymotion-prefix)
let g:wordmotion_prefix = '<Leader>'

" surround
autocmd FileType cpp
      \ let b:surround_{char2nr("c")} ="CHECKED_RESULT(\r)" |
      \ let b:surround_{char2nr("C")} ="CHECK_STATUS_OK(\r)" |
      \ let b:surround_{char2nr("r")} ="RETURN_OR_ASSIGN(\r)" |
      \ let b:surround_{char2nr("R")} ="RETURN_IF_NOT_OK(\r)" |
      \ let b:surround_{char2nr("n")} ="CONTINUE_OR_ASSIGN(\r)" |
      \ let b:surround_{char2nr("N")} ="CONTINUE_IF_NOT_OK(\r)" 

if !exists('g:vscode')
  set ttyfast
  set wildmenu
else
  nnoremap gb <Cmd>call VSCodeNotify('aurora-vscode.jumpToBuild')<CR>
  nnoremap gz <Cmd>call VSCodeNotify('workbench.action.toggleZenMode')<CR>
endif

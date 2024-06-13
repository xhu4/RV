" Vim compiler file
" Compiler:		tidybatch
" Maintainer:	Emile van Raaij (eraaij@xs4all.nl)
" Last Change:	2004 Mar 27
"		2024 Apr 03 by The Vim Project (removed :CompilerSet definition)

if exists("current_compiler")
  finish
endif
let current_compiler = "tidybatch"

" default make
CompilerSet makeprg=bazel

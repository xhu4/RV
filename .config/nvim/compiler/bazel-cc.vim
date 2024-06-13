" Vim compiler file
" Compiler:		Bazel
" Maintainer:	Emile van Raaij (eraaij@xs4all.nl)
" Last Change:	2004 Mar 27
"		2024 Apr 03 by The Vim Project (removed :CompilerSet definition)

if exists("current_compiler")
  finish
endif
let current_compiler = "bazel-cc"

" A workable errorformat for Borland C
CompilerSet errorformat="%f:%l:%c: %t%m"

" default make
CompilerSet makeprg=bazel

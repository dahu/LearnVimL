" Vim syntax plugin.
" Language:	lvlindex
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Syntax for LearnVimL index.
" Last Change:	2014-01-18
" License:	Vim License (see :help license)
" Location:	syntax/lvlindex.vim
" Website:	https://github.com/dahu/LearnVimL
"
" See learnviml.txt for help. This can be accessed by doing:
"
" :help learnviml.txt

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

setl conceallevel=2

syn match LVLOdd /^+ .*$/ nextgroup=LVLEven
syn match LVLEven /^* .*$/ nextgroup=LVLOdd
syn match LVLHeader /^\%1l.*/ nextgroup=LVLLine
syn match LVLLine /^\%2l----\n/ nextgroup=LVLOdd
syn match LVLMarker /^[+*]/ contained containedin=LVLOdd,LVLEven conceal cchar=-

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi link LVLOdd    String
hi link LVLEven   Normal
hi link LVLLine   Comment
hi link LVLHeader Statement
hi link LVLMarker Identifier

let b:current_syntax = "lvlindex"

let &cpo = s:save_cpo
unlet s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:

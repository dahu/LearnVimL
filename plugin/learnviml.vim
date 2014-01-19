" Vim global plugin for LearnVimL recipes.
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Description:	Manage LearnVimL recipes.
" Last Change:	2014-01-18
" License:	Vim License (see :help license)
" Location:	plugin/learnviml.vim
" Website:	https://github.com/dahu/LearnVimL
"
" See learnviml.txt for help.  This can be accessed by doing:
" :help learnviml.txt

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" load guard
"if exists("g:loaded_learnviml")
"      \ || v:version < 700
"      \ || v:version == 703 && !has('patch338')
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
"let g:loaded_learnviml = 1

let s:basedir = expand('<sfile>:p:h:h')

" Options: {{{1
" "learnviml_vert_index" Open Index window in a vertical split when 1.
" "learnvim_vert_recipe" Open Recipe window in a vertical split when 1.

" Private Functions: {{{1

function! s:switch_to(name, ...)
  let prefix = 'LearnVimL_'
  let name = prefix . a:name
  let bufnr = bufnr(name)
  let winnr = bufwinnr(bufnr)
  unsilent echom a:name . ': ' . a:0 ? a:1 : ''
  let dir = a:0 && a:1 ? 'v' : ''
  if bufnr == -1
    exec dir . 'new ' . name
  elseif winnr == winnr()
    " It's weird to be here. Just stay in this window and don't move.
  elseif winnr > -1
    exec winnr . "wincmd w"
  else
    exec dir . "split | buffer " . bufnr
  endif
endfunction

function! s:read_recipes()
  let recipes = []
  for file in glob(s:basedir . '/sample/**/*.vim', 0, 1)
    if filereadable(file)
      call extend(recipes, readfile(file))
    endif
  endfor
  return recipes
endfunction

function! s:parse_recipe() range
  let title = substitute(getline(a:firstline), '^"=\+\s*', '', '')
  let body  = getline(a:firstline + 1, a:lastline)
  call extend(s:recipes, {title : body})
endfunction

function! s:handle_index_cursor()
  if line('.') < 3
    3
  endif
  if col('.') < 3
    normal! 3|
  endif
  if s:index_line != line('.')
    let s:index_line = line('.')
    call s:get_recipe(getline('.'))
    call s:switch_to('Index')
  endif
endfunction

function! s:get_index(pat)
  let s:recipes = {}
  let s:index_line = 0
  call s:switch_to('Index', get(g:, 'learnviml_vert_index', 0))
  setl modifiable
  let saved_lazyredraw = &lazyredraw
  set lazyredraw
  augroup LearnVimL
    au!
  augroup END
  %delete _
  call setline(1, s:read_recipes())
  let delim = '"=\{4}\s*'
  let pat = '^' . delim . '\%(.*\n\%(' . delim . '\)\@!\)\{-1,}.\{-}\zs'
        \ . escape(a:pat, '/')
  let cmd = printf('g/%s/ .;/^%s/-1 call s:parse_recipe()', pat, delim)
  " TODO this could be faster but we need a bigger sample to test if it is
  " even needed.
  "let pat = '^\%(' . delim . '\)\@!.\{-}' . escape(a:pat, '/')
  "let cmd = printf('g/%s/ ?^%s?;/^%s/-1 call s:parse_recipe()',
  "      \ pat, delim, delim)
  exec cmd
  %delete _
  let index = keys(s:recipes)
  if empty(index)
    let header = ['No recipe matched the given pattern: ' . a:pat, '----']
    let index = ['']
  else
    let header = ['Press Enter to go to the code of the current item.', '----']
    let index = map(index, '(v:key % 2 ? "+ " : "* ") . v:val')
  endif
  call setline(1, header + index)
  setl nomodifiable
  au LearnVimL CursorMoved <buffer> call s:handle_index_cursor()
  if empty(&buftype)
    " One-time setup
    exec 'nnore <silent><buffer><CR> :<C-U>call s:get_recipe(getline("."))<CR>'
    setl buftype=nofile ft=lvlindex noswapfile undolevels=100
  endif
  let &lazyredraw = saved_lazyredraw
  redraw
endfunction

function! s:get_recipe(title)
  let saved_lazyredraw = &lazyredraw
  set lazyredraw
  call s:switch_to('Recipe', get(g:, 'learnviml_vert_recipe', 0))
  %delete _
  let title = substitute(a:title, '^[+*]\s\+', '', '')
  let recipe = copy(get(s:recipes, title, []))
  if !empty(recipe)
    call insert(recipe, '" ' . title)
    call setline(1, recipe)
  endif
  if &swapfile
    " One-time setup.
    setl noswapfile ft=vim
  endif
  silent write
  let &lazyredraw = saved_lazyredraw
  redraw
endfunction

function! s:close_lvl()
  for name in ['Recipe', 'Index']
    call s:switch_to(name)
    close
  endfor
endfunction

" Public Interface: {{{1

" Commands: {{{1
command! -nargs=+ LVL silent call s:get_index(<q-args>)
command! LVLClose call s:close_lvl()
" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:

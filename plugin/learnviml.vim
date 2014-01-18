let s:basedir = expand('<sfile>:p:h:h')
let s:tmpname = get(s:, 'tmpname', tempname())
if !isdirectory(s:tmpname)
  call mkdir(s:tmpname)
endif

function! Switch(name)
  let prefix = (a:name == 'Recipe' ? s:tmpname.'/' : '') . 'LearnVimL_'
  let name = prefix . a:name
  let bufnr = bufnr(name)
  let winnr = bufwinnr(bufnr)
  if bufnr == -1
    exec 'new ' . name
  elseif winnr == winnr()
    " It's weird to be here. Just stay in this window and don't move.
  elseif winnr > -1
    exec winnr . "wincmd w"
  else
    split
    exec "buffer " . bufnr
  endif
endfunction

function! ResetIndex(pat)
  setl modifiable
  %delete _
  call setline(1, readfile(s:basedir . '/sample/recipe.vim'))
  let delimiter = '\m^"=\{4}'
  let pat = escape(a:pat, '/')
  let get_cmd = '?' . delimiter . '?;/' . delimiter . '/-1 call ParseRecipe()'
  let cmd = printf('g/%s/ %s', pat, get_cmd)
  exec cmd
  %delete _
  let header = ['Press Enter to go to the code of the current item.', '----']
  let index = map(keys(s:recipes), '(v:key % 2 ? "+ " : "* ") . v:val')
  echom string(index)
  call setline(1, header + index)
  setl nomodifiable
  if exists('s:index_setup')
    return
  endif
  let s:index_setup = 1
  augroup LearnVimL
    au!
    au CursorMoved <buffer> call HandleIndexCursor()
  augroup END
  exec 'nnore <silent><buffer><CR> :<C-U>call GetRecipe(getline("."))<CR>'
  setl buftype=nofile
  syn clear
  syn match LVLOdd /^+ .*$/ nextgroup=LVLEven
  syn match LVLEven /^* .*$/ nextgroup=LVLOdd
  syn match LVLHeader /^\%1l.*/ nextgroup=LVLLine
  syn match LVLLine /^\%2l----\n/ nextgroup=LVLOdd
  hi link LVLOdd    String
  hi link LVLEven   Normal
  hi link LVLLine   Comment
  hi link LVLHeader Statement
endfunction

function! ParseRecipe() range
  let title = substitute(getline(a:firstline), '^"=\+\s*', '', '')
  let body  = getline(a:firstline + 1, a:lastline)
  call extend(s:recipes, {title : body})
endfunction

function! GetIndex(pat)
  let s:recipes = {}
  let s:index_line = 0
  " Reset Recipes' window
  call GetRecipe(get(keys(s:recipes), 0, ''))
  call Switch('Index')
  call ResetIndex(a:pat)
endfunction

function! SetupIndex()
  if get(s:, 'index_setup', 1)
    return
  endif
  let s:index_setup = 1
  augroup LearnVimL
    au!
    au CursorMoved <buffer> call HandleIndexCursor()
  augroup END
  exec 'nnore <silent><buffer><CR> :<C-U>call GetRecipe(getline("."))<CR>'
  setl buftype=nofile nomodifiable
endfunction

function! HandleIndexCursor()
  if line('.') < 3
    3
  endif
  if s:index_line != line('.')
    let s:index_line = line('.')
    call GetRecipe(getline('.'))
    call Switch('Index')
  endif
endfunction

function! GetRecipe(title)
  call Switch('Recipe')
  %delete _
  let title = substitute(a:title, '^[+*]\s\+', '', '')
  let recipe = copy(get(s:recipes, title, []))
  if empty(recipe)
    " Do something
    return
  endif
  call insert(recipe, '" ' . title)
  call setline(1, recipe)
  setfiletype vim
  silent write
endfunction

command! -nargs=+ LVL call GetIndex(<q-args>)

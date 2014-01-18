let s:basedir = expand('<sfile>:p:h:h')

function! Switch(name)
  let prefix = 'LVL_'
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

function! Init(pat)
  %delete _
  call setline(1, readfile(s:basedir . '/sample/recipe.vim'))
  let delimiter = '\m^"=\{4}'
  let pat = escape(a:pat, '/')
  let get_cmd = '?' . delimiter . '?;/' . delimiter . '/-1 call ParseRecipe()'
  let cmd = printf('g/%s/ %s', pat, get_cmd)
  exec cmd
  %delete _
  call setline(1, keys(s:recipes))
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
  "call GetRecipe(get(keys(s:recipes), 0, ''))
  call Switch('index')
  call Init(a:pat)
  set buftype=nofile
  "augroup LearnVimL
  "  au!
  "  au CursorMoved <buffer>
  "        \ if s:index_line != line('.')   |
  "        \   call GetRecipe(getline('.')) |
  "        \   let s:index_line = line('.') |
  "        \   call Switch('index')         |
  "        \ endif
  "augroup END
  exec 'nnore <silent><buffer><CR> :<C-U>call GetRecipe(getline("."))<CR>'
endfunction

function! GetRecipe(title)
  call Switch('recipe')
  %delete _
  let recipe = get(s:recipes, a:title, [])
  if empty(recipe)
    " Do something
    return
  endif
  call insert(recipe, '" ' . a:title)
  call setline(1, recipe)
  setfiletype vim
  set buftype=nofile
endfunction

command! -nargs=+ LVL call GetIndex(<q-args>)

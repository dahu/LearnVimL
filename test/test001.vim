command! -nargs=+ Cursor call cursor(<f-args>) | doau CursorMoved <buffer>

call vimtest#StartTap()
TapPlan 13
call setline(1, 'let x = 1')
LVL set
Cursor 1 1
TapIs winnr('$'), 3, 'We have three windows.'
TapOk bufwinnr('LearnVimL_Index') > 0, 'Index is present.'
TapOk bufwinnr('LearnVimL_Recipe') > 0, 'Recipe is present.'
TapOk !empty(getline(1)), 'The recipe has content.'
TapIs winnr(), bufwinnr('LearnVimL_Index'), 'Current window is LearnVimL_Index.'
Cursor 1 1
TapIs line('.'), 3, 'The cursor can not go onto the heading.'
Cursor 3 1
TapIs col('.'), 3, 'The cursor can not go onto the list markers.'
TapOk line('$') > 2, 'There is one recipe at least.'
exec "normal! \<CR>"
TapOk line('$') > 2, 'We have a recipe.'
let line1 = getline(1)
wincmd p
Cursor 4 3
wincmd p
let line2 = getline(1)
TapOk line1 == line2 && !empty(line2), 'The recipe was updated on CursorMoved.'
wincmd p
Cursor 3 3
exec "normal! \<CR>"
TapIsnt getline(1), line2, 'The recipe changed on CR.'
let lines1 = getline(1,'$')
LVL let
let lines2 = getline(1,'$')
TapOk lines1 != lines2, 'The index changed on :LVL let.'
" Test "sourceabililty", this must be the last test because the window layout
" and contents can change in unexpected ways.
wincmd p
let v:errmsg = ''
source %
TapOk empty(v:errmsg,), 'Sourcing the recipe works.'
call vimtest#Quit()

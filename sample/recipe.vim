"==== Use a default value if variable does not exists.
" See :help internal-variables.
let foo = get(g:, 'bar', 1)
"==== Switch a boolean option.
set wrap!
set invhlsearch
"==== Set a complicated option
set formatlistpat=^\\s\\d\\.\\s\\+
" is better written as
let &formatlistpat = '^\s\d\.\s\+'
" on the command-line, use:   :let &flp = <c-r>=string(&flp)
"==== Show the value of an option.
set formatoptions?
echo &formatoptions
"==== Apply custom highlighting to echoed text.
echohl WarningMsg
echom 'Some error happened. Please forgive me, I did not mean it.'
echohl None
"==== This is the end.

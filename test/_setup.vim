let &rtp = expand('<sfile>:p:h:h') . ',' . &rtp . ',' . expand('<sfile>:p:h:h') . '/after'
runtime plugin/learnviml.vim
for fn in ['Plan', 'Ok', 'Is', 'Isnt', 'Like', 'Unlike', 'Pass', 'Fail',
      \ 'Diag', 'Skip', 'Todo', 'Bailout', 'SetOutputFile']
  exec 'command! -nargs=* Tap' . fn . ' call vimtap#' . fn .'(<args>)'
endfor

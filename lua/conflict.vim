function! ConflictsHighlight() abort
    " https://github.com/jsit/conflict-syntax.vim/blob/master/syntax/conflict.vim
    syn region conflict start="^<<<<<<<.*$" end="^>>>>>>>.*$" keepend contains=DiffAdd,conflictCommon,DiffText

    syn region DiffAdd start="^<<<<<<<.*$" end="^|||||||\|=======$"me=e-7 keepend contains=conflictMarker
    syn region conflictCommon start="^|||||||.*$" end="^=======$"me=e-7 keepend contains=conflictMarker
    syn region DiffText start="^=======" end="^>>>>>>>.*$" keepend contains=conflictMarker

    syn match conflictMarker "^\(<<<<<<<.*\||||||||.*\|>>>>>>>.*\|=======\)$" contained
endfunction
augroup MyColors
    autocmd!
    autocmd BufEnter * call ConflictsHighlight()
    autocmd BufWinEnter * call ConflictsHighlight()
    autocmd BufAdd * call ConflictsHighlight()
    autocmd BufNew * call ConflictsHighlight()
augroup END


setlocal formatoptions+=t       " Autowrap text when over tw.
setlocal spell

" TODO have added the dhruvasagar/vim-table-mode plugin. Which is best?
" call the :Tabularize command each time you insert a | character.
if exists(":Tabularize")
  function! s:align()
    let p = '^\s*|\s.*\s|\s*$'
    if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
      let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
      let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
      Tabularize/|/l1
      normal! 0
      call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
    endif
  endfunction

  inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
endif

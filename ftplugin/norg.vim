if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

setlocal spell foldtext=foldtext()

if len(maparg('<Leader>N', 'n')) != 0
    nunmap <Leader>N
endif

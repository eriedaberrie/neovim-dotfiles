if exists("b:did_ftplugin") || exists('g:vscode') || exists('g:started_')
    finish
endif
let b:did_ftplugin = 1

setlocal spell spelloptions=camel foldtext=foldtext()

if len(maparg('<Leader>N', 'n')) != 0
    nunmap <Leader>N
endif

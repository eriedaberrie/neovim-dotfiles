if exists("b:did_ftplugin") || exists('g:vscode') || exists('g:started_')
    finish
endif
let b:did_ftplugin = 1

setlocal spell foldtext=foldtext()

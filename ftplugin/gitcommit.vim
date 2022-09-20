if exists("b:did_ftplugin") || exists('g:started_by_firenvim')
    finish
endif
let b:did_ftplugin = 1

setlocal spell foldtext=foldtext()

if exists("b:did_ftplugin") || exists('g:vscode') || exists('g:started_by_firenvim')
    finish
endif
let b:did_ftplugin = 1

setlocal spell foldtext=foldtext()

" remove noplainbuffer from spell options (set from treesitter)
lua vim.schedule(function () vim.opt_local.spelloptions:remove('noplainbuffer') end)

if len(maparg('<Leader>N', 'n')) != 0
    nunmap <Leader>N
endif

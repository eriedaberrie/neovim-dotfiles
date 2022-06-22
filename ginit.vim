" Neovim-QT initializiation

" ctrl-tab stuff
nnoremap <silent> <c-tab> <Cmd>bn<enter>
nnoremap <silent> <c-s-tab> <Cmd>bN<enter>

" Enable Mouse
set mouse=a

" Enable Gui Ligatures
if exists(':GuiRenderLigatures')
    GuiRenderLigatures 1
endif

" Enable Gui Font
if exists(':GuiFont')
    GuiFont! FiraCode Nerd Font Mono:h10
endif

" Disable GUI Tabline
if exists(':GuiTabline')
    GuiTabline 0
endif

" Disable GUI Popupmenu
if exists(':GuiPopupmenu')
    GuiPopupmenu 0
endif

" Disable GUI ScrollBar
if exists(':GuiScrollBar')
    GuiScrollBar 0
endif

" Right Click Context Menu (Copy-Cut-Paste)
if exists('*GuiShowContextMenu')
    nnoremap <silent><RightMouse> <Cmd>call GuiShowContextMenu()<CR>
    inoremap <silent><RightMouse> <Cmd>call GuiShowContextMenu()<CR>
    xnoremap <silent><RightMouse> <Cmd>call GuiShowContextMenu()<CR>
    snoremap <silent><RightMouse> <Cmd>call GuiShowContextMenu()<CR>
endif

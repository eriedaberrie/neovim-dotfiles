-- Keymaps
-- Nonrecursive and silent is assumed unless otherwise specified

-- Flags:
-- 0b0001 - default
-- 0b0010 - Unix
-- 0b0100 - VSCode plugin
-- 0b1000 - Firenvim

return {
    -- 0b0001
    [1] = function (map)
        -- Open RPG maker game in debug mode
        map. n ([[<Leader>pd]], [[&shell ==# 'cmd.exe' ? '<Cmd>!for /f "usebackq tokens=*" \%a in (`git rev-parse --show-toplevel`) do start /d "\%a" Game.exe debug<CR><CR>' : '<Cmd>!start -FilePath Game.exe -WorkingDirectory "$(git rev-parse --show-toplevel)" -ArgumentList "debug"<CR><CR>']], { expr = true })

        -- Don't accidentaly permanently suspend in Windows
        map. n ([[<C-z>]], [[<Nop>]])
    end,

    -- 0b0010
    [2] = function (map)
    end,

    -- 0b0011
    [3] = function (map)
        -- :PackerSync
        map. n ([[<Leader>ps]], [[:PackerSync<CR>]], { silent = false })

        -- Reload impatient.nvim cache
        map. n ([[<Leader>I]], [[:LuaCacheClear<CR>]], { silent = false })

        -- Lazygit maps
        map. n ([[<Leader>gg]], require'lazygit'.lazygit)
        map. n ([[<Leader>fl]], require'telescope._extensions'.manager.lazygit.lazygit)

        -- Debugging
        local dap = require'dap'
        local dapui = require'dapui'
        map. n ([[<Leader>D]],  dap.continue)
        map. n ([[<Leader>dr]], dap.repl.toggle)
        map. n ([[<Leader>dd]], dap.toggle_breakpoint)
        map. n ([[<Leader>ds]], dap.step_into)
        map. n ([[<Leader>do]], dap.step_over)
        map. n ([[<Leader>dg]], function () dap.goto_(vim.v.count ~= 0 and vim.v.count) end)
        map. n ([[<Leader>dO]], dap.step_out)
        map. n ([[<Leader>dB]], dap.step_back)
        map. n ([[<Leader>dT]], dap.terminate)
        map. n ([[<Leader>dD]], dap.disconnect)
        map. n ([[<Leader>dC]], dap.close)
        map. n ([[<Leader>dU]],  dapui.toggle)
        map. n ([[<Leader>duu]], dapui.toggle)
        map. n ([[<Leader>duf]], dapui.float_element)
        map. nx ([[<Leader>due]], dapui.eval)
    end,

    -- 0b0100
    [4] = function (map)
        -- Pressing "z=" opens the context menu
        map. n ([[z=]], [[<Cmd>call VSCodeNotify('keyboard-quickfix.openQuickFix')<CR>]])

        -- Do not preserve q: <CR> functionality
        map. n ([[<CR>]], [[<Nop>]])
    end,

    -- 0b1000
    [8] = function (map)
    end,

    -- 0b1011
    [11] = function (map)
        -- Maps Ctrl-Backspace to do the thing
        map. ic ([[<C-BS>]], [[<C-w>]], { silent = false, noremap = false })

        -- Window resize
        map. n ([[+]],     [[<Cmd>exe v:count . 'wincmd +'<CR>]])
        map. n ([[-]],     [[<Cmd>exe v:count . 'wincmd -'<CR>]])
        map. n ([[<M-,>]], [[<Cmd>exe v:count . 'wincmd <'<CR>]])
        map. n ([[<M-.>]], [[<Cmd>exe v:count . 'wincmd >'<CR>]])

        -- Text resize maps
        map. n ([[<Leader>0]], vim.funcs.resizetext)
        map. n ([[<Leader>=]], function () vim.funcs.resizetext(vim.v.count1, 1) end)
        map. n ([[<Leader>-]], function () vim.funcs.resizetext(vim.v.count1, -1) end)

        -- Easy enter terminal mode
        local toggleterm = require'toggleterm'
        map. n ([[<Leader>to]], function () toggleterm.toggle(vim.v.count) end)
        map. n ([[<Leader>th]], function () toggleterm.toggle(vim.v.count, nil, nil, 'horizontal') end)
        map. n ([[<Leader>tv]], function () toggleterm.toggle(vim.v.count, nil, nil, 'vertical') end)
        map. n ([[<Leader>ta]], toggleterm.toggle_all)
        map. n ([[<C-\>h]], function () toggleterm.toggle(vim.v.count, nil, nil, 'horizontal') end)
        map. n ([[<C-\>v]], function () toggleterm.toggle(vim.v.count, nil, nil, 'vertical') end)
        map. n ([[<C-\>a]], toggleterm.toggle_all)

        -- More ToggleTerm maps
        map. n ([[<Leader>ts]], function () toggleterm.send_lines_to_terminal('single_line', true, { args = vim.v.count }) end)
        map. x ([[<Leader>ts]], function () toggleterm.send_lines_to_terminal('visual_lines', true, { args = vim.v.count }) end)
        map. x ([[<Leader>tS]], function () toggleterm.send_lines_to_terminal('visual_selection', true, { args = vim.v.count }) end)
        map. n ([[<C-\>s]], function () toggleterm.send_lines_to_terminal('single_line', true, { args = vim.v.count }) end)
        map. x ([[<C-\>s]], function () toggleterm.send_lines_to_terminal('visual_lines', true, { args = vim.v.count }) end)
        map. x ([[<C-\>S]], function () toggleterm.send_lines_to_terminal('visual_selection', true, { args = vim.v.count }) end)

        -- Easy exit terminal mode
        map. t ([[<C-\><Esc>]],    [[<C-\><C-n>]], { nolazyredraw = true })
        map. t ([[<C-\><Leader>]], [[<C-\><C-n>]], { nolazyredraw = true })

        -- Use alt keys in terminal mode to change window
        map. nt ([[<M-h>]], [[<Cmd>exe v:count . 'wincmd h'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-j>]], [[<Cmd>exe v:count . 'wincmd j'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-k>]], [[<Cmd>exe v:count . 'wincmd k'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-l>]], [[<Cmd>exe v:count . 'wincmd l'<CR>]], { nolazyredraw = true })

        -- Close help page easily
        map. n ([[<Leader>hc]], [[<Cmd>helpclose<CR>]])

        -- Loclist and Quickfixlist toggles
        map. n ([[<Leader>lo]], [[<Cmd>lopen<CR>]])
        map. n ([[<Leader>lc]], [[<Cmd>lclose<CR>]])
        map. n ([[<Leader>co]], [[<Cmd>copen<CR>]])
        map. n ([[<Leader>cc]], [[<Cmd>cclose<CR>]])
        map. nx ([[<Leader>ln]], [[<Cmd>lnext<CR>]])
        map. nx ([[<Leader>lp]], [[<Cmd>lprev<CR>]])
        map. nx ([[<Leader>cn]], [[<Cmd>cnext<CR>]])
        map. nx ([[<Leader>cp]], [[<Cmd>cprev<CR>]])

        -- LSP maps
        map. n ([[<Leader>eE]], vim.diagnostic.setloclist)
        -- map. n ([[<Leader>ee]], vim.diagnostic.open_float)
        -- map. n ([[<Leader>el]], vim.diagnostic.goto_next)
        -- map. n ([[<Leader>eh]], vim.diagnostic.goto_prev)
        -- map. n ([[<Leader>ej]], [[$<Cmd>lua vim.diagnostic.goto_next()<CR>]])
        -- map. n ([[<Leader>ek]], [[0<Cmd>lua vim.diagnostic.goto_prev()<CR>]])
        map. n ([[<Leader>eI]], [[<Cmd>LspInfo<CR>]])
        -- map. n ([[<Leader>E]], vim.lsp.buf.hover)
        map. n ([[<Leader>ed]], vim.lsp.buf.definition)
        map. n ([[<Leader>eD]], vim.lsp.buf.declaration)
        map. n ([[<Leader>ei]], vim.lsp.buf.implementation)
        -- map. n ([[<Leader>er]], vim.lsp.buf.rename)
        map. n ([[<Leader>eR]], vim.lsp.buf.references)
        map. n ([[<Leader>et]], vim.lsp.buf.type_definition)
        map. n ([[<Leader>eF]], vim.lsp.buf.format)
        map. x ([[<Leader>eF]], vim.lsp.buf.range_formatting)
        -- map. n ([[<Leader>ec]], vim.lsp.buf.code_action)
        -- map. x ([[<Leader>ec]], vim.lsp.buf.range_code_action)
        -- map. n ([[<Leader>es]], vim.lsp.buf.signature_help)
        map. n ([[<Leader>ew]], vim.lsp.buf.add_workspace_folder)
        map. n ([[<Leader>eW]], vim.lsp.buf.remove_workspace_folder)
        map. n ([[<Leader>e<C-w>]], function () vim.pretty_print(vim.lsp.buf.list_workspace_folders()) end)

        -- Lspsaga maps
        map. n ([[<Leader>E]],  [[<Cmd>Lspsaga hover_doc<CR>]])
        map. n ([[<Leader>ef]], [[<Cmd>Lspsaga lsp_finder<CR>]])
        map. n ([[<Leader>ec]], [[<Cmd>Lspsaga code_action<CR>]])
        map. x ([[<Leader>ec]], [[<Cmd>Lspsaga code_range_action<CR>]])
        map. n ([[<Leader>es]], [[<Cmd>Lspsaga signature_help<CR>]])
        map. n ([[<Leader>ep]], [[<Cmd>Lspsaga preview_definition<CR>]])
        map. n ([[<Leader>ee]], [[<Cmd>Lspsaga show_line_diagnostics<CR>]])
        map. n ([[<Leader>el]], [[<Cmd>Lspsaga diagnostic_jump_next<CR>]])
        map. n ([[<Leader>eh]], [[<Cmd>Lspsaga diagnostic_jump_prev<CR>]])
        map. n ([[<Leader>ej]], [[$<Cmd>Lspsaga diagnostic_jump_next<CR>]])
        map. n ([[<Leader>ek]], [[0<Cmd>Lspsaga diagnostic_jump_prev<CR>]])
        map. n ([[<Leader>er]], [[<Cmd>Lspsaga rename<CR>]])
        local lspsaga_action = require'lspsaga.action'
        map. n ([[<C-f>]], function () lspsaga_action.smart_scroll_with_saga(1) end)
        map. n ([[<C-b>]], function () lspsaga_action.smart_scroll_with_saga(-1) end)

        -- Coq_nvim + nvim-autopairs keymaps
        map. i ([[<Esc>]], [[pumvisible() ? '<C-e><Esc>' : '<Esc>']], { expr = true })
        map. i ([[<C-c>]], [[pumvisible() ? '<C-e><C-c>' : '<C-c>']], { expr = true })
        map. i ([[<Tab>]],   [[pumvisible() ? '<C-n>' : '<Tab>']], { expr = true })
        map. i ([[<S-Tab>]], [[pumvisible() ? '<C-p>' : '<Tab>']], { expr = true })

        -- Toggle whitespace visibility
        map. nx ([[<Leader><Leader>]], [[<Cmd>set list!<CR>]])

        -- Toggles dark/light themes
        map. nx ([[<Leader>tt]], function () vim.funcs.settheme(vim.o.background == 'dark' and 'light' or 'dark') end)

        -- Preserve q: and quickfix <CR> functionality
        map. n ([[<CR>]], [[!(index(['[Command Line]'], expand('%')) is -1) || (&filetype == 'qf') ? '<CR>' : '']], { silent = false, expr = true })

        -- Swap to visual linewise movement (for editing actual paragraphs)
        map. n ([[<Leader>jk]], [[<Cmd>nnoremap j gj<CR><Cmd>nnoremap k gk<CR><Cmd>nnoremap 0 g0<CR><Cmd>nnoremap $ g$<CR>]])

        -- Set cwd to current file directory
        map. n ([[<Leader>cd]], [[<Cmd>tcd %:h<CR>]])

        -- Delete trailing spaces
        map. n ([[<Leader>tr]], [[<Cmd>%s/\s\+$//<Bar>norm!``<CR><Cmd>noh<CR>]])

        -- Delete buffer without closing the current window
        map. n ([[<Leader>bd]], [[<Cmd>bp<Bar>bd#<CR>]])
        map. n ([[<Leader>Bd]], [[<Cmd>bp<Bar>bd!#<CR>]])

        -- Change buffer easily
        map. nt ([[<M-n>]], [[<Cmd>exe v:count . 'bn'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-N>]], [[<Cmd>exe v:count . 'bN'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-p>]], [[<Cmd>exe v:count . 'bp'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-3>]], [[<Cmd>b#<CR>]], { nolazyredraw = true })

        -- Temporarily increase scrolloff
        map. n ([[<Leader>zz]], [['<Cmd>set scrolloff=8<CR><Cmd>set scrolloff=' . &scrolloff . '<CR>']], { expr = true })

        -- Go to misspelled word in insert mode
        map. i ([[<C-z>]], [[<Esc>b[sviw<Esc>a]])
        map. i ([[<C-s>]], [[<Esc>]sviw<Esc>a]])

        -- Telescope maps
        local tele_builtin = require'telescope.builtin'
        local tele_ext = require'telescope._extensions'.manager
        map. n ([[<Leader>fr]], tele_builtin.resume)
        map. n ([[<Leader>ff]], tele_builtin.find_files)
        map. n ([[<Leader>fg]], tele_builtin.live_grep)
        map. n ([[<Leader>fb]], tele_builtin.buffers)
        map. n ([[<Leader>fh]], tele_builtin.help_tags)
        map. n ([[<Leader>fc]], tele_ext.neoclip.neoclip)
        map. n ([[<Leader>fn]], tele_ext.notify.notify)
        map. n ([[<Leader>fH]], tele_ext.howdoi.howdoi)

        -- Open nvim tree without accidentally closing the current tabpage
        map. n ([[<Leader>e.]], [[<Cmd>NvimTreeToggle<CR>]])

        -- Folding in files too large for treesitter
        map. n ([[z%]], [[V%o:fold<CR>]])

        -- Toggle indent-blankline plugin
        map. n ([[<Leader>ib]], [[<Cmd>let g:indent_blankline_enabled = g:indent_blankline_enabled ? v:false : v:true<CR>]])
    end,

    -- 0b1101
    [13] = function (map)
        -- Toggle shell
        map. n ([[<Leader>ss]], vim.funcs.toggleshell)
    end,

    -- 0b1111
    [15] = function (map)
        -- Indent without exiting visual mode
        map. x ([[<]], [[<gv]])
        map. x ([[>]], [[>gv]])

        -- Unmap Backspace, Enter, Space
        map. nx ([[<Bs>]], [[<Nop>]])
        map. nx ([[<Space>]], [[<Nop>]])
        map. x ([[<CR>]], [[<Nop>]])

        -- Pressing Escape cancels search highlights
        map. n ([[<Esc>]], [[<Cmd>noh<CR>]])

        -- Save and close easily
        map. n ([[<Leader>w]], [[<Cmd>w<CR>]])
        map. n ([[<Leader>q]], [[<Cmd>q<CR>]])
        map. n ([[<Leader>Q]], [[<Cmd>qa!<CR>]])

        -- Toggle lazy redraw
        map. n ([[<Leader>lr]], [[<Cmd>set lazyredraw! lazyredraw?<CR>]])

        -- Run previous command with ! prefix
        map. n ([[<Leader>!]], [[:!<C-r>:<CR>]], { silent = false })

        -- Run previous command with lua prefix
        map. n ([[<Leader>lu]], [[:lua <C-r>:<CR>]], { silent = false })

        -- Move around in insert modes with alt
        map. ic ([[<M-h>]], [[<Left>]],  { noremap = false, silent = false })
        map. ic ([[<M-j>]], [[<Down>]],  { noremap = false, silent = false })
        map. ic ([[<M-k>]], [[<Up>]],    { noremap = false, silent = false })
        map. ic ([[<M-l>]], [[<Right>]], { noremap = false, silent = false })

        -- EasyAlign
        map. nx ([[<Leader>ga]], [[<Plug>(EasyAlign)]])

        -- Easy access to clipboard in normal, visual mode
        map. nx ([[<Leader>"]], [["+]])

        -- Swap case of letter
        map. n ([[gl]], [[g~l]])

        -- Copy to clipboard
        map. n ([[<Leader>yy]], [[<Cmd>%y+<CR>]])

        -- Don't move the cursor with insert mode <C-o>
        map. i ([[<C-o>]], [[<C-\><C-o>]], { silent = false })

        -- Current line text object
        map. O ([[il]], [[0o$h]])
        map. O ([[al]], [[(line('.') ==# line('$')) ? 'V' : '0o$']], { expr = true })

        -- Current buffer text object
        map. O ([[i%]], [[V0Gogg]])

        -- Indentation text object
        map. O ([[ii]], function () vim.funcs.selectindent(false) end)
        map. O ([[ai]], function () vim.funcs.selectindent(true) end)
    end,
}

-- Keymaps
-- Nonrecursive and silent is assumed unless otherwise specified

-- Flags:
-- 0b001 - default
-- 0b010 - Unix
-- 0b100 - Firenvim

---@diagnostic disable: unused-local
return {
    -- 0b001
    [1] = function (map, wkreg)
        -- Open RPG maker game in debug mode
        map. n ([[<Leader>pd]], [[&shell ==# 'cmd.exe' ? '<Cmd>!for /f "usebackq tokens=*" \%a in (`git rev-parse --show-toplevel`) do start /d "\%a" Game.exe debug<CR><CR>' : '<Cmd>!start -FilePath Game.exe -WorkingDirectory "$(git rev-parse --show-toplevel)" -ArgumentList "debug"<CR><CR>']], { expr = true }, 'Play RPG maker game in debug mode')

        -- Don't accidentaly permanently suspend in Windows
        map. n ([[<C-z>]], [[<Nop>]])
    end,

    -- 0b010
    [2] = function (map, wkreg)
    end,

    -- 0b011
    [3] = function (map, wkreg)
        -- :PackerSync
        wkreg{ ['<Leader>p'] = { name = 'Packer' } }
        map. n ([[<Leader>ps]], [[:PackerSync<CR>]], { silent = false })

        -- Reload impatient.nvim cache
        map. n ([[<Leader>I]], [[:LuaCacheClear<CR>]], { silent = false })

        -- Lazygit maps
        wkreg{ ['<Leader>g'] = { name = 'Lazygit and EasyAlign' } }
        map. n ([[<Leader>gg]], require'lazygit'.lazygit, 'Toggle lazygit')
        map. n ([[<Leader>fl]], [[<Cmd>Telescope lazygit<CR>]], 'Lazygit')

        -- Debugging
        local dapregtable = {
            ['<Leader>d'] = { name = 'DAP' },
            ['<Leader>du'] = { name = 'Dap-ui' },
        }
        wkreg(dapregtable)
        wkreg(dapregtable, { mode = 'x' })
        local dap = require'dap'
        local dapui = require'dapui'
        map. n ([[<Leader>D]],  dap.continue, 'DAP continue')
        map. n ([[<Leader>dr]], dap.repl.toggle, 'Toggle REPL (use dap-ui instead)')
        map. n ([[<Leader>dd]], dap.toggle_breakpoint, 'Toggle breakpoint')
        map. n ([[<Leader>dl]], vim.funcs.setlogpoint, 'Toggle log point')
        map. n ([[<Leader>ds]], dap.step_into, 'Step into')
        map. n ([[<Leader>do]], dap.step_over, 'Step over')
        map. n ([[<Leader>dg]], function () dap.goto_(vim.v.count ~= 0 and vim.v.count) end, 'Goto')
        map. n ([[<Leader>dO]], dap.step_out, 'Step out')
        map. n ([[<Leader>dB]], dap.step_back, 'Step back')
        map. n ([[<Leader>dT]], dap.terminate, 'Terminate')
        map. n ([[<Leader>dD]], dap.disconnect, 'Disconnect')
        map. n ([[<Leader>dC]], dap.close, 'Close (use terminate instead)')
        map. n ([[<Leader>duu]], dapui.toggle, 'Toggle')
        map. n ([[<Leader>duf]], dapui.float_element, 'Float element')
        map. nx ([[<Leader>due]], dapui.eval, 'Eval')

        -- Start neorg
        map. n ([[<Leader>N]], [[<Cmd>NeorgStart<CR>]])
    end,

    -- 0b100
    [4] = function (map, wkreg)
    end,

    -- 0b101
    [5] = function (map, wkreg)
        -- Toggle shell
        map. n ([[<Leader>S]], vim.funcs.toggleshell, 'Toggle shell between cmd.exe and pwsh.exe')
    end,

    -- 0b111
    [7] = function (map, wkreg)
        -- Unmap Backspace, Enter, Space
        map. nx ([[<Bs>]], [[<Nop>]])
        map. nx ([[<Space>]], [[<Nop>]])
        map. x ([[<CR>]], [[<Nop>]])

        -- Make cw make sense
        map. n ([[cw]], [[dwi]], { virte = true }, 'Next word')
        map. n ([[cW]], [[dWi]], { virte = true }, 'Next Word')

        -- Indent without exiting visual mode
        map. x ([[<]], [[<gv]])
        map. x ([[>]], [[>gv]])

        -- Pressing Escape cancels search highlights
        map. n ([[<Esc>]], [[<Cmd>noh<CR>]])

        -- Save and close easily
        map. n ([[<Leader>w]], [[<Cmd>w<CR>]])
        map. n ([[<Leader>q]], [[<Cmd>q<CR>]])
        map. n ([[<Leader>Q]], [[<Cmd>qa!<CR>]])

        -- Run previous command with ! prefix
        map. n ([[<Leader>!]], [[:!<C-r>:<CR>]], { silent = false }, 'Previous command with ! prefix')

        -- Run previous command with lua prefix
        map. n ([[<Leader>L]], [[:lua <C-r>:<CR>]], { silent = false }, 'Run previous command with lua prefix')

        -- Maps Ctrl-Backspace to do the thing
        map. ic ([[<C-BS>]], [[<C-w>]], { silent = false, noremap = false })

        -- Toggle lazy redraw
        map. n ([[<Leader>lr]], [[<Cmd>set lazyredraw! lazyredraw?<CR>]])

        -- Toggle spell checking
        wkreg{ ['<Leader>s'] = { name = 'Spell' } }
        map. n ([[<Leader>sp]], [[<Cmd>set spell! spell?<CR>]])

        -- Window resize
        map. n ([[+]],     [[<Cmd>exe v:count . 'wincmd +'<CR>]])
        map. n ([[-]],     [[<Cmd>exe v:count . 'wincmd -'<CR>]])
        map. n ([[<M-,>]], [[<Cmd>exe v:count . 'wincmd <'<CR>]])
        map. n ([[<M-.>]], [[<Cmd>exe v:count . 'wincmd >'<CR>]])

        -- Text resize maps
        map. n ([[<Leader>0]], vim.funcs.resizetext, 'Reset text size')
        map. n ([[<Leader>=]], function () vim.funcs.resizetext(vim.v.count1, 1) end, 'Increase text size')
        map. n ([[<Leader>-]], function () vim.funcs.resizetext(vim.v.count1, -1) end, 'Decrease text size')

        -- Move around in insert modes with alt
        map. ic ([[<M-h>]], [[<Left>]],  { noremap = false, silent = false })
        map. ic ([[<M-j>]], [[<Down>]],  { noremap = false, silent = false })
        map. ic ([[<M-k>]], [[<Up>]],    { noremap = false, silent = false })
        map. ic ([[<M-l>]], [[<Right>]], { noremap = false, silent = false })

        -- EasyAlign
        map. nx ([[<Leader>ga]], [[<Plug>(EasyAlign)]], 'Activate EasyAlign')

        -- Easy access to clipboard in normal, visual mode
        map. nx ([[<Leader>"]], [["+]])

        -- Swap case of letter
        map. n ([[gl]], [[g~l]], 'Swap case of single letter')

        -- Copy to clipboard
        wkreg{['<Leader>y'] = { name = '+Yank' }}
        map. n ([[<Leader>yy]], [[<Cmd>%y+<CR>]], 'Yank full buffer into system clipboard')

        -- Don't move the cursor with insert mode <C-o>
        map. i ([[<C-o>]], [[<C-\><C-o>]], { silent = false })

        -- Current buffer text object
        map. O ([[i%]], [[V0Gogg]], 'Current buffer')

        -- Indentation text object
        map. O ([[ii]], function () vim.funcs.selectindent(false) end, 'Current indentation level')
        map. O ([[ai]], function () vim.funcs.selectindent(true) end, 'Current indentation level with trailing empty lines')

        -- Caps lock
        map. ic ([[<C-l>]], vim.funcs.capslock)

        -- Close help page easily
        wkreg{ ['<Leader>h'] = { name = 'Help' } }
        map. n ([[<Leader>hc]], [[<Cmd>helpclose<CR>]])

        -- Loclist and quickfixlist toggles
        wkreg{ ['<Leader>c'] = { name = 'Quickfix list and cd'} }
        wkreg({ ['<Leader>c'] = { name = 'Quickfix list'} }, { mode = 'x' })
        wkreg{ ['<Leader>l'] = { name = 'Location list and lazyredraw'} }
        wkreg({ ['<Leader>l'] = { name = 'Location list'} }, { mode = 'x' })
        map. n ([[<Leader>lo]], [[<Cmd>lopen<CR>]])
        map. n ([[<Leader>lc]], [[<Cmd>lclose<CR>]])
        map. n ([[<Leader>co]], [[<Cmd>copen<CR>]])
        map. n ([[<Leader>cc]], [[<Cmd>cclose<CR>]])
        map. nx ([[<Leader>ln]], [[<Cmd>lnext<CR>]])
        map. nx ([[<Leader>lp]], [[<Cmd>lprev<CR>]])
        map. nx ([[<Leader>cn]], [[<Cmd>cnext<CR>]])
        map. nx ([[<Leader>cp]], [[<Cmd>cprev<CR>]])

        -- Easy enter terminal mode
        wkreg{ ['<Leader>t'] = { name = 'ToggleTerm' } }
        wkreg({ ['<Leader>t'] = { name = 'ToggleTerm' } }, { mode = 'x' })
        wkreg{ ['<C-\\>'] = { name = 'ToggleTerm' } }
        wkreg({ ['<C-\\>'] = { name = 'ToggleTerm' } }, { mode = 'x' })
        local toggleterm = require'toggleterm'
        map. n ([[<Leader>tt]], function () toggleterm.toggle(vim.v.count) end, 'Toggle')
        map. n ([[<Leader>th]], function () toggleterm.toggle(vim.v.count, nil, nil, 'horizontal') end, 'Horizontal')
        map. n ([[<Leader>tv]], function () toggleterm.toggle(vim.v.count, nil, nil, 'vertical') end, 'Vertical')
        map. n ([[<Leader>ta]], toggleterm.toggle_all, 'All')
        map. n ([[<C-\>h]], function () toggleterm.toggle(vim.v.count, nil, nil, 'horizontal') end, 'Horizontal')
        map. n ([[<C-\>v]], function () toggleterm.toggle(vim.v.count, nil, nil, 'vertical') end, 'Vertical')
        map. n ([[<C-\>a]], toggleterm.toggle_all, 'All')

        -- More ToggleTerm maps
        map. n ([[<Leader>ts]], function () toggleterm.send_lines_to_terminal('single_line', true, { args = vim.v.count }) end, 'Send lines')
        map. x ([[<Leader>ts]], function () toggleterm.send_lines_to_terminal('visual_lines', true, { args = vim.v.count }) end, 'Send lines')
        map. x ([[<Leader>tS]], function () toggleterm.send_lines_to_terminal('visual_selection', true, { args = vim.v.count }) end, 'Send visual selection')
        map. n ([[<C-\>s]], function () toggleterm.send_lines_to_terminal('single_line', true, { args = vim.v.count }) end, 'Send lines')
        map. x ([[<C-\>s]], function () toggleterm.send_lines_to_terminal('visual_lines', true, { args = vim.v.count }) end, 'Send lines')
        map. x ([[<C-\>S]], function () toggleterm.send_lines_to_terminal('visual_selection', true, { args = vim.v.count }) end, 'Send visual selection')

        -- Easy exit terminal mode
        map. t ([[<C-\><Esc>]],    [[<C-\><C-n>]], { nolazyredraw = true })
        map. t ([[<C-\><Leader>]], [[<C-\><C-n>]], { nolazyredraw = true })

        -- Use alt keys in terminal mode to change window
        map. nt ([[<M-h>]], [[<Cmd>exe v:count . 'wincmd h'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-j>]], [[<Cmd>exe v:count . 'wincmd j'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-k>]], [[<Cmd>exe v:count . 'wincmd k'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-l>]], [[<Cmd>exe v:count . 'wincmd l'<CR>]], { nolazyredraw = true })

        -- LSP maps
        map. n ([[<Leader>eE]], vim.diagnostic.setloclist, 'Set location list with diagnostics')
        -- map. n ([[<Leader>ee]], vim.diagnostic.open_float)
        -- map. n ([[<Leader>el]], vim.diagnostic.goto_next)
        -- map. n ([[<Leader>eh]], vim.diagnostic.goto_prev)
        -- map. n ([[<Leader>ej]], [[$<Cmd>lua vim.diagnostic.goto_next()<CR>]])
        -- map. n ([[<Leader>ek]], [[0<Cmd>lua vim.diagnostic.goto_prev()<CR>]])
        map. n ([[<Leader>eI]], [[<Cmd>LspInfo<CR>]])
        -- map. n ([[<Leader>E]], vim.lsp.buf.hover)
        map. n ([[<Leader>ed]], vim.lsp.buf.definition, 'Jump to definition')
        map. n ([[<Leader>eD]], vim.lsp.buf.declaration, 'Jump to declaration')
        map. n ([[<Leader>ei]], vim.lsp.buf.implementation, 'Set location list with implementations')
        -- map. n ([[<Leader>er]], vim.lsp.buf.rename)
        map. n ([[<Leader>eR]], vim.lsp.buf.references, 'References')
        map. n ([[<Leader>et]], vim.lsp.buf.type_definition, 'Type definition')
        map. n ([[<Leader>eF]], vim.lsp.buf.format, 'Format')
        map. x ([[<Leader>eF]], vim.lsp.buf.range_formatting, 'Format')
        -- map. n ([[<Leader>ec]], vim.lsp.buf.code_action)
        -- map. x ([[<Leader>ec]], vim.lsp.buf.range_code_action)
        -- map. n ([[<Leader>es]], vim.lsp.buf.signature_help)
        map. n ([[<Leader>ew]], vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
        map. n ([[<Leader>eW]], vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
        map. n ([[<Leader>e<C-w>]], function () vim.pretty_print(vim.lsp.buf.list_workspace_folders()) end, 'List workspace folders')

        -- Lspsaga maps
        wkreg{ ['<Leader>e'] = { name = 'LSP'} }
        wkreg({ ['<Leader>e'] = { name = 'LSP'} }, { mode = 'x' })
        map. n ([[<Leader>E]],  [[<Cmd>Lspsaga hover_doc<CR>]], 'LSP hover')
        map. n ([[<Leader>ef]], [[<Cmd>Lspsaga lsp_finder<CR>]], 'Lspsaga finder')
        map. n ([[<Leader>es]], [[<Cmd>Lspsaga signature_help<CR>]], 'Signature')
        map. n ([[<Leader>ep]], [[<Cmd>Lspsaga preview_definition<CR>]], 'Preview definition')
        map. n ([[<Leader>ee]], [[<Cmd>Lspsaga show_line_diagnostics<CR>]], 'Line diagnostics')
        map. n ([[<Leader>el]], [[<Cmd>Lspsaga diagnostic_jump_next<CR>]], 'Next diagnostic')
        map. n ([[<Leader>eh]], [[<Cmd>Lspsaga diagnostic_jump_prev<CR>]], 'Previous diagnostic')
        map. n ([[<Leader>er]], [[<Cmd>Lspsaga rename<CR>]], 'Rename')
        map. n ([[<Leader>ej]], [[$<Cmd>Lspsaga diagnostic_jump_next<CR>]], 'Next line diagnostic')
        map. n ([[<Leader>ek]], [[0<Cmd>Lspsaga diagnostic_jump_prev<CR>]], 'Previous line diagnostic')
        map. nx ([[<Leader>ec]], [[<Cmd>Lspsaga code_action<CR>]], 'Code action')

        -- lsp_lines.nvim toggle
        map. n ([[<Leader>e<C-e>]], require'lsp_lines'.toggle, 'Toggle diagnostic lines')

        -- Toggle whitespace visibility
        map. nx ([[<Leader><Leader>]], [[<Cmd>set list!<CR>]], 'Toggle showing whitespace')

        -- Toggles light/dark mode
        map. n ([[<Leader>C]], vim.funcs.toggledark, 'Toggle dark/light colorschemes')

        -- Preserve q: and quickfix <CR> functionality
        map. n ([[<CR>]], [[!(index(['[Command Line]'], expand('%')) is -1) || (&filetype == 'qf') ? '<CR>' : '']], { silent = false, expr = true })

        -- Swap to visual linewise movement (for editing actual paragraphs)
        map. n ([[<Leader>jk]], [[<Cmd>nnoremap j gj<CR><Cmd>nnoremap k gk<CR><Cmd>nnoremap 0 g0<CR><Cmd>nnoremap $ g$<CR>]], 'Make jk0$ visual')

        -- Set cwd to current file directory
        map. n ([[<Leader>cd]], [[<Cmd>tcd %:h<CR>]], 'Tab cd to current file')

        -- Delete trailing spaces
        map. n ([[<Leader>S]], [[<Cmd>%s/\s\+$//<Bar>norm!``<CR><Cmd>noh<CR>]], 'Trim trailing spaces')

        -- Quick jump to buffer
        map. n ([[<Leader>b]], [[<Cmd>ls<CR>:<C-u>b ]], { silent = false }, 'Buffer jump')

        -- Delete buffer without closing the current window
        map. n ([[<M-d>]], [[<Cmd>bp<Bar>bd#<CR>]], 'Close current buffer')
        map. n ([[<Leader><M-d>]], [[<Cmd>bp<Bar>bd!#<CR>]], 'Force-close current buffer')

        -- Change buffer easily
        map. nt ([[<M-n>]], [[<Cmd>exe v:count . 'bn'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-N>]], [[<Cmd>exe v:count . 'bN'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-p>]], [[<Cmd>exe v:count . 'bp'<CR>]], { nolazyredraw = true })
        map. nt ([[<M-3>]], [[<Cmd>b#<CR>]], { nolazyredraw = true })

        -- Temporarily increase scrolloff
        wkreg{ ['<Leader>z'] = { name = 'Scrolloff' } }
        map. n ([[<Leader>zz]], [['<Cmd>set scrolloff=8<CR><Cmd>set scrolloff=' . &scrolloff . '<CR>']], { expr = true }, 'Temporarily set scrolloff to 8')

        -- Go to misspelled word in insert mode
        map. i ([[<C-z>]], [[<Esc>b[sviw<Esc>a]])
        map. i ([[<C-s>]], [[<Esc>]sviw<Esc>a]])

        -- Telescope maps
        wkreg{ ['<Leader>f'] = { name = 'Telescope'} }
        local tele_builtin = require'telescope.builtin'
        map. n ([[<Leader>fr]], tele_builtin.resume,      'Resume previous')
        map. n ([[<Leader>ff]], tele_builtin.find_files,  'Files')
        map. n ([[<Leader>fg]], tele_builtin.live_grep,   'Live grep')
        map. n ([[<Leader>fb]], tele_builtin.buffers,     'Buffers')
        map. n ([[<Leader>fh]], tele_builtin.help_tags,   'Help tags')
        map. n ([[<Leader>fc]], tele_builtin.colorscheme, 'Colorschemes')
        map. n ([[<Leader>fR]], [[<Cmd>Telescope neoclip<CR>]], 'Neoclip registers')
        map. n ([[<Leader>fn]], [[<Cmd>Telescope notify<CR>]],  'Notify')
        map. n ([[<Leader>fH]], [[<Cmd>Telescope howdoi<CR>]],  'Howdoi')

        -- Open nvim tree without accidentally closing the current tabpage
        map. n ([[<Leader>e.]], [[<Cmd>NvimTreeToggle<CR>]])

        -- Toggle indent-blankline plugin
        wkreg{ ['<Leader>i'] = { name = 'Indent-blankline' } }
        map. n ([[<Leader>ii]], [[<Cmd>let g:indent_blankline_enabled = g:indent_blankline_enabled ? v:false : v:true<CR>]], 'Toggle')
    end,
}

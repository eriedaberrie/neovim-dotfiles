-- Keymaps
-- Nonrecursive and silent is assumed unless otherwise specified

-- Flags:
-- 0b0001 - default
-- 0b0010 - WSL
-- 0b0100 - VSCode plugin
-- 0b1000 - Firenvim

return {
    -- 0b0001
    [1] = {
        -- Open RPG maker game in debug mode
        -- { 'n', '<Leader>dg', [[<Cmd>!cmd.exe /s /c for /f "tokens=*" \%a in ('git rev-parse --show-toplevel') do start /d "\%a" Game.exe debug<CR>]] },
        -- { 'n', '<Leader>dg', [[<Cmd>!pwsh.exe -NoProfile -NoLogo -NonInteractive -Command cd "$(git rev-parse --show-toplevel)"  && Start-Process -FilePath "Game.exe" -ArgumentList "debug"<CR>]] },
        { 'n', '<Leader>dg', [[&shell ==# 'cmd.exe' ? '<Cmd>!for /f "usebackq tokens=*" \%a in (`git rev-parse --show-toplevel`) do start /d "\%a" Game.exe debug<CR><CR>' : '<Cmd>!start -FilePath Game.exe -WorkingDirectory "$(git rev-parse --show-toplevel)" -ArgumentList "debug"<CR><CR>']], { expr = true } },
        -- { 'n', '<Leader>gd', [[<Cmd>!pwsh.exe -NoProfile -NoLogo -NonInteractive -Command cd "$(git rev-parse --show-toplevel)" && .\Game.exe debug<CR>]] },
    },

    -- 0b0010
    [2] = {
        { 'n', '<Leader>dg', [[]] },
    },

    -- 0b0011
    [3] = {
        -- Set cwd to current file directory
        { 'n', '<Leader>cd', [[<Cmd>lcd %:h<CR>]] },

        -- Delete trailing spaces
        { 'n', '<Leader>ds', [[<Cmd>%s/\s\+$//<bar>norm!``<CR><Cmd>noh<CR>]] },

        -- Delete buffer without closing the current window
        { 'n', '<Leader>bd', [[<Cmd>bp<bar>bd#<CR>]]  },
        { 'n', '<Leader>Bd', [[<Cmd>bp<bar>bd!#<CR>]] },

        -- Open nvim tree without accidentally closing the current tabpage
        { 'n', '<Leader>e.', [[<Cmd>NvimTreeToggle<CR>]] },

        -- Window resize
        { 'n', '+', [[<C-w>+]] },
        { 'n', '-', [[<C-w>-]] },
        { 'n', '<M-,>', [[<C-w><]] },
        { 'n', '<M-.>', [[<C-w>>]] },

        -- Telescope maps
        { 'n', '<Leader>ff', [[<Cmd>Telescope find_files<CR>]] },
        { 'n', '<Leader>fg', [[<Cmd>Telescope live_grep<CR>]]  },
        { 'n', '<Leader>fb', [[<Cmd>Telescope buffers<CR>]]    },
        { 'n', '<Leader>fh', [[<Cmd>Telescope help_tags<CR>]]  },
        { 'n', '<Leader>fc', [[<Cmd>Telescope neoclip<CR>]]    },
        { 'n', '<Leader>fr', [[<Cmd>Telescope resume<CR>]]     },

        -- Reload impatient.nvim cache
        { 'n', '<Leader>I', [[:LuaCacheClear<CR>]], { silent = false } },

        -- Lazygit maps
        { 'n', '<Leader>gg', [[<Cmd>LazyGit<CR>]] },

        -- Zero cmdheight stuff
        -- { 'n', '<Esc>', [[<Cmd>noh<bar>set cmdheight=0<CR>]] },
        -- { 'n', 'q',     [[<Cmd>set cmdheight=1<CR>q]]},
    },

    -- 0b0100
    [4] = {
        -- Pressing "z=" opens the context menu
        { 'n', 'z=', [[<Cmd>call VSCodeNotify('keyboard-quickfix.openQuickFix')<CR>]] },

        -- Do not preserve q: <CR> functionality
        { 'n', '<CR>', [[<Nop>]] },
    },

    -- 0b1000
    [8] = {
        -- Pressing Escape twice in normal mode exits the Vim editor
        { 'n', '<Esc><Esc>', [[:wq<CR>]], { silent = false } },
    },

    -- 0b1011
    [11] = {
        -- Maps Ctrl-Backspace to do the thing
        { 'ic', '<C-bs>', [[<C-w>]], { silent = false } },

        -- Easy exit terminal mode
        { 't', '<Leader>t<Esc>', [[<C-\><C-n>]] },

        -- Use alt keys in terminal mode to change window
        { 'nt', '<M-h>', [[<C-\><C-n><C-w>h]] },
        { 'nt', '<M-j>', [[<C-\><C-n><C-w>j]] },
        { 'nt', '<M-k>', [[<C-\><C-n><C-w>k]] },
        { 'nt', '<M-l>', [[<C-\><C-n><C-w>l]] },

        -- Use alt keys in command mode
        { 'c', '<M-h>', [[<Left>]],  { silent = false } },
        { 'c', '<M-j>', [[<Down>]],  { silent = false } },
        { 'c', '<M-k>', [[<Up>]],    { silent = false } },
        { 'c', '<M-l>', [[<Right>]], { silent = false } },

        -- LSP maps
        { 'n', '<Leader>ee', vim.diagnostic.open_float },
        { 'n', '<Leader>E',  vim.diagnostic.setloclist },
        { 'n', '<Leader>el', vim.diagnostic.goto_next },
        { 'n', '<Leader>eh', vim.diagnostic.goto_prev },
        { 'n', '<Leader>ej', [[$<Cmd>lua vim.diagnostic.goto_next()<CR>]] },
        { 'n', '<Leader>ek', [[0<Cmd>lua vim.diagnostic.goto_prev()<CR>]] },

        -- Toggle whitespace visibility
        { 'nx', '<Leader><Leader>', [[<Cmd>set list!<CR>]] },

        -- Toggles dark/light themes
        { 'nx', '<Leader>tt', [[<Cmd>lua vim.funcs.settheme(vim.o.background == 'dark' and 'light' or 'dark')<CR>]] },

        -- Quickfix movement
        { 'nx', '<Leader>n', [[<Cmd>lne<CR>]] },
        { 'nx', '<Leader>N', [[<Cmd>lp<CR>]]  },

        -- Run code
        { 'n', '<Leader>rc', [[<Cmd>RunCodeFile<CR>]] },
        { 'x', '<Leader>rc', [[<Cmd>RunCodeSelected<CR>]] },

        -- Preserve q: <CR> functionality
        { 'n', '<CR>', [[expand('%') ==# '[Command Line]' ? '<CR>' : '']], { silent = false, expr = true } },

        -- Swap to visual linewise movement (for editing actual paragraphs)
        { 'n', '<Leader>jk', [[<Cmd>nnoremap j gj<CR><Cmd>nnoremap k gk<CR>]] },

        -- Telescope howdoi
        { 'n', '<Leader>hdi', [[<Cmd>Telescope howdoi<CR>]] },
    },

    -- 0b1111
    [15] = {
        -- Indent without exiting visual mode
        { 'x', '<', [[<gv]] },
        { 'x', '>', [[>gv]] },

        -- Unmap Backspace, Enter, Space
        { 'nx', '<Bs>',    [[<Nop>]] },
        { 'nx', '<Space>', [[<Nop>]] },
        { 'x',  '<CR>',    [[<Nop>]] },

        -- Pressing Escape cancels search highlights
        { 'n', '<Esc>', [[<Cmd>noh<CR>]] },

        -- Toggle lazy redraw
        { 'n', '<Leader>lr', [[<Cmd>set lazyredraw! lazyredraw?<CR>]] },

        -- Toggle shell
        { 'n', '<Leader>ss', vim.funcs.toggleshell },

        -- Run previous command with ! prefix
        { 'n', '<Leader>!', [[:!<C-r>:<CR>]], { silent = false } },

        -- Run previous command with lua prefix
        { 'n', '<Leader>lu', [[:lua <C-r>:<CR>]], { silent = false } },

        -- Pressing Ctrl-k to delete a pair of brackets ("deprecated" in favor of vim-surround)
        -- {'n', '<C-k>', [[mk%x`kx]]},

        -- ^ is more useful than 0
        { 'nx', '0', [[^]] },
        { 'nx', '^', [[0]] },

        -- Move around in insert mode with alt
        { 'i', '<M-h>', [[<Left>]]  },
        { 'i', '<M-j>', [[<Down>]]  },
        { 'i', '<M-k>', [[<Up>]]    },
        { 'i', '<M-l>', [[<Right>]] },

        -- EasyAlign
        { 'nx', '<Leader>ga', [[<plug>(EasyAlign)]], { noremap = true }},

        -- Easy access to clipboard in normal mode
        { 'n', '<Leader>+', [["+]] },
        { 'n', '<Leader>"', [["+]] },

        -- Swap case of letter
        { 'n', 'gl', [[g~l]] },

        -- Copy to clipboard
        { 'n', '<Leader>yy', [[<Cmd>%y+<CR>]] }
    },
}
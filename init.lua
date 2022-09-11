---------- NEOVIM INIT ----------
local opt = vim.opt
local g   = vim.g
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local env = vim.env

-- decrease startup time
require'impatient'

-- whether or not it's running Unix-like
local isUnix = fn.has('Unix') == 1
vim.isUnix = isUnix

-- my functions
local funcs = require'functions'
vim.funcs = funcs

-- set keymaps
g.mapleader = ' '
funcs.set_keymaps(require'keymaps')

-- search options - relevant everywhere
opt.ignorecase = true
opt.smartcase  = true

-- if spell is ever turend on
opt.spelllang = 'en_us'

-- disable K being "man" which is just not useful even on Unix
opt.keywordprg = ':help'

-- turn on lazy redraw - reenablable through keymaps
opt.lazyredraw = true

-- disable mouse by default on non-gui im not sure why nightly added this
opt.mouse = ''

-- easier to exit
api.nvim_create_user_command('W',  'w',  {})
api.nvim_create_user_command('Wq', 'wq', {})
api.nvim_create_user_command('WQ', 'wq', {})
api.nvim_create_user_command('Q',  'q',  {})

-- set up init autogroup
local initgroup = api.nvim_create_augroup('InitGroup', { clear = true })

---------- global plugins ----------
-- comment config
require'Comment'.setup{}

-- CursorHold config
g.cursorhold_updatetime = 50

local sconfig = require'nvim-surround.config'
-- nvim-surround config
require'nvim-surround'.setup {
    surrounds = {
        F = {
            add = function ()
                local result = sconfig.get_input('Arguments: ')
                if result then
                    return { { 'function (' .. result .. ') ' }, { ' end' } }
                end
            end
        },
    },
}
api.nvim_set_hl(0, 'NvimSurroundHighlight', { link = 'IncSearch' })

-- VSCode Neovim stuff
if g.vscode then
    -- disable neovim syntax highlighting
    opt.syntax = 'off'

    -- remove keymap timeout
    opt.timeout = false

    -- disable git blame plugin
    g.gitblame_enabled = 0

    -- disable indent blankline plugin
    g.indent_blankline_enabled = false

    return
end

-- for stuff that doesn't apply to VSCode extension
-- general options
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.tabstop        = 4
-- tab options (use sleuth.vim)
opt.expandtab      = true
opt.shiftwidth     = 0
opt.completeopt    = 'menu,menuone,noselect'
-- guifont (mainly for Neovide)
opt.guifont        = 'FiraCode NF:h10'
-- linebreak
opt.linebreak      = true
opt.breakindent    = true
opt.breakindentopt:append('shift:8')
-- <Leader><Leader> to show this
opt.listchars = {
    eol      = '¬',
    tab      = '<->',
    trail    = '~',
    extends  = '>',
    precedes = '<',
    space    = '·',
    nbsp     = 'x',
}
-- https://www.reddit.com/r/neovim/comments/psl8rq/sexy_folds/
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend))]]
        .. [[ . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']]
opt.fillchars:append('fold: ')

-- highlight yanked text
api.nvim_create_autocmd('TextYankPost', {
    group = initgroup,
    callback = function () pcall(vim.highlight.on_yank) end,
})

---------- plugins ----------
-- fuck it italics suck in general
require'gruvbox'.setup { italic = false }

-- colorizor setup
opt.termguicolors = true -- needs to be explicitly set before setting up
require'colorizer'.setup ({
    '*',
    html  = { names = true },
    css   = { names = true },
}, { names = false })

-- treesitter config
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        'norg',
        'lua', 'vim',
        'ruby', 'python',
        'c', 'c_sharp', 'cpp',
        'html', 'css', 'javascript', 'typescript', 'tsx',
        'json', 'json5', 'jsonc', 'yaml',
        'jsdoc',
        'markdown', 'rst', 'latex',
        'bash',
        'make', 'cmake', 'ninja',
        'fennel', 'scala',
        'java', 'go', 'rust', 'haskell',
    },
    highlight = {
        enable = true,
        disable = funcs.tsdisable,
        additional_vim_regex_highlighting = true,
    },
    incremental_selection = {
        enable = true,
        disable = funcs.tsdisable,
        keymaps = {
            init_selection    = '<M-t>',
            node_incremental  = '<M-t>',
            node_decremental  = '<M-s-t>',
            scope_incremental = '<Leader><M-t>',
        }
    },
    textobjects = {
        select = {
            enable = true,
            disable = funcs.tsdisable,
            lookahead = true,
            keymaps = {
                ['if'] = { query = '@function.inner',  desc = 'inner function' },
                ['af'] = { query = '@function.outer',  desc = 'a function' },
                ['ic'] = { query = '@class.inner',     desc = 'inner class' },
                ['ac'] = { query = '@class.outer',     desc = 'a class' },
                ['il'] = { query = '@loop.inner',      desc = 'inner loop' },
                ['al'] = { query = '@loop.outer',      desc = 'a loop' },
                ['ia'] = { query = '@parameter.inner', desc = 'inner argument' },
                ['aa'] = { query = '@parameter.outer', desc = 'an argument' },
            },
            selection_modes = {
                ['@class.inner'] = 'V',
                ['@class.outer'] = 'V',
                ['@loop.inner']  = 'V',
                ['@loop.outer']  = 'V',
            },
        },
        swap = {
            enable = true,
            disable = funcs.tsdisable,
            swap_next = { ['<M-s>'] = '@parameter.inner' },
            swap_previous = { ['<M-s-s>'] = '@parameter.inner' },
        },
        move = {
            enable = true,
            disable = funcs.tsdisable,
            set_jumps = true,
            goto_next_start     = { [']m'] = { query = '@function.outer', desc = 'Next function start' } },
            goto_next_end       = { [']M'] = { query = '@function.outer', desc = 'Next function end' } },
            goto_previous_start = { ['[m'] = { query = '@function.outer', desc = 'Previous function start' } },
            goto_previous_end   = { ['[M'] = { query = '@function.outer', desc = 'Previous function end' } },
        },
    },
    -- nvim-ts-rainbow parentheses highlighting
    rainbow = {
        enable = true,
        disable = funcs.tsdisable,
        extended_mode = true,
    },
}

-- disable treesitter fold on large buffers, auto open folds
api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
    group = initgroup,
    callback = function (arg)
        if funcs.autsdisable(api.nvim_buf_get_option(0, 'filetype'), 0) then
            api.nvim_win_set_option(0, 'foldmethod', 'manual')
        else
            local oldmethod = api.nvim_win_get_option(0, 'foldmethod')
            api.nvim_win_set_option(0, 'foldmethod', 'expr')
            if arg.event == 'BufEnter' or oldmethod == 'manual' then
                api.nvim_win_set_option(0, 'foldlevel', 99999)
            end
        end
    end,
})

-- coq_nvim settings
g.coq_settings = {
    auto_start = 'shut-up',
    keymap = {
        -- in order to use nvim-autopairs, see keymaps.lua and below
        recommended = false,
        eval_snips = '<Leader>C',
    },
    display = {
        pum = {
            fast_close = false,
        },
    },
    limits = {
        completion_manual_timeout = 1.33,
    }
}

-- third party coq sources
require'coq_3p' {
    { src = "nvimlua", short_name = "nLUA", conf_only = true },
    { src = 'bc', short_name = 'MATH', precision = 6 },
}

-- lspsaga config
require'lspsaga'.init_lsp_saga {
    code_action_lightbulb = {
        sign = false,
    },
    code_action_keys = {
        quit = '<Esc>',
    },
    symbol_in_winbar = {
        enable = true,
        separator = '  '
    },
}

-- make lspsaga winbar use theme
local _pre_lspsaga_settheme = funcs.settheme
---@diagnostic disable-next-line: duplicate-set-field
funcs.settheme = function (theme)
    _pre_lspsaga_settheme(theme)
    local colors = {
        fg     = '#bbc2cf',
        red    = '#e95678',
        orange = '#FF8700',
        yellow = '#f7bb3b',
        green  = '#afd700',
        cyan   = '#36d0e0',
        blue   = '#61afef',
        violet = '#CBA6F7',
        teal   = '#1abc9c',
    }
    local changes = {
        [colors.fg]     = 'ModeMsg',
        [colors.red]    = 'Exception',
        [colors.orange] = 'Special',
        [colors.yellow] = 'ModeMsg',
        [colors.green]  = 'Title',
        [colors.cyan]   = 'Macro',
        [colors.blue]   = 'Identifier',
        [colors.violet] = 'Constant',
        [colors.teal]   = 'Macro',
    }
    for _, kind in pairs(require'lspsaga.lspkind') do
        api.nvim_set_hl(0, 'LspSagaWinbar' .. kind[1], { link = changes[kind[3]] })
    end
    api.nvim_set_hl(0, 'LspSagaWinbarSep', { link = 'Comment' })
end

-- lsp_signature setup
require'lsp_signature'.setup {
    always_trigger = true,
    -- this is ctrl+slash
    toggle_key = '<C-_>',
    move_cursor_key = '<M-/>',
    select_signature_key = '<M-n>',
}

-- lsp_lines.nvim setup
require'lsp_lines'.setup()
-- use lsp_lines plugin or <Leader>ee/E for text
vim.diagnostic.config { virtual_text = false }

-- mason.nvim LSP installer
require'mason'.setup()
require'mason-lspconfig'.setup {
    automatic_installation = {
        exclude = {
            'clangd',
        }
    },
    ensure_installed = { 'jdtls', 'rust_analyzer' }
}

-- LSP config base
local lspconfig = require'lspconfig'
-- vim.lsp.set_log_level'debug'

local on_attach = function (_, buf)
    api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- LSP servers
local servers = {
    -- python
    pyright = {},
    -- ruby
    solargraph = {},
    -- lua
    sumneko_lua = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = { 'vim' }
            },
            telemetry = {
                enable = false,
            },
        }
    },
    -- eslint
    eslint = {},
    -- typescript - takes too much memory for ps :(
    -- tsserver = {},
    -- C stuff
    clangd = {},
    -- Emmet snippets
    emmet_ls = {},
}
if isUnix then
    -- haskell
    servers.hls = {}
end

-- actually setting up the LSP servers
local coq = require'coq'
for server, settings in pairs(servers) do
    lspconfig[server].setup(coq.lsp_ensure_capabilities {
        on_attach = on_attach,
        settings  = settings,
    })
end

-- set up the complicated nvim-autopairs keymaps
local npairs = require'nvim-autopairs'
npairs.setup { map_bs = false, map_cr = false, map_c_w = true }

api.nvim_set_keymap('i', '<CR>', '', { noremap = true, expr = true, callback = function ()
    if fn.pumvisible() ~= 0 then
        if fn.complete_info{ 'selected' }.selected ~= -1 then
            return npairs.esc('<C-y>')
        else
            return npairs.esc('<C-e>') .. npairs.autopairs_cr(api.nvim_get_current_buf())
        end
    else
        return npairs.autopairs_cr(api.nvim_get_current_buf())
    end
end })

api.nvim_set_keymap('i', '<BS>', '', { noremap = true, expr = true, callback = function ()
    if fn.pumvisible() ~= 0 and fn.complete_info{ 'mode' }.mode == 'eval' then
        return npairs.esc('<C-e>') .. npairs.autopairs_bs(api.nvim_get_current_buf())
    else
        return npairs.autopairs_bs(api.nvim_get_current_buf())
    end
end })

-- toggleterm setup
require'toggleterm'.setup {
    open_mapping = [[<C-\><C-\>]],
    insert_mappings = false,
    shell = isUnix and opt.shell:get() or 'pwsh.exe',
    size = function (term)
        if term.direction == 'horizontal' then
            return opt.lines:get() < 50 and opt.lines:get() * 0.4 or 20
        elseif term.direction == 'vertical' then
            return opt.columns:get() * 0.4
        end
    end,
}

-- filetree explorer
require'nvim-tree'.setup {
    respect_buf_cwd = true,
    sync_root_with_cwd = true,
    on_attach = function (bufnr)
        local inject_node = require'nvim-tree.utils'.inject_node
        local map = function (key, func, desc)
            api.nvim_buf_set_keymap(bufnr, 'n', key, '', { callback = inject_node(func), nowait = true, noremap = true, desc = desc })
        end

        map('d', require'nvim-tree.actions.fs.trash'.fn)
        map('D', require'nvim-tree.actions.fs.remove-file'.fn)
    end,
    remove_keymaps = { 'q', 'bmv' }, -- enable macros, never gonna use bulk move in my life
    trash = {
        cmd = isUnix and 'gio trash' or 'recycle-bin',
    },
    view = {
        preserve_window_proportions = true,
        signcolumn = 'auto',
    },
    renderer = {
        full_name = true,
        highlight_opened_files = 'name',
        indent_markers = {
            enable = true,
        },
    },
    api.nvim_set_hl(0, 'NvimTreeOpenedFile', { link = 'GruvboxBlueBold' })
}

-- telescope
local telescope = require'telescope'
telescope.setup {
    defaults = {
        mappings = {
            n = {
                ['q']     = 'close',
                ['<C-c>'] = 'close',
            },
        },
    },
    extensions = {
        howdoi = {
            command_executor = { 'cmd.exe', '/c' },
        },
    },
}
telescope.load_extension'neoclip'
telescope.load_extension'notify'
telescope.load_extension'howdoi'

-- set dressing as default input and select
require'dressing'.setup{}

-- set nvim-notify as default notifier
vim.notify = require'notify'

-- neoclip
require'neoclip'.setup{}

-- todo comments
require'todo-comments'.setup{}

-- firenvim stuff
if g.started_by_firenvim then
    g.firenvim_config = {
        localSettings = {
            [ [[.*]] ] = {
                takeover = 'never',
                selector = 'textarea',
                priority = 0,
            },
            [ [[https?://discord\.com/]] ] = {
                takeover = 'never',
                priority = 1,
            },
            [ [[https?://docs\.google\.com/]] ] = {
                takeover = 'never',
                priority = 1,
            },
        },
    }

    -- Gruvbox Theme plugin with light theme (insanely roundabout way for some reason)
    -- also starts insert mode if on empty buffer
    api.nvim_create_autocmd('BufReadPre', {
        group = initgroup,
        callback = function ()
            funcs.settheme'light'
            vim.schedule(function ()
                if fn.line('$') == 1 and fn.getline(1) == '' then
                    api.nvim_command [[startinsert]]
                end
            end)
        end,
        once = true,
    })

    -- less space so should hide statusline
    opt.laststatus = 1

    -- decrease fontsize
    funcs.resizetext(11)

    -- set spell always
    opt.spell = true

    -- remove keymap timeout
    opt.timeout = false

    -- disable git blame plugin
    g.gitblame_enabled = 0

    -- disable indent blankline plugin
    g.indent_blankline_enabled = false

    return
end

-- finally, for exclusively vanilla neovim
-- automatically prepend lua
funcs.autoprepend({ 'require', 'vim.' }, 'lua ')
-- automatically prepend !
funcs.autoprepend({ 'git', 'rubocop' }, '!')

-- make it easier to use funcs
funcs.alias('funcs', 'lua vim.funcs')

-- make it easier to help
funcs.alias('H', 'h')

-- make it easier to help in new tab
funcs.alias('ht', 'tab help')

-- make Bd not close the current window
api.nvim_create_user_command('Bd',  'bp<Bar>bd#',  {})
api.nvim_create_user_command('BD',  'bp<Bar>bd#',  {})
api.nvim_create_user_command('Bd1', 'bp<Bar>bd!#', {})
api.nvim_create_user_command('BD1', 'bp<Bar>bd!#', {})

-- set cwd to ~ if launched from windows start menu
local cwd = fn.fnamemodify(fn.getcwd(), ':~')
if cwd:sub(1, 21) == [[~\scoop\apps\neovide\]] or cwd == [[C:\WINDOWS\system32]] then
    cmd.cd('~')
end

-- filetype associations
vim.filetype.add {
    filename = { ['.path']  = 'sh' },
    extension = {
        nasm = 'asm',
        class = 'class',
    },
}

-- plugin management (packer)
require'plugins'
api.nvim_create_autocmd('BufWritePost', {
    pattern = [[plugins.lua]],
    group = initgroup,
    command = [[source <afile> | PackerCompile]],
})

---------- more plugins ----------
-- GitHub Theme
-- only set up once so running :so% doesn't ruin the tabline (not anymore)
local _pre_lualine_settheme = funcs.settheme
-- add lualine to the theme (do it after so that it updates)
local gitblame = require'gitblame'
g.gitblame_ignored_filetypes = { 'NvimTree' }
g.gitblame_display_virtual_text = 0
---@diagnostic disable-next-line: duplicate-set-field
funcs.settheme = function (theme)
    _pre_lualine_settheme(theme)
    require'lualine'.setup {
        options = {
            theme = 'gruvbox',
            globalstatus = true,
        },
        sections = {
            lualine_a = {
                { 'mode', separator = { right = '' } },
                { function ()
                    return funcs.capslockon and 'CAPS LOCK' or ''
                end, color = 'QuickFixLine', separator = { right = '' } }
            },
            lualine_b = { { 'filename' }, },
            lualine_c = {{ gitblame.get_current_blame_text, cond = gitblame.is_blame_text_available }},
            lualine_x = { 'encoding', 'fileformat', 'filesize', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
        tabline = {
            lualine_a = { 'buffers' },
            lualine_b = { 'branch', 'diff', { 'diagnostics', update_in_insert = true } },
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { 'tabs' },
        },
    }
end

-- image viewer
require'image'.setup{}

-- which-key
opt.timeoutlen = 0
api.nvim_create_autocmd('ModeChanged', {
    group = initgroup,
    callback = function ()
        local mode = fn.mode()
        opt.timeout = mode == 'n' or mode == 'v'
    end,
})
local wk = require'which-key'
wk.setup {
    plugins = {
        registers = false,
        spelling = {
            enabled = true,
            suggestions = 36,
        },
    },
    operators = {
        ['gr'] = 'Replace with register',
        ['ys'] = 'Yank surround',
        ['<Leader>ga'] = 'EasyAlign',
    }
}
wk.register {
    gr = { name = 'Replace with register' },
    grr = 'Replace current line with register',
}

-- disable git-blame.nvim on big files
api.nvim_create_autocmd('BufEnter', {
    group = initgroup,
    callback = function ()
        if api.nvim_buf_line_count(0) > 5000 then
            api.nvim_command [[GitBlameDisable]]
        else
            api.nvim_command [[GitBlameEnable]]
        end
    end
})

-- neorg
require'neorg'.setup {
    load = {
        ['core.defaults'] = {},
        ['core.keybinds'] = {
            config = {
                hook = function (k)
                    for _, lhs in ipairs({ 'gtu', 'gtp', 'gtd', 'gth', 'gtc', 'gtr', 'gti' }) do
                        k.unmap('norg', 'n', lhs)
                    end

                    k.map_event('norg', 'n', '<Leader>ntu', 'core.norg.qol.todo_items.todo.task_undone',    { desc = 'Mark undone' })
                    k.map_event('norg', 'n', '<Leader>ntp', 'core.norg.qol.todo_items.todo.task_pending',   { desc = 'Mark pending' })
                    k.map_event('norg', 'n', '<Leader>ntd', 'core.norg.qol.todo_items.todo.task_done',      { desc = 'Mark done' })
                    k.map_event('norg', 'n', '<Leader>nth', 'core.norg.qol.todo_items.todo.task_on_hold',   { desc = 'Mark on hold' })
                    k.map_event('norg', 'n', '<Leader>ntc', 'core.norg.qol.todo_items.todo.task_cancelled', { desc = 'Mark cancelled' })
                    k.map_event('norg', 'n', '<Leader>nti', 'core.norg.qol.todo_items.todo.task_important', { desc = 'Mark important' })
                    k.map_event('norg', 'n', '<Leader>nti', 'core.norg.qol.todo_items.todo.task_important', { desc = 'Mark important' })
                    k.map_event('norg', 'n', '<Leader>ntt', 'core.norg.qol.todo_items.todo.task_cycle',     { desc = 'Cycle' })
                    k.map_event('norg', 'n', '<Leader>nT',  'core.norg.qol.todo_items.todo.task_cycle',     { desc = 'Task cycle' })

                    k.map_event('norg', 'n', '<Leader>ngv', 'core.gtd.base.views',   { desc = 'Show view selection menu' })
                    k.map_event('norg', 'n', '<Leader>ngc', 'core.gtd.base.capture', { desc = 'Capture task' })
                    k.map_event('norg', 'n', '<Leader>nge', 'core.gtd.base.edit',    { desc = 'Edit task' })

                    k.map_event('norg', 'n', '<Leader>nN', 'core.norg.dirman.new.note', { desc = 'New note' })
                    k.map_event('norg', 'n', '<Leader>nx', 'core.norg.esupports.hop.hop-link', { desc = 'Follow link' })

                    k.map('norg', 'n', '<Leader>nn', '<Cmd>Neorg mode traverse-heading<CR>', { desc = 'Traverse headings' })
                    k.map('traverse-heading', 'n', '<Leader>nn', '<Cmd>Neorg mode norg<CR>', { desc = 'Return to normal mode' })

                    wk.register {
                        ['<Leader>n']  = { name = 'Neorg' },
                        ['<Leader>nt'] = { name = 'Tasks' },
                        ['<Leader>ng'] = { name = 'GTD' },
                    }
                end,
            }
        },
        ['core.norg.dirman'] = {
            config = {
                workspaces = {
                    notes = '~/Notes',
                }
            }
        },
        ['core.gtd.base'] = {
            config = {
                workspace = 'notes',
            }
        },
        ['core.norg.concealer'] = {},
    }
}

-- indent_blankline configuration
g.indentLine_fileTypeExclude = { '', 'text', 'norg', 'lspinfo', 'packer', 'checkhealth', 'help', 'man' }

-- nvim-dap configuration file
require'dap-config'

-- telescope lazygit (not in firenvim)
telescope.load_extension'lazygit'

-- config lazygit
api.nvim_create_autocmd('BufEnter', {
    group = initgroup,
    callback = require'lazygit.utils'.project_root_dir
})
g.lazygit_floating_window_use_plenary = 1

-- committia.vim
g.committia_hooks = {
    edit_open = function ()
        -- auto insert mode on blank commit messages
        if fn.getline(1) == '' then api.nvim_command [[startinsert]] end

        -- scrolling keymaps
        api.nvim_buf_set_keymap(0, 'i', [[<C-f>]], [[<Plug>(committia-scroll-diff-down-page)]], { noremap = false })
        api.nvim_buf_set_keymap(0, 'i', [[<C-b>]], [[<Plug>(committia-scroll-diff-up-page)]],   { noremap = false })
        api.nvim_buf_set_keymap(0, 'i', [[<C-d>]], [[<Plug>(committia-scroll-diff-down-half)]], { noremap = false })
        api.nvim_buf_set_keymap(0, 'i', [[<C-u>]], [[<Plug>(committia-scroll-diff-up-half)]],   { noremap = false })
        api.nvim_buf_set_keymap(0, 'i', [[<C-e>]], [[<Plug>(committia-scroll-diff-down)]], { noremap = false })
        api.nvim_buf_set_keymap(0, 'i', [[<C-y>]], [[<Plug>(committia-scroll-diff-up)]],   { noremap = false })
    end
}

-- Neovide (GUI) options
if g.neovide then
    -- g.neovide_fullscreen                     = true
    g.neovide_remember_window_size           = true
    g.neovide_refresh_rate                   = 45
    g.neovide_cursor_animation_length        = 0.05
    g.neovide_cursor_trail_length            = 0.8
    g.neovide_cursor_unfocused_outline_width = 0.075
    g.neovide_cursor_vfx_mode                = 'railgun'

    opt.mouse = 'a'

-- terminal neovim
else
    -- smooth scrolling
    -- require'neoscroll'.setup{}

    -- Windows Terminal cursor fix
    if env.WT_SESSION then
        local lastmatchid = -1
        local lastwin = 0

        local function delmatch ()
            if lastmatchid ~= -1 then
                if api.nvim_win_is_valid(lastwin) then
                    fn.matchdelete(lastmatchid, lastwin)
                end
                lastmatchid = -1
            end
        end

        -- WindowsTerminalFixHighlight
        api.nvim_create_autocmd({ 'VimEnter', 'InsertLeave', 'CursorMoved' }, {
            group = initgroup,
            callback = function ()
                local mode = fn.mode()
                if mode == 'i' or mode == 't' then return end

                delmatch()
                api.nvim_set_hl(0, 'WindowsTerminalCursorFg', { reverse = true })

                local l, c = unpack(api.nvim_win_get_cursor(0))
                lastmatchid = fn.matchaddpos('WindowsTerminalCursorFg', {{ l, c + 1 }}, 100)
                lastwin = api.nvim_get_current_win()
            end,
        })
        -- WindowsTerminalFixClear
        api.nvim_create_autocmd({ 'InsertEnter', 'TermEnter' }, {
            group = initgroup,
            callback = delmatch,
        })

        -- restore blinking cursor
        api.nvim_create_autocmd('VimLeave', {
            group = initgroup,
            command = [[set guicursor=a:block-blinkon750]],
        })
    end
end

-- set theme after deciding on italics
funcs.settheme(env.NVIM_LIGHTMODE and 'light' or (env.NVIM_DARKMODE and 'dark' or nil))

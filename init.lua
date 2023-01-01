---------- NEOVIM INIT ----------
local opt = vim.opt
local g   = vim.g
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd
local env = vim.env

-- whether or not it's running Unix-like
local isUnix = fn.has('Unix') == 1
local isRealUnix = isUnix and fn.has('win32') ~= 1
local isNixOS = isRealUnix and vim.loop.fs_stat('/nix') ~= nil
vim.isUnix = isUnix
vim.isRealUnix = isRealUnix
vim.isNixOS = isNixOS

-- whether or not it's running in TTY
local hasgui = not (isRealUnix and env.DISPLAY == nil)

-- decrease startup time
require'impatient'

-- my functions
local funcs = require'functions'
vim.funcs = funcs

-- set keymaps
g.mapleader = ' '
funcs.set_keymaps(require'keymaps')

-- set up init autogroup
local initgroup = api.nvim_create_augroup('InitGroup', { clear = true })

-- font variables
vim.defaultfont = 'JetbrainsMono Nerd Font'
vim.defaultfontsize = 7

-- search options
opt.ignorecase     = true
opt.smartcase      = true
opt.wildignorecase = true
-- general options
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.tabstop        = 4
-- tab options (use sleuth.vim)
opt.expandtab   = true
opt.shiftwidth  = 0
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.scrolloff   = 3
-- guifont (mainly for Neovide)
opt.guifont = vim.defaultfont .. ':h' .. tostring(vim.defaultfontsize)
-- linebreak
opt.linebreak   = true
opt.breakindent = true
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
opt.fillchars:append('fold: ')
-- if spell is ever turend on
opt.spelllang = 'en_us'
opt.spelloptions:append('camel')
-- disable K being "man" which is just not useful even on Unix
if not isRealUnix then
    opt.keywordprg = ':help'
end
-- https://www.reddit.com/r/neovim/comments/psl8rq/sexy_folds/
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend))]]
        .. [[ . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']]
-- update CursorHold events
opt.updatetime = 1500

-- easier to exit
api.nvim_create_user_command('W',  'w',  {})
api.nvim_create_user_command('Wq', 'wq', {})
api.nvim_create_user_command('WQ', 'wq', {})
api.nvim_create_user_command('Q',  'q',  {})

-- highlight yanked text
api.nvim_create_autocmd('TextYankPost', {
    group = initgroup,
    callback = function () pcall(vim.highlight.on_yank) end,
})

---------- plugins ----------
-- plugin management (packer)
require'plugins'
api.nvim_create_autocmd('BufWritePost', {
    pattern = [[plugins.lua]],
    group = initgroup,
    command = [[source <afile> | PackerCompile]],
})

-- load cmp config
require'cmp-config'

-- theme setups
require'onedark'.setup {
    style = 'warmer',
    ending_tildes = true,
    code_style = {
        functions = 'bold',
    },
}

require'catppuccin'.setup {
    term_colors = true,
    styles = {
        functions = { 'bold' },
    },
    integrations = {
        ts_rainbow = true,
        which_key  = true,
    },
}

g.github_comment_style  = 'NONE'
g.github_keyword_style  = 'NONE'
g.github_function_style = 'bold'
g.github_dark_float     = true

-- colorizor setup
if hasgui then
    opt.termguicolors = true -- needs to be explicitly set before setting up
    require'colorizer'.setup ({
        '*',
        html  = { names = true },
        css   = { names = true },
    }, { names = false })
end

-- treesitter config
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        'lua', 'vim',
        'ruby', 'python',
        'c', 'c_sharp', 'cpp',
        'html', 'css', 'javascript', 'typescript', 'tsx',
        'json', 'json5', 'jsonc', 'yaml',
        'jsdoc',
        'markdown', 'rst', 'latex',
        'bash', 'regex',
        'make', 'cmake', 'ninja',
        'commonlisp', 'fennel', 'clojure', 'scheme',
        'java', 'go', 'rust', 'haskell',
        'nix',
    },
    highlight = {
        enable = true,
        disable = funcs.tsdisable,
        additional_vim_regex_highlighting = { 'vim' },
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

-- comment config
require'Comment'.setup{}

-- nvim-surround config
local sconfig = require'nvim-surround.config'
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

-- set up nvim-autopairs
require'nvim-autopairs'.setup {
    disable_filetype = { 'TelescopePrompt', 'lisp', 'fennel', 'clojure', 'scheme' },
    map_cr = true,
    map_c_w = true,
}

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
            command_executor = isUnix and { 'bash', '-c' } or { 'cmd.exe', '/c' },
        },
    },
}
telescope.load_extension'neoclip'
telescope.load_extension'notify'

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

    -- Light theme (insanely roundabout way for some reason)
    -- also starts insert mode if on empty buffer
    api.nvim_create_autocmd('BufReadPre', {
        group = initgroup,
        callback = function ()
            funcs.toggledark(false)
            cmd.colorscheme('onedark')
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
    funcs.resizetext(9)

    -- set spell always
    opt.spell = true

    -- remove keymap timeout
    opt.timeout = false

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
        yuck = 'lisp',
    },
}

---------- more plugins ----------
-- nvim-dap configuration file
require'dap-config'

-- add lualine to the theme
require'lualine'.setup {
    options = {
        globalstatus = true,
    },
    sections = {
        lualine_a = {
            { 'mode', separator = { right = '' } },
            { function ()
                return funcs.capslockon and 'CAPS LOCK' or ''
            end, color = 'QuickFixLine', separator = { right = '' } }
        },
        lualine_b = {{ 'filename' }},
        lualine_c = {},
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
-- stop the annoying visual mode messages in which-key
api.nvim_set_keymap('n', 'v', 'v', { noremap = true })

-- set up aerial.nvim
local aerial = require'aerial'
aerial.setup{}
telescope.load_extension'aerial'

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
api.nvim_create_autocmd('ColorScheme', {
    group = initgroup,
    callback = function ()
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
            [colors.fg]     = { link = 'ModeMsg' },
            [colors.red]    = { fg = g.terminal_color_1 },
            [colors.orange] = { fg = g.terminal_color_11 },
            [colors.yellow] = { fg = g.terminal_color_3 },
            [colors.green]  = { fg = g.terminal_color_2 },
            [colors.cyan]   = { fg = g.terminal_color_6 },
            [colors.blue]   = { fg = g.terminal_color_4 },
            [colors.violet] = { fg = g.terminal_color_5 },
            [colors.teal]   = { fg = g.terminal_color_14 },
        }
        for _, kind in pairs(require'lspsaga.lspkind') do
            api.nvim_set_hl(0, 'LspSagaWinbar' .. kind[1], changes[kind[3]])
        end
        api.nvim_set_hl(0, 'LspSagaWinbarSep', { link = 'Comment' })
    end
})

-- lsp_signature setup
require'lsp_signature'.setup {
    always_trigger = true,
    hint_enable = false,
    handler_opts = {
        border = 'none',
    },
    -- different depending on OS for some reason
    toggle_key = isRealUnix and '<C-/>' or '<C-_>',
    move_cursor_key = '<M-/>',
    select_signature_key = '<M-s>',
}

-- lsp_lines.nvim setup
require'lsp_lines'.setup{}
-- use lsp_lines plugin or <Leader>ee/E for text
vim.diagnostic.config { virtual_lines = false }

if not isNixOS then
    -- mason.nvim LSP installer
    require'mason'.setup{}
    require'mason-lspconfig'.setup {
        automatic_installation = { exclude = { 'clangd' } },
        ensure_installed = { 'jdtls', 'rust_analyzer' },
    }
end

-- LSP config base
local lspconfig = require'lspconfig'
-- vim.lsp.set_log_level'debug'

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
    -- C stuff
    clangd = {},
    -- Emmet snippets
    emmet_ls = {},
}
if vim.isUnix then
    -- typescript - takes too much memory for ps on windows :(
    servers.tsserver = {}
end

-- actually setting up the LSP servers
local capabilities = require'cmp_nvim_lsp'.default_capabilities()
for server, settings in pairs(servers) do
    lspconfig[server].setup {
        settings = settings,
        capabilities = capabilities,
    }
end

-- indent_blankline configuration
g.indentLine_fileTypeExclude = {
    '', 'text', 'help', 'man',
    'checkhealth', 'lspinfo', 'packer',
    'lisp', 'fennel', 'clojure', 'scheme',
}

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
    end,
    status_open = function ()
        api.nvim_win_set_option(0, 'relativenumber', false)
    end,
    diff_open = function ()
        api.nvim_win_set_option(0, 'number', true)
        api.nvim_win_set_option(0, 'relativenumber', false)
    end,
}

-- Neovide (GUI) options
if g.neovide then
    -- g.neovide_fullscreen                     = true
    g.neovide_remember_window_size           = not isRealUnix
    g.neovide_remember_window_position       = not isRealUnix
    g.neovide_refresh_rate                   = 45
    g.neovide_cursor_animation_length        = 0.05
    g.neovide_cursor_trail_length            = 0.8
    g.neovide_cursor_unfocused_outline_width = 0.075
    g.neovide_cursor_vfx_mode                = 'railgun'
    g.neovide_transparency                   = 0.88

-- terminal neovim
else
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

-- set colorscheme before deciding on lightness because of github theme
if hasgui then
    require'colorscheme-file'.setup{ fallback = 'catppuccin-macchiato' }
    funcs.toggledark(env.NVIM_DARKMODE or not env.NVIM_LIGHTMODE)
end

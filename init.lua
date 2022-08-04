---------- NEOVIM INIT ----------
local opt = vim.opt
local g   = vim.g
local v   = vim.v
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

-- disable K being "man" which doesn't really exist on Windows
if not isUnix then
    opt.keywordprg = ':help'
end

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

-- nvim-surround config
require'nvim-surround'.setup {
    delimiters = {
        pairs = {
            z = { 'function () ', ' end' },
        },
    },
}
api.nvim_set_hl(0, 'NvimSurroundHighlightTextObject', { link = 'IncSearch' })

-- VSCode Neovim stuff
if g.vscode then
    -- disable neovim syntax highlighting
    opt.syntax = 'off'

    -- disable emmet plugin
    g.user_emmet_install_global = 0

    -- disable git blame plugin
    g.gitblame_enabled = 0

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
opt.guifont        = 'FiraCode NF:h11'
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

-- neovim terminal emulator things
-- automatically enter insert mode
api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
    group = initgroup,
    pattern = [[term://*]],
    command = [[startinsert]],
})
api.nvim_create_autocmd('TermOpen', {
    group = initgroup,
    -- command = [[set nonumber norelativenumber]],
    callback = function () end,
})
-- autoclose if exits with 0
api.nvim_create_autocmd('TermClose', {
    group = initgroup,
    callback = function (args)
        if v.event.status == 0 and args.file:sub(-8) ~= ':lazygit' then
            api.nvim_buf_delete(args.buf, {})
        end
    end,
})

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
require'colorizer'.setup {
    ['*'] = { names = false },
    html  = { names = true },
    css   = { names = true },
}

local tsdisable = function (_, buf) -- _ is lang
    return api.nvim_buf_line_count(buf) > 5000
end

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
        'java', 'go', 'rust',
    },
    highlight = {
        enable = true,
        disable = tsdisable,
        additional_vim_regex_highlighting = true,
    },
    incremental_selection = {
        enable = true,
        disable = tsdisable,
        keymaps = {
            init_selection    = '<Leader>ti',
            node_incremental  = '<Leader>ti',
            scope_incremental = '<Leader>tt',
            node_decremental  = '<Leader>td',
        }
    },
    -- nvim-ts-rainbow parentheses highlighting
    rainbow = {
        enable = true,
        disable = tsdisable,
        extended_mode = true,
    },
}

opt.foldexpr = 'nvim_treesitter#foldexpr()'

-- disable treesitter fold on large buffers, auto open folds
api.nvim_create_autocmd('BufWinEnter', {
    group = initgroup,
    callback = function ()
        if not tsdisable(nil, 0) then
            api.nvim_win_set_option(0, 'foldmethod', 'expr')
            cmd.normal{ 'zR', bang = true }
        else
            api.nvim_win_set_option(0, 'foldmethod', 'manual')
        end
    end,
})

-- coq_nvim settings
g.coq_settings = {
    auto_start = 'shut-up',
    keymap = {
        -- in order to use nvim-autopairs, see keymaps.lua and below
        recommended = false,
    },
    display = {
        pum = {
            fast_close = false,
        },
    },
}

-- third party coq sources
require'coq_3p' {
    { src = "nvimlua", short_name = "nLUA", conf_only = true },
    { src = 'bc', short_name = 'MATH', precision = 6 },
}

-- lsp_signature setup
require'lsp_signature'.setup {
    always_trigger = true,
    -- this is ctrl+slash
    toggle_key = '<C-_>',
    move_cursor_key = '<M-/>',
    select_signature_key = '<M-n>',
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
}
if isUnix then
    -- Java
    servers.jdtls = {}
    -- Scala
    servers.metals = {}
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

api.nvim_set_keymap('i', '<BS>', '', { noremap = true, expr = true, callback = function()
    if fn.pumvisible() ~= 0 and fn.complete_info{ 'mode' }.mode == 'eval' then
        return npairs.esc('<C-e>') .. npairs.autopairs_bs(api.nvim_get_current_buf())
    else
        return npairs.autopairs_bs(api.nvim_get_current_buf())
    end
end })

-- use <Leader>ee/E for text
-- vim.diagnostic.config { virtual_text = false }

-- filetree explorer
require'nvim-tree'.setup {
    respect_buf_cwd = true,
    sync_root_with_cwd = true,
    on_attach = function (bufnr)
        local inject_node = require'nvim-tree.utils'.inject_node
        local map = function (key, func)
            api.nvim_buf_set_keymap(bufnr, 'n', key, '', { callback = inject_node(func), nowait = true, noremap = true })
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

-- make emmet use my leader key instead of hijacking ctrl-y
g.user_emmet_leader_key = '<Leader>y'

-- so it doesn't mess with my insert mode typing
g.user_emmet_mode = 'n'

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
    api.nvim_create_autocmd('BufReadPre', {
        group = initgroup,
        callback = function ()
            funcs.settheme'light'
        end,
        once = true,
    })

    -- less space so should hide statusline
    opt.laststatus = 1

    -- decrease fontsize
    funcs.resizetext(8)

    -- disable git blame plugin
    g.gitblame_enabled = 0

    return
end

-- finally, for exclusively vanilla neovim
-- remove leader timeout
opt.timeout = false

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
funcs.setfiletype(initgroup, '.path', 'sh')
funcs.setfiletype(initgroup, '*.nasm', 'asm')

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
local oldsettheme = funcs.settheme
-- add lualine to the theme (do it after so that it updates)
local gitblame = require'gitblame'
g.gitblame_ignored_filetypes = { 'NvimTree' }
g.gitblame_display_virtual_text = 0
funcs.settheme = function (theme)
    oldsettheme(theme)
    require'lualine'.setup {
        options = {
            theme = 'gruvbox',
            globalstatus = true,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'filename' },
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

-- Disable git-blame.nvim on big files
api.nvim_create_autocmd('BufEnter', {
    group = initgroup,
    callback = function ()
        if api.nvim_buf_line_count(0) > 5000 then
            cmd.GitBlameDisable()
        else
            cmd.GitBlameEnable()
        end
    end
})

-- neorg
require'neorg'.setup {
    load = {
        ['core.defaults'] = {},
        ['core.norg.dirman'] = {
            config = {
                workspaces = {
                    notes = '~/Notes',
                }
            }
        },
        ['core.norg.concealer'] = {},
    }
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
    edit_open = function (_)
        -- spellcheck
        api.nvim_win_set_option(0, 'spell', true)

        -- auto insert mode on blank commit messages
        if fn.getline(1) == '' then cmd.startinsert() end

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
            callback = function () opt.guicursor = 'a:block-blinkon750' end
        })
    end
end

-- set theme after deciding on italics
funcs.settheme(env.NVIM_LIGHTMODE and 'light' or (env.NVIM_DARKMODE and 'dark' or nil))

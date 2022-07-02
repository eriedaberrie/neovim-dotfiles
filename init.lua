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

-- whether or not it's running WSL
local isWSL = fn.has('WSL') == 1
vim.isWSL = isWSL

-- my functions
local funcs = require'functions'
vim.funcs = funcs

-- set keymaps
g.mapleader = ' '
funcs.set_keymaps(require'keymaps')

-- search options - relevant everywhere
opt.ignorecase = true
opt.smartcase  = true

-- disable K being "man" which doesn't really exist on Windows
if not isWSL then
    opt.keywordprg = ':help'
end

-- turn on lazy redraw - reenablable through keymaps
opt.lazyredraw = true

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

-- VSCode Neovim stuff
if g.vscode then
    -- disable neovim syntax highlighting
    opt.syntax = 'off'

    -- remap broken commands
    -- doesn't work for some reason
    -- funcs.alias('bn', 'call VSCodeNotify("workbench.action.nextEditorInGroup")')
    -- funcs.alias('bN', 'call VSCodeNotify("workbench.action.previousEditorInGroup")')
    -- funcs.alias('bd', 'q')

    -- disable emmet plugin
    g.user_emmet_install_global = 0

    -- disable git blame plugin
    g.gitblame_enabled = 0

-- for stuff that doesn't apply to VSCode extension
else
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
        pattern = 'term://*',
        command = 'startinsert',
    })
    api.nvim_create_autocmd('TermOpen', {
        group = initgroup,
        -- command = 'set nonumber norelativenumber',
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

    ---------- plugins ----------
    -- cursor underline setup
    --[[ require'nvim-cursorline'.setup {
        cursorline = {
            enable = false,
        },
        cursorword = {
            enable = true,
            min_length = 3,
            hl = { underline = true },
        }
    } ]]

    -- colorizor setup
    opt.termguicolors = true -- needs to be explicitly set before setting up
    require'colorizer'.setup {
        '*',
        '!text',
        '!markdown',
    }

    -- require'nvim-autopairs'.setup {
    --     map_cr = false,
    -- }

    -- treesitter config
    require'nvim-treesitter.configs'.setup {
        ensure_installed = {
            'norg',
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = true,
            disable = function (_, buf) -- _ is lang
                return api.nvim_buf_line_count(buf) > 5000
            end,
        },
        -- nvim-ts-rainbow parentheses highlighting
        rainbow = {
            enable = true,
            extended_mode = true,
        },
    }

    -- treesitter fold options
    opt.foldmethod = 'expr'
    opt.foldexpr   = 'nvim_treesitter#foldexpr()'
    -- auto open folds
    api.nvim_create_autocmd('BufWinEnter', {
        group = initgroup,
        command = 'normal zR',
    })

    -- LSP config base
    local lspconfig = require'lspconfig'
    -- vim.lsp.set_log_level'debug'

    local mapopts = { noremap = true, silent = true }
    local on_attach = function (_, buf)
        api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        local lspmaps = {
        }

        for key, val in pairs(lspmaps) do
            api.nvim_buf_set_keymap(buf, 'n', key, val, mapopts)
        end
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
                workspace = {
                    library = vim.api.nvim_get_runtime_file('', true),
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
        -- Scala
        metals = {},
    }
    -- Java
    if isWSL then
        servers['jdtls'] = {}
    end

    -- use <Leader>ee/E for text
    vim.diagnostic.config { virtual_text = false }

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

        -- set up LSP for firenvim
        for server, settings in pairs(servers) do
            lspconfig[server].setup {
                on_attach    = on_attach,
                settings     = settings,
            }
        end

        -- disable git blame plugin
        g.gitblame_enabled = 0

    -- finally, for exclusively vanilla neovim
    else
        -- remove leader timeout
        opt.timeout = false

        -- automatically prepend lua
        funcs.autoprepend({ 'require', 'vim.' }, 'lua ')
        -- automatically prepend !
        funcs.autoprepend({ 'git', 'rubocop' }, '!')

        -- make it easier to use funcs
        funcs.alias('funcs', 'lua vim.funcs')

        -- make Bd not close the current window
        api.nvim_create_user_command('Bd',  'bp<Bar>bd#',  {})
        api.nvim_create_user_command('BD',  'bp<Bar>bd#',  {})
        api.nvim_create_user_command('Bd1', 'bp<Bar>bd!#', {})
        api.nvim_create_user_command('BD1', 'bp<Bar>bd!#', {})

        -- more zero cmdheight shenanigans are in keymaps
        -- opt.cmdheight = 0
        -- api.nvim_create_autocmd('InsertEnter', {
        --     group = initgroup,
        --     callback = function ()
        --         opt.cmdheight = (fn.reg_recording() == '') and 0 or 1
        --     end
        -- })

        -- set cwd to ~ if launched from windows start menu
        local cwd = fn.fnamemodify(fn.getcwd(), ':~')
        if cwd:sub(1, 21) == [[~\scoop\apps\neovide\]] or cwd == [[C:\WINDOWS\system32]] then
            cmd [[cd ~]]
        end

        -- filetype associations
        funcs.setfiletype(initgroup, '.path', 'sh')
        funcs.setfiletype(initgroup, '*.nasm', 'asm')

        -- plugin management (packer)
        require'plugins'
        api.nvim_create_autocmd('BufWritePost', {
            pattern = 'plugins.lua',
            group = initgroup,
            command = 'source <afile> | PackerCompile',
        })

        ---------- more plugins ----------
        -- adding luasnip snippets
        local luasnip = require'luasnip'
        require'luasnip.loaders.from_vscode'.lazy_load()

        -- actually setting up the LSP servers
        for server, settings in pairs(servers) do
            lspconfig[server].setup {
                on_attach    = on_attach,
                settings     = settings,
            }
        end

        -- GitHub Theme
        -- only set up once so running :so% doesn't ruin the tabline (not anymore)
        local oldsettheme = funcs.settheme
        -- add lualine to the theme (do it after so that it updates)
        local gitblame = require'gitblame'
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
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
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
                }
            }
        end

        -- Disable git-blame.nvim on big files
        api.nvim_create_autocmd('BufEnter', {
            group = initgroup,
            callback = function ()
                if api.nvim_buf_line_count(0) > 5000 then
                    cmd [[GitBlameDisable]]
                else
                    cmd [[GitBlameEnable]]
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

        -- neoclip
        require'neoclip'.setup{}

        -- todo comments
        require'todo-comments'.setup{}

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
                --[[ fzf_writer = {
                    minimum_grep_characters = 2,
                    minimum_files_characters = 2,
                    use_highlighter = true,
                }, ]]
            },
        }
        telescope.load_extension'neoclip'
        telescope.load_extension'notify'
        telescope.load_extension'lazygit'
        telescope.load_extension'howdoi'

        -- config lazygit
        api.nvim_create_autocmd('BufEnter', {
            group = initgroup,
            callback = require'lazygit.utils'.project_root_dir
        })
        g.lazygit_floating_window_use_plenary = 1

        -- filetree explorer
        require'nvim-tree'.setup {
            view = {
                mappings = {
                    list = {
                        { key = 'd', action = 'trash' },
                        { key = 'D', action = 'remove' },
                    },
                },
            },
        }

        -- set nvim-notify as default notifier
        vim.notify = require'notify'

        -- Neovide (GUI) options
        if g.neovide then
            -- g.neovide_fullscreen                     = true
            g.neovide_remember_window_size           = true
            g.neovide_refresh_rate                   = 45
            g.neovide_cursor_animation_length        = 0.05
            g.neovide_cursor_trail_length            = 0.8
            g.neovide_cursor_unfocused_outline_width = 0.075
            g.neovide_cursor_vfx_mode                = 'railgun'

        -- terminal neovim
        else
            -- italics outside of Neovide specifically tends to cause rendering problems with this font
            require'gruvbox'.setup {
                italic = false,
            }

            -- smooth scrolling
            -- require'neoscroll'.setup{}
        end

        -- set theme after deciding on italics
        funcs.settheme(env.NVIM_LIGHTMODE and 'light' or (env.NVIM_DARKMODE and 'dark' or nil))
    end
end

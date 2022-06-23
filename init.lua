---------- NEOVIM INIT ----------
local opt = vim.opt
local g   = vim.g
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
opt.keywordprg = ':help'

-- turn on lazy redraw - reenablable through keymaps
opt.lazyredraw = true

-- easier to exit
api.nvim_create_user_command('W',  'w',  {})
api.nvim_create_user_command('Wq', 'wq', {})
api.nvim_create_user_command('WQ', 'wq', {})
api.nvim_create_user_command('Q',  'q',  {})

-- set up init autogroup
local initgroup = api.nvim_create_augroup('InitGroup', {})

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
    }-- parentheses are necessary for defaults

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
                return api.nvim_buf_line_count(buf) > 30000
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
    }

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
        local themeac -- idk it stops the linter from yelling at me
        themeac = api.nvim_create_autocmd('BufReadPre', {
            group = initgroup,
            callback = function ()
                funcs.settheme'light'
                api.nvim_del_autocmd(themeac)
            end
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

        -- nvim-cmp
        local cmp = require'cmp'
        cmp.setup {
            snippet = {
                expand = function (args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert {
                -- this is ctrl-slash
                ['<C-_>'] = cmp.mapping.complete(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-2),
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-u>'] = cmp.mapping.scroll_docs(2),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-e>'] = cmp.mapping.abort(),

                -- autopair mapping
                ['<CR>'] = cmp.mapping(function (fallback)
                    if cmp.visible() then
                        cmp.confirm{ select = true }
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                -- luasnip mappings
                ['<Tab>'] = cmp.mapping(function (fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                        if col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function (fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            },
            sources = cmp.config.sources ({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            -- }, {
            --     { name = 'buffer' },
            })
        }

        -- command line completion
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                {
                    name = 'cmdline',
                    -- no autocomplete for bare ! due to lag
                    -- TODO: also for :term
                    keyword_pattern = [=[\!\@<!\w*]=],
                }
            })
        })

        -- search line completion
        for _, key in ipairs{ '/', '?' } do
            cmp.setup.cmdline(key, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
        end

        -- cmp with LSP
        local capabilities = require'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol.make_client_capabilities())

        -- actually setting up the LSP servers
        for server, settings in pairs(servers) do
            lspconfig[server].setup {
                on_attach    = on_attach,
                capabilities = capabilities,
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
                if api.nvim_buf_line_count(0) > 10000 then
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
        require'nvim-tree'.setup{
            view = {
                mappings = {
                    list = {
                        { key = 'd', action = 'trash' },
                        { key = 'D', action = 'remove' },
                    },
                },
            },
            trash = {
                cmd = 'recycle',
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
            g.gruvbox_italic = false
            g.gruvbox_italicize_comments = false

            -- smooth scrolling
            -- require'neoscroll'.setup{}
        end

        -- set theme after deciding on italics
        funcs.settheme(env.NVIM_LIGHTMODE and 'light' or (env.NVIM_DARKMODE and 'dark' or nil))
    end
end

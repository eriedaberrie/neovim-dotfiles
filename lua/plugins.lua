-- This file can be loaded by calling `lua require('plugins')` from your init.vim

return require'packer'.startup {
    function (use)
        -- Packer can manage itself
        use 'wbthomason/packer.nvim'

        -- Impatient.nvim (decrease startup time)
        use 'lewis6991/impatient.nvim'

        -- Fix the CursorHold event with LuaLine
        use 'antoinemadec/FixCursorHold.nvim'

        -- Collection of configurations for the built-in LSP client
        use 'neovim/nvim-lspconfig'

        -- General LSP help
        use 'glepnir/lspsaga.nvim'

        -- LSP signature help
        use 'ray-x/lsp_signature.nvim'

        -- Auto pairs
        use 'windwp/nvim-autopairs'

        -- Gruvbox Neovim theme
        use 'ellisonleao/gruvbox.nvim'

        -- GitHub Neovim Theme
        -- use 'projekt0n/github-nvim-theme'

        -- Smoother scrolling animation
        use 'karb94/neoscroll.nvim'

        -- Indent line
        use 'lukas-reineke/indent-blankline.nvim'

        -- Image viewer
        use 'samodostal/image.nvim'

        -- Highlight word under cursor
        -- use 'yamatsum/nvim-cursorline'

        -- Color hex codes
        use 'norcalli/nvim-colorizer.lua'

        -- Input and select UI
        use 'stevearc/dressing.nvim'

        -- Notifications
        use 'rcarriga/nvim-notify'

        -- Commenting
        use 'numToStr/Comment.nvim'

        -- Surround but in lua
        use 'kylechui/nvim-surround'

        -- Line diagnostics
        -- use 'Mofiqul/trld.nvim'

        -- Git blame
        use 'f-person/git-blame.nvim'

        -- Lazygit
        use 'kdheepak/lazygit.nvim'

        -- Terminal helper
        use 'akinsho/toggleterm.nvim'

        -- Just require plenary at all times no matter what
        use 'nvim-lua/plenary.nvim'

        -- Neorg
        use {
            'nvim-neorg/neorg',
            requires = 'nvim-lua/plenary.nvim',
        }

        -- nvim-tree.lua
        use {
            'kyazdani42/nvim-tree.lua',
            -- 'eriedaberrie/nvim-tree.lua.fork',
            -- branch = 'release',
            requires = 'kyazdani42/nvim-web-devicons',
        }

        -- Neoclip
        use {
            'AckslD/nvim-neoclip.lua',
            requires = 'nvim-telescope/telescope.nvim',
        }

        -- Howdoi Telescope integration
        use {
            'zane-/howdoi.nvim',
            requires = 'nvim-telescope/telescope.nvim',
        }

        -- Telescope
        use {
            'nvim-telescope/telescope.nvim',
            requires = 'nvim-lua/plenary.nvim',
        }

        -- Debugger
        use {
            'mfussenegger/nvim-dap',

            -- UI
            'theHamsta/nvim-dap-virtual-text',
            'rcarriga/nvim-dap-ui',

            -- Additional configurations
            'mfussenegger/nvim-dap-python',
        }

        -- Code completion (supposedly quite speedy as well)
        use {
            {
                'ms-jpq/coq_nvim',
                run = vim.isUnix and ':COQdeps' or nil,
            },
            'ms-jpq/coq.artifacts',
            'ms-jpq/coq.thirdparty',
        }

        -- Treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            'nvim-treesitter/playground',

            -- Rainbow parentheses
            'p00f/nvim-ts-rainbow',
        }

        -- Todo comments
        use {
            'vinnyA3/todo-comments.nvim',
            requires = 'nvim-lua/plenary.nvim',
        }

        -- LuaLine
        use {
            'nvim-lualine/lualine.nvim',
            -- after = 'github-nvim-theme',
            requires = 'kyazdani42/nvim-web-devicons',
        }

        -- firenvim (browser extension)
        if vim.isUnix == false then
            use {
                'glacambre/firenvim',
                run = function () vim.fn['firenvim#install'](0) end
            }
        end

        ---------- .vim plugins ----------
        -- vim-easy-align
        use 'junegunn/vim-easy-align'

        -- ReplaceWithRegister
        use 'inkarkat/vim-ReplaceWithRegister'

        -- sleuth.vim
        use 'tpope/vim-sleuth'

        -- Better git commit editing
        use 'rhysd/committia.vim'

        -- fzf finder
        use {
            'junegunn/fzf.vim',
            requires = 'junegunn/fzf',
            disable = true,
        }

        ---------- minesweeper ----------
        use 'seandewar/nvimesweeper'
    end,
    config = {
        git = {
            subcommands = {
                update = 'pull --progress --rebase=true --no-autostash',
            },
        },
    }
}

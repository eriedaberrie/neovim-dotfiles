-- This file can be loaded by calling `lua require('plugins')` from your init.vim

return require'packer'.startup {
    function (use)
        -- Packer can manage itself, but so can NixOS
        if not vim.isNixOS then
            use 'wbthomason/packer.nvim'
        end

        -- Impatient.nvim (decrease startup time)
        use 'lewis6991/impatient.nvim'

        -- Auto pairs
        use 'windwp/nvim-autopairs'

        -- File for colorscheme
        use 'eriedaberrie/colorscheme-file.nvim'

        -- Indent line
        use 'lukas-reineke/indent-blankline.nvim'

        -- Color hex codes
        use 'norcalli/nvim-colorizer.lua'

        -- Input and select UI
        use 'stevearc/dressing.nvim'

        -- Notifications
        use 'rcarriga/nvim-notify'

        -- Keymap popup
        use 'folke/which-key.nvim'

        -- Commenting
        use 'numToStr/Comment.nvim'

        -- Popup for if you hit enter before hitting tab
        use 'mong8se/actually.nvim'

        -- Surround but in lua
        use 'kylechui/nvim-surround'

        -- Above, but for lisps
        use 'gpanders/nvim-parinfer'

        -- Lazygit
        use 'kdheepak/lazygit.nvim'

        -- Terminal helper
        use 'akinsho/toggleterm.nvim'

        -- Just require plenary at all times no matter what
        use 'nvim-lua/plenary.nvim'

        -- Colorschemes
        use {
            'ellisonleao/gruvbox.nvim',
            'navarasu/onedark.nvim',
            'projekt0n/github-nvim-theme',
            {
                'catppuccin/nvim',
                as = 'catppuccin',
            },
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

        -- Telescope
        use {
            'nvim-telescope/telescope.nvim',
            requires = 'nvim-lua/plenary.nvim',
        }

        -- LSP
        use {
            'neovim/nvim-lspconfig',

            -- Language-specific LSP plugins
            'mfussenegger/nvim-jdtls',
            'simrat39/rust-tools.nvim',

            -- General LSP usefulness
            'glepnir/lspsaga.nvim',

            -- LSP signature help
            'ray-x/lsp_signature.nvim',

            -- LSP diagnostics prettier
            'Maan2003/lsp_lines.nvim',
        }

        -- LSP installers
        if not vim.isNixOS then
            use 'williamboman/mason.nvim'
            use 'williamboman/mason-lspconfig.nvim'
        end

        -- Debugger
        use {
            'mfussenegger/nvim-dap',

            -- UI
            'theHamsta/nvim-dap-virtual-text',
            'rcarriga/nvim-dap-ui',

            -- Additional configurations
            'mfussenegger/nvim-dap-python',
        }

        -- Autocompletion
        use {
            'hrsh7th/nvim-cmp',

            -- Sources
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-calc',
            'f3fora/cmp-spell',
            'dmitmel/cmp-digraphs',

            -- Snippets
            'dcampos/nvim-snippy',
            'dcampos/cmp-snippy',
            'honza/vim-snippets',

            -- Custom icons
            'onsails/lspkind.nvim',
        }

        -- Treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            'nvim-treesitter/playground',

            -- Text objects
            'nvim-treesitter/nvim-treesitter-textobjects',
            -- Rainbow parentheses
            'p00f/nvim-ts-rainbow',
            -- Symbol navigator
            'stevearc/aerial.nvim',
        }

        -- Todo comments
        use {
            'folke/todo-comments.nvim',
            requires = 'nvim-lua/plenary.nvim',
        }

        -- LuaLine
        use {
            'nvim-lualine/lualine.nvim',
            -- after = 'github-nvim-theme',
            requires = 'kyazdani42/nvim-web-devicons',
        }

        -- firenvim (browser extension)
        if vim.fn.has('wsl') == 0 then
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

        -- Hyprland configuration syntax
        use 'theRealCarneiro/hyprland-vim-syntax'

        -- fzf finder
        use {
            'junegunn/fzf.vim',
            requires = 'junegunn/fzf',
            disable = true,
        }

        ---------- minesweeper ----------
        use 'seandewar/nvimesweeper'
        use 'seandewar/killersheep.nvim'
    end,
    config = {
        git = {
            subcommands = {
                update = 'pull --progress --rebase=true --no-autostash',
            },
        },
    }
}

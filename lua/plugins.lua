-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Following autocmmand migrated to lua in init.lua
--- vim.cmd([[
---   augroup packer_user_config
---     autocmd!
---     autocmd BufWritePost plugins.lua source <afile> | PackerCompile
---   augroup end
--- ]])

return require'packer'.startup(function (use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Impatient.nvim (decrease startup time)
    use 'lewis6991/impatient.nvim'

    -- Collection of configurations for the built-in LSP client
    use 'neovim/nvim-lspconfig'

    -- Auto pairs
    use 'windwp/nvim-autopairs'

    -- Gruvbox Neovim theme
    use 'ellisonleao/gruvbox.nvim'

    -- GitHub Neovim Theme
    -- use 'projekt0n/github-nvim-theme'

    -- Smoother scrolling animation
    use 'karb94/neoscroll.nvim'

    -- Indent line
    -- use 'lukas-reineke/indent-blankline.nvim'

    -- Highlight word under cursor
    -- use 'yamatsum/nvim-cursorline'

    -- Color hex codes
    use 'norcalli/nvim-colorizer.lua'

    -- Notifications
    use 'rcarriga/nvim-notify'

    -- Commenting
    use 'numToStr/Comment.nvim'

    -- Line diagnostics
    -- use 'Mofiqul/trld.nvim'

    -- Git blame
    use '~/Downloads/git-blame.nvim'

    -- Lazygit
    use '~/Downloads/lazygit.nvim'

    -- Run code
    use 'arjunmahishi/run-code.nvim'

    -- REPL
    use {
        'pappasam/nvim-repl',
        requires = 'tpope/vim-repeat',
    }

    -- Neorg
    use {
        'nvim-neorg/neorg',
        requires = 'nvim-lua/plenary.nvim',
    }

    -- nvim-tree.lua
    use {
        '~/Downloads/nvim-tree.lua',
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

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        -- Modules not dependencies
        requires = {
            -- Rainbow parentheses
            'p00f/nvim-ts-rainbow',
        },
    }

    -- Todo comments
    use {
        '~/Downloads/todo-comments.nvim',
        requires = 'nvim-lua/plenary.nvim',
    }

    -- LuaLine
    use {
        'nvim-lualine/lualine.nvim',
        -- after = 'github-nvim-theme',
        requires = 'kyazdani42/nvim-web-devicons',
    }

    -- firenvim (browser extension)
    if not vim.isWSL then
        use {
            'glacambre/firenvim',
            run = function() vim.fn['firenvim#install'](0) end
        }
    end

    ---------- .vim plugins ----------
    -- vim-easy-align
    use 'junegunn/vim-easy-align'

    -- ReplaceWithRegister
    use 'inkarkat/vim-ReplaceWithRegister'

    -- surround.vim
    use 'tpope/vim-surround'

    -- repeat.vim
    use 'tpope/vim-repeat'

    -- sleuth.vim
    use 'tpope/vim-sleuth'

    -- Emmet
    use 'mattn/emmet-vim'

    -- fzf finder
    use {
        'junegunn/fzf.vim',
        requires = 'junegunn/fzf',
        disable = true,
    }

    ---------- minesweeper ----------
    use 'seandewar/nvimesweeper'
end)

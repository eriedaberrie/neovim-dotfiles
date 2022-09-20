-- nvim-cmp config

local cmp = require'cmp'
local snippy = require'snippy'

cmp.setup {
    snippet = {
        expand = function (args)
            snippy.expand_snippet(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-u>']     = cmp.mapping.scroll_docs(-3),
        ['<C-d>']     = cmp.mapping.scroll_docs(3),
        ['<C-b>']     = cmp.mapping.scroll_docs(-6),
        ['<C-f>']     = cmp.mapping.scroll_docs(6),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>']     = cmp.mapping.abort(),
        ['<CR>']      = cmp.mapping.confirm(),
        ['<Tab>']     = cmp.mapping.select_next_item(),
        ['<S-Tab>']   = cmp.mapping.select_prev_item(),
    },
    sources = cmp.config.sources {
        { name = 'snippy' },
        { name = 'neorg' },
        { name = 'nvim_lsp' },
        { name = 'calc' },
        { name = 'buffer', keyword_length = 2 },
        { name = 'spell',  keyword_length = 2 },
        -- Requires manual completion
        { name = 'digraphs', keyword_length = 3 },
    },
    formatting = {
        -- Use fancier icons
        format = require'lspkind'.cmp_format {
            mode = 'symbol',
        }
    }
}

for _, c in ipairs({ '/', '?' }) do
    cmp.setup.cmdline(c, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer', keyword_length = 2 }
        }
    })
end

-- Restore tab completion for regular : cmdline
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {},
})

-- Set up snippy
snippy.setup {
    hl_group = '@text.strong',
    mappings = {
        is = {
            ['<M-n>'] = 'expand_or_advance',
            ['<M-p>'] = 'previous',
        },
    },
}

-- Automatically add parentheses at the end of a method
cmp.event:on('confirm_done',  require'nvim-autopairs.completion.cmp'.on_confirm_done())

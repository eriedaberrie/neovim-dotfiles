-- rust-tools.nvim setup

if vim.g.vscode or vim.g.started_by_firenvim then return end
if vim.g.sourced_rust_tools then return end
vim.g.sourced_rust_tools = true

if vim.fn.executable('rust-analyzer') == 0 then
    vim.notify('`rust-analyzer` is not executable', vim.log.levels.WARN)
    return
end

local codelldb = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/'
local codelldb_exe = codelldb .. 'adapter/codelldb'
if not vim.isUnix then codelldb_exe = codelldb_exe .. '.exe' end
local liblldb = codelldb .. (vim.isUnix and 'lldb/lib/liblldb.so' or 'lldb/bin/liblldb.dll')

local rt = require'rust-tools'

rt.setup {
    server = {
        on_attach = function (_, buf)
            local wk = require'which-key'
            require'jdtls.setup'.add_commands()
            wk.register({
                name = 'Rust',
                r = { rt.runnables.runnables, 'Choose runnables' },
                c = { rt.code_action_group.code_action_group, 'Code action group' },
                m = { rt.expand_macro.expand_macro, 'Expand macro' },
                t = { rt.open_cargo_toml.open_cargo_toml, 'Open cargo.toml' },
                p = { rt.parent_module.parent_module, 'Parent module' },
                k = { function () rt.move_item.move_item(true) end, 'Move item up' },
                j = { function () rt.move_item.move_item(false) end, 'Move item down' },
                ['<C-r>'] = { rt.hover_actions.hover_actions, 'Hover actions' },
            }, { buffer = buf, prefix = '<Leader>e<C-r>' })

            vim.api.nvim_buf_set_keymap(buf, 'n', '<Leader>D', '', { callback = function ()
                local dap = require'dap'
                if dap.session() then
                    dap.continue()
                else
                    rt.debuggables.debuggables()
                end
            end, desc = 'Rust DAP continue' })
        end,
    },
    dap = {
        adapter = require'rust-tools.dap'.get_codelldb_adapter(codelldb_exe, liblldb)
    },
}

-- reload autocommands with setup
vim.api.nvim_command [[edit]]

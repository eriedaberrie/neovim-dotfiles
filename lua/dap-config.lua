-- nvim-dap configuration
local uv     = vim.loop
local fn     = vim.fn
local api    = vim.api
local levels = vim.log.levels

local isUnix = vim.isUnix

local dap = require'dap'

fn.sign_define('DapStopped',             { text = '', texthl = 'Visual', linehl = 'Visual', numhl = 'Visual' })
fn.sign_define('DapBreakpoint',          { text = '🔴', texthl = 'SignColumn' })
fn.sign_define('DapLogPoint',            { text = '',  texthl = 'SignColumn' })
fn.sign_define('DapBreakpointRejected',  { text = 'R', texthl = 'SignColumn' })
fn.sign_define('DapBreakpointCondition', { text = 'C', texthl = 'SignColumn' })

local compiling = {}
local try_recompile_cxx = function (sourcename, exename)
    local compiler = fn.fnamemodify(sourcename, ':e') == 'c' and 'gcc' or 'g++'
    if not isUnix then compiler = compiler .. '.exe' end
    if fn.executable(compiler) == 1 then
        local co = coroutine.running()
        vim.schedule(function ()
            local buf = api.nvim_get_current_buf()
            if compiling[buf] then
                vim.notify(string.format('Already compiling buffer %d (%s). Restarting recompilation...',
                        buf, fn.shellescape(exename)), levels.WARNING)
                compiling[buf]:shutdown(25, 15)
            else
                vim.notify(string.format('Executable %s older than source. Recompiling...',
                        fn.shellescape(exename)))
            end

            compiling[buf] = require'plenary.job':new {
                command = compiler,
                args = { '-g', '-o', exename, sourcename },
                on_exit = function (j, code)
                    compiling[buf] = nil
                    if code == 0 then
                        coroutine.resume(co)
                    elseif code ~= 25 then
                        vim.notify(string.format('Compiler %s exited with code %d:\n\n%s',
                                compiler, code, table.concat(j:stderr_result(), '\n')),
                                levels.ERROR)
                    end
                end,
            }
            compiling[buf]:start()
        end)
        coroutine.yield()
    else
        vim.notify(string.format('Executable %s older than source. Debugging anyways...',
                fn.shellescape(exename)), levels.WARN)
    end
end

local dap_cxx_program = function ()
    -- needs to be a thread in order to use async vim.ui.input
    return coroutine.create(function (dap_run_co)
        local sourcename = fn.expand('%:p')
        local curstat = uv.fs_stat(sourcename)

        -- use current file without extension, dirname, "main", "a", "a.out" if possible
        for _, exename in ipairs({ fn.fnamemodify(sourcename, ':r'), fn.fnamemodify(uv.cwd(), ':t'), 'main', 'a', 'a.out' }) do
            if not isUnix then exename = exename .. '.exe' end
            exename = fn.fnamemodify(exename, ':p')

            local stat = uv.fs_stat(exename)
            if stat then
                if stat.ctime.sec < curstat.mtime.sec then
                    try_recompile_cxx(sourcename, exename)
                end

                vim.schedule(function ()
                    coroutine.resume(dap_run_co, exename)
                end)
                return
            end
        end

        -- if that doesn't work then ui input prompt
        vim.ui.input({
            prompt = 'Path to executable: ',
            default = fn.getcwd() .. (isUnix and '/' or '\\'),
            completion = 'file',
        }, function (exename)
            coroutine.resume(dap_run_co, exename)
        end)
    end)
end

-- adapters
dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
        command = fn.stdpath('data') .. (isUnix and '/mason/bin/codelldb' or '\\mason\\bin\\codelldb.cmd'),
        args = { '--port', '${port}' },
        detached = isUnix,
    },
}

-- custom configurations
dap.configurations.c = {
    {
        name = 'Launch',
        type = 'codelldb',
        request = 'launch',
        program = dap_cxx_program,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = vim.LLDB_CXX_ARGS,
        stdio = function ()
            local possible = fn.expand('%:r') .. '.in'
            if fn.filereadable(possible) == 1 then
                return possible
            end
        end,
    },
}
dap.configurations.cpp = dap.configurations.c

-- language-specific dap extensions
require'dap-python'.setup()

-- additional dap plugins
require'nvim-dap-virtual-text'.setup {
    only_first_definition = false,
    all_references = true,
}

local dapui = require'dapui'
dapui.setup()
dap.listeners.after.event_initialized.dapui_config = dapui.open

-- close neovim if the only other windows are dap-ui
api.nvim_create_autocmd('QuitPre', {
    group = 'InitGroup',
    callback = function ()
        local daptable = {}

        local winisfile = function (win)
            local buf = api.nvim_win_get_buf(win)
            local ft = api.nvim_buf_get_option(buf, 'ft')
            if ft:sub(1, 6) == 'dapui_' or ft == 'dap-repl' then
                daptable[win] = true
                return false
            end
            -- Floating wins don't count
            return api.nvim_win_get_config(win).relative == '' and api.nvim_buf_get_option(buf, 'bt') == ''
        end

        local curwin = api.nvim_get_current_win()

        local tabpage = nil
        if #api.nvim_list_tabpages() > 1 then
            tabpage = api.nvim_get_current_tabpage()
        end

        for _, win in ipairs(api.nvim_list_wins()) do
            if tabpage and api.nvim_win_get_tabpage(win) ~= tabpage then goto continue end
            if win == curwin then goto continue end

            if winisfile(win) then
                -- print(api.nvim_buf_get_option(api.nvim_win_get_buf(win), 'ft'))
                return
            end
            ::continue::
        end

        for i, _ in pairs(daptable) do
            api.nvim_win_close(i, true)
        end
    end
})

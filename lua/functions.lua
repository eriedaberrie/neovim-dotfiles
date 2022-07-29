-- Custom functions

local M = {}

local o   = vim.o
local g   = vim.g
local api = vim.api
local fn  = vim.fn
local cmd = vim.cmd

M.set_keymaps = function (maptable)
    local launchmask = g.started_by_firenvim and 8 or (g.vscode and 4 or (vim.isUnix and 2 or 1))
    local opts, nolazyredraw

    for flags, val in pairs(maptable) do
        if flags % (launchmask + launchmask) >= launchmask then
            for _, map in ipairs(val) do
                opts = { noremap = true, silent = true }
                nolazyredraw = false

                if map[4] then
                    if map[4].nolazyredraw then
                        map[4].nolazyredraw = nil
                        nolazyredraw = true
                    end

                    opts = vim.tbl_extend('force', opts, map[4])
                end

                if type(map[3]) == 'function' then
                    if nolazyredraw then
                        opts.callback = function ()
                            local prevlr = o.lazyredraw
                            o.lazyredraw = false
                            map[3]()
                            o.lazyredraw = prevlr
                        end
                    else
                        opts.callback = map[3]
                    end
                    map[3] = ''
                elseif nolazyredraw then
                    if opts.expr then
                        map[3] = [['<Cmd>let g:oldlazyredraw=&lazyredraw<Bar>set nolazyredraw<CR>' . ]] ..
                                map[3] .. [[ . '<Cmd>let &lazyredraw=g:oldlazyredraw<CR>']]
                    else
                        map[3] = [[<Cmd>let g:oldlazyredraw=&lazyredraw<Bar>set nolazyredraw<CR>]] ..
                                map[3] .. [[<Cmd>let &lazyredraw=g:oldlazyredraw<CR>]]
                    end
                end

                for c in map[1]:gmatch'.' do
                    if c == '_' then
                        -- text object mapping
                        api.nvim_set_keymap('x', map[2], map[3], opts)
                        local tempopts = opts
                        tempopts.callback = nil
                        tempopts.expr = nil
                        api.nvim_set_keymap('o', map[2], '<Cmd>norm v' .. map[2] .. '<CR>', tempopts)
                    else
                        api.nvim_set_keymap(c, map[2], map[3], opts)
                    end
                end
            end
        end
    end
end

M.alias = function (lhs, rhs)
    -- WARNING: can't use apostrophes
    cmd.cnoreabbrev('<expr>', lhs, string.format(
        [[(getcmdtype() ==# ':' && getcmdline() ==# '%s') ? '%s' : '%s']],
        lhs, rhs, lhs
    ))
end

M.autoprepend = function (originals, prefix)
    for _, original in ipairs(originals) do
        M.alias(original, prefix .. original)
    end
end

M.selectindent = function (around)
    local startline = api.nvim_win_get_cursor(0)[1]
    local curline = startline
    while curline > 0 and api.nvim_buf_get_lines(0, curline - 1, curline, true)[1] == '' do
        curline = curline - 1
    end
    local startindent = fn.indent(curline)

    local curup = curline
    while curline > 0 do
        local curindent = fn.indent(curline)
        if curindent >= startindent then
            curup = curline
        elseif curindent ~= 0 or api.nvim_buf_get_lines(0, curline - 1, curline, true)[1] ~= '' then
            break
        end
        curline = curline - 1
    end

    local maxline = api.nvim_buf_line_count(0)
    local curdown = startline
    while startline <= maxline do
        local curindent = fn.indent(startline)
        if curindent >= startindent then
            curdown = startline
        elseif curindent ~= 0 or api.nvim_buf_get_lines(0, startline - 1, startline, true)[1] ~= '' then
            break
        end
        startline = startline + 1
    end

    if around then
        curdown = startline - 1
    end

    if fn.mode() ~= 'V' then cmd.normal{ 'V', bang = true } end
    api.nvim_win_set_cursor(0, { curdown, 0 })
    cmd.normal{ 'o', bang = true }
    api.nvim_win_set_cursor(0, { curup, 0 })
end

M.settheme = function (theme)
    if theme then
        o.background = theme
    end
    return cmd.colorscheme('gruvbox')
end

M.toggleshell = function (newshell)
    if not newshell then
        newshell = (o.shell == [[cmd.exe]]) and [[pwsh.exe]] or [[cmd.exe]]
        -- if o.cmdheight == 0 then
        --     o.cmdheight = 1
        -- end
        vim.notify('Set shell to ' .. newshell)
    end

    o.shell = newshell
    if newshell == [[cmd.exe]] then
        o.shellcmdflag = [[/s /c]]
        o.shellxquote  = [["]]
        o.shellpipe    = [[>%s 2>&1]]
        o.shellredir   = [[>%s 2>&1]]
    else
        o.shellcmdflag = [[-NoProfile -NoLogo -NonInteractive -Command]]
        o.shellxquote  = [[]]
        o.shellpipe    = [[|]]
        o.shellredir   = [[>]]
    end
end

M.resizetext = function (newsize)
    local newsizestring = tostring(newsize or 11)
    if o.guifont == '' or o.guifont == nil then
        o.guifont = 'FiraCode NF:h' .. newsizestring
        return
    end

    local newguifont = { o.guifont:match'^[^:]+' }
    for item in o.guifont:gmatch':[^:]+' do
        if item:sub(2, 2) ~= 'h' then
            table.insert(newguifont, item)
        end
    end
    table.insert(newguifont, ':h' .. newsizestring)
    o.guifont = table.concat(newguifont)
end

M.setfiletype = function (group, pattern, ft)
    api.nvim_create_autocmd('BufRead', {
        group = group,
        pattern = pattern,
        command = 'set filetype=' .. ft,
    })
end

M.del_autocmds = function ()
    local augroups = {}
    for _, au in ipairs(api.nvim_get_autocmds{}) do
        if au.group_name then augroups[au.group_name] = true end
    end
    for aug, _ in pairs(augroups) do
        api.nvim_del_augroup_by_name(aug)
    end
    api.nvim_clear_autocmds{}
end


return M

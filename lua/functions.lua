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

    local mapfunc = setmetatable({}, {
        __index = function (t, shortname)
            t[shortname] = function (lhs, rhs, customopts)
                opts = { noremap = true, silent = true }
                nolazyredraw = false

                if customopts then
                    if customopts.nolazyredraw then
                        customopts.nolazyredraw = nil
                        nolazyredraw = true
                    end

                    opts = vim.tbl_extend('force', opts, customopts)
                end

                if type(rhs) == 'function' then
                    if nolazyredraw then
                        opts.callback = function ()
                            local prevlr = o.lazyredraw
                            o.lazyredraw = false
                            rhs()
                            o.lazyredraw = prevlr
                        end
                    else
                        opts.callback = rhs
                    end

                    rhs = ''
                elseif nolazyredraw then
                    if opts.expr then
                        rhs = [['<Cmd>let g:oldlazyredraw=&lazyredraw<Bar>set nolazyredraw<CR>' . ]] ..
                                rhs .. [[ . '<Cmd>let &lazyredraw=g:oldlazyredraw<CR>']]
                    else
                        rhs = [[<Cmd>let g:oldlazyredraw=&lazyredraw<Bar>set nolazyredraw<CR>]] ..
                                rhs .. [[<Cmd>let &lazyredraw=g:oldlazyredraw<CR>]]
                    end
                end

                for c in shortname:gmatch'.' do
                    if c == 'O' then
                        -- text object mapping
                        api.nvim_set_keymap('x', lhs, rhs, opts)
                        local tempopts = opts
                        tempopts.callback = nil
                        tempopts.expr = nil
                        api.nvim_set_keymap('o', lhs, '<Cmd>norm v' .. lhs .. '<CR>', tempopts)
                    else
                        api.nvim_set_keymap(c, lhs, rhs, opts)
                    end
                end
            end
            return t[shortname]
        end,
    })

    for flags, mappings in pairs(maptable) do
        if flags % (launchmask + launchmask) >= launchmask then
            mappings(mapfunc)
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

M.tsdisable = function (_, buf) -- _ is lang
    return api.nvim_buf_line_count(buf) > 5000
end

M.autsdisable = function (lang, buf)
    return M.tsdisable(lang, buf) or not vim.treesitter.require_language(lang, nil, true)
end

M.settheme = function (theme)
    if theme then
        o.background = theme
    end
    cmd.colorscheme('gruvbox')
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

M.resizetext = function (intin, mode)
    local modenum = type(mode) == 'number'

    local newsize
    if modenum then
        newsize = 10 + (intin or vim.v.count1) * mode
    else
        newsize = intin or vim.v.count ~= 0 and vim.v.count or 10
    end

    if o.guifont == '' or o.guifont == nil then
        o.guifont = 'FiraCode NF:h' .. tostring(newsize)
        return
    end

    local newguifont = { o.guifont:match'^[^:]+' }

    for item in o.guifont:gmatch':[^:]+' do
        if item:sub(2, 2) ~= 'h' then
            table.insert(newguifont, item)
        elseif modenum then
            local cursize = tonumber(item:sub(3))
            if cursize then
                newsize = newsize - 10 + cursize
            end
        end
    end
    table.insert(newguifont, ':h' .. tostring(newsize))
    o.guifont = table.concat(newguifont)
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

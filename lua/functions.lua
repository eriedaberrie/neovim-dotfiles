-- Custom functions

local M = {}

local o = vim.o
local g = vim.g

M.set_keymaps = function (maptable)
    local launchmask = g.started_by_firenvim and 8 or (g.vscode and 4 or (vim.isWSL and 2 or 1))
    local opts

    for flags, val in pairs(maptable) do
        if flags % (launchmask + launchmask) >= launchmask then
            for _, map in ipairs(val) do
                opts = { noremap = true, silent = true }
                if map[4] then
                    opts = vim.tbl_extend('force', opts, map[4])
                end

                if type(map[3]) == 'function' then
                    opts.callback = map[3]
                    map[3] = ''
                end

                for c in map[1]:gmatch'.' do
                    vim.api.nvim_set_keymap(c, map[2], map[3], opts)
                end
            end
        end
    end
end

M.alias = function (lhs, rhs)
    -- WARNING: can't use apostrophes
    vim.cmd(string.format(
        [[cnoreabbrev <expr> %s (getcmdtype() ==# ':' && getcmdline() ==# '%s') ? '%s' : '%s']],
        lhs, lhs, rhs, lhs
    ))
end

M.autoprepend = function (originals, prefix)
    for _, original in ipairs(originals) do
        M.alias(original, prefix .. original)
    end
end

M.settheme = function (theme)
    if theme then
        vim.opt.background = theme
    end
    return vim.cmd [[colorscheme gruvbox]]
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


return M

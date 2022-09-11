vim.schedule(function ()
    pcall(function ()
        local name = vim.fn.expand('%:r') .. '.java'
        if vim.fn.filereadable(name) then
            vim.cmd.edit(name)
        end
    end)
end)

-- JDTLS setup

if vim.fn.executable('jdtls') == 0 then
    vim.notify('`jdtls` is not executable', vim.log.levels.WARN)
    return
end

local ps = (not vim.isUnix and vim.opt.shellslash:get()) and '\\' or '/'
local datastd = vim.fn.stdpath('data')
local jdtls_path = datastd .. ps .. 'mason' .. ps .. 'packages' .. ps .. 'jdtls' .. ps
local configuration = jdtls_path .. (vim.isUnix and 'config_linux' or 'config_win')

local jar = vim.fn.glob(jdtls_path .. 'plugins' .. ps .. 'org.eclipse.equinox.launcher_*.jar')

local root_patterns = {
    '.git', 'gradlew', 'gradlew.bat', 'mvnw', 'mvnw.cmd',
    'build.xml', 'pom.xml', 'settings.gradle', 'settings.gradle.kts',
    'build.gradle', 'build.gradle.kts',
}
local root_dir = require'jdtls.setup'.find_root(root_patterns) or vim.fn.expand('%:p:h')

local cache_dir
if vim.env.XDG_CACHE_HOME then
    cache_dir = vim.env.XDG_CACHE_HOME .. ps
else
    cache_dir = (vim.env.HOME or vim.env.USERPROFILE) .. ps .. '.cache' .. ps
end
local data_root = cache_dir .. 'jdtls' .. ps .. 'workspace'
local data_dir

if vim.isUnix then
    data_dir = data_root .. root_dir
else
    data_dir = data_root .. ps .. root_dir:sub(1, 1) .. root_dir:sub(3)
end

local javadeb = datastd .. ps .. 'java-debug' .. ps
local bundle = vim.fn.glob(javadeb .. 'com.microsoft.java.debug.plugin' .. ps .. 'target' .. ps .. 'com.microsoft.java.debug.plugin-*.jar')
-- If can't find package, clone it and build it
if #bundle == 0 then
    bundle = nil
    local job = require'plenary.job'
    job:new {
        command = 'git',
        args = { 'clone', 'https://github.com/microsoft/java-debug.git', javadeb },
        on_exit = function ()
            local mvnwcmd = pjoin(javadeb, 'mvnw')
            if not vim.isUnix then mvnwcmd = mvnwcmd .. '.cmd' end
            job:new {
                command = mvnwcmd,
                cwd = javadeb,
                args = { 'clean', 'install' },
            }:start()
        end
    }:start()
end

local jdtls = require'jdtls'
jdtls.start_or_attach {
    cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', jar,
        '-configuration', configuration,
        '-data', data_dir,
    },
    root_dir = root_dir,
    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            maven = {
                downloadSources = true,
            },
        },
    },
    init_options = {
        bundles = {
            bundle
        },
    },
    on_attach = function (_, buf)
        -- Register keymaps
        local wk = require'which-key'
        wk.register({
            name = 'Java',
            o = { jdtls.organize_imports, 'Organize imports' },
            v = { jdtls.extract_variable, 'Extract variable' },
            c = { jdtls.extract_constant, 'Extract constant' },
            m = { jdtls.extract_method, 'Extract method' },
            D = { require'jdtls.dap'.setup_dap_main_class_configs, 'Setup DAP config' },
        }, { buffer = buf, prefix = '<Leader>eJ' })
        wk.register({
            name = 'Java',
            v = { function () jdtls.extract_variable(true) end, 'Extract variable' },
            c = { function () jdtls.extract_constant(true) end, 'Extract constant' },
            m = { function () jdtls.extract_method(true) end, 'Extract method' },
        }, { buffer = buf, prefix = '<Leader>eJ', mode = 'x' })

        -- Setup dap
        jdtls.setup_dap{ hotcodereplace = 'auto' }
        require'jdtls.setup'.add_commands()
    end,
}

local shared = require('lsp.shared')

vim.lsp.config.sourcekit = {
    cmd = { "/usr/bin/sourcekit-lsp" },
    filetypes = { 'swift', 'objc', 'objcpp', 'c', 'cpp' },
    root_markers = {
        'buildServer.json',
        '*.xcodeproj',
        '*.xcworkspace',
        'compile_commands.json',
        'Package.swift',
        '.git'
    },
    capabilities = vim.tbl_deep_extend('force',
        shared.capabilities,
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = true,
                },
            },
        }
    ),
    on_attach = shared.on_attach,
    get_language_id = function(bufnr, filetype)
        local language_id_map = {
            objc = 'objective-c',
            objcpp = 'objective-cpp',
            swift = 'swift',
            c = 'c',
            cpp = 'cpp',
        }
        return language_id_map[filetype] or filetype
    end,
}

vim.lsp.enable('sourcekit')



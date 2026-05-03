local shared = require('lsp.shared')

local markers = {
    'settings.gradle', 'settings.gradle.kts',
    'build.gradle', 'build.gradle.kts',
    'pom.xml', '.git',
}

vim.lsp.config.kotlin_language_server = {
    cmd = { 'kotlin-lsp', '--stdio' },
    filetypes = { 'kotlin' },
    -- Fall back to the file's directory when no project marker is found,
    -- so single-file scratch projects still get an LSP attached.
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, markers) or vim.fs.dirname(fname)
        on_dir(root)
    end,
    capabilities = shared.capabilities,
    on_attach = shared.on_attach,
}

vim.lsp.enable('kotlin_language_server')

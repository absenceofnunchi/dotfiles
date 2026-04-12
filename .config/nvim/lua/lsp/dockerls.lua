local shared = require('lsp.shared')

vim.lsp.config.dockerls = {
    cmd = { 'docker-langserver', '--stdio' },
    filetypes = { 'dockerfile' },
    root_markers = { 'Dockerfile', '.git' },
    capabilities = shared.capabilities,
    on_attach = shared.on_attach,
}

vim.lsp.enable('dockerls')

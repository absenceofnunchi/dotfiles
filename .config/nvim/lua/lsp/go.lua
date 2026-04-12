local shared = require('lsp.shared')

local mod_cache = nil

local function get_gomodcache()
    if mod_cache then
        return mod_cache
    end

    if vim.system then
        local result = vim.system({ 'go', 'env', 'GOMODCACHE' }, { text = true }):wait()
        if result.code == 0 and result.stdout then
            mod_cache = vim.trim(result.stdout)
            return mod_cache
        end
    end

    local output = vim.fn.system('go env GOMODCACHE')
    if vim.v.shell_error == 0 then
        mod_cache = vim.trim(output)
    end

    return mod_cache
end

vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    capabilities = shared.capabilities,
    on_attach = shared.on_attach,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
}

vim.lsp.enable('gopls')

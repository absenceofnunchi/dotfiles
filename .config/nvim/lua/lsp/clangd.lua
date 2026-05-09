local shared = require('lsp.shared')

-- Custom commands for clangd
local function switch_source_header(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local clangd_client = vim.lsp.get_clients({ name = 'clangd', bufnr = bufnr })[1]
    if not clangd_client then
        vim.notify('clangd client not found', vim.log.levels.WARN)
        return
    end

    local params = { uri = vim.uri_from_bufnr(bufnr) }
    clangd_client:request('textDocument/switchSourceHeader', params, function(err, result)
        if err then
            vim.notify('Error switching source/header: ' .. tostring(err), vim.log.levels.ERROR)
            return
        end
        if not result then
            print('Corresponding file cannot be determined')
            return
        end
        vim.api.nvim_command('edit ' .. vim.uri_to_fname(result))
    end, bufnr)
end

vim.lsp.config.clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
        '.git'
    },
    capabilities = vim.tbl_deep_extend('force',
        shared.capabilities,
        {
            textDocument = {
                completion = {
                    completionItem = {
                        snippetSupport = true
                    },
                    editsNearCursor = true,
                },
            },
            offsetEncoding = { 'utf-8', 'utf-16' },
        }
    ),
    on_attach = function(client, bufnr)
        shared.on_attach(client, bufnr)

        -- Clangd-specific keymaps
        vim.keymap.set('n', '<leader>ch', function()
            switch_source_header(bufnr)
        end, { buffer = bufnr, desc = 'Switch source/header' })
    end,
}

vim.lsp.enable('clangd')

-- User commands
vim.api.nvim_create_user_command('ClangdSwitchSourceHeader', function()
    switch_source_header(0)
end, { desc = 'Switch between source/header' })

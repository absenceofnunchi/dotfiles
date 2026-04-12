local shared = require('lsp.shared')

-- Organize imports command
local function organize_imports()
    local params = {
        command = 'pyright.organizeimports',
        arguments = { vim.uri_from_bufnr(0) },
    }
    local client = vim.lsp.get_active_clients({ name = 'pyright', bufnr = vim.api.nvim_get_current_buf() })[1]
    if client then
        client.request('workspace/executeCommand', params, function(err, _, result)
            if err then
                vim.notify("Error organizing imports: " .. tostring(err), vim.log.levels.ERROR)
            elseif result then
                vim.notify("Imports organized successfully.", vim.log.levels.INFO)
            end
        end)
    else
        vim.notify("Pyright LSP client not found.", vim.log.levels.WARN)
    end
end

-- Infer Python path dynamically
local function get_python_path(workspace)
    if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
    end

    -- Check for common virtual environment directories
    for _, pattern in ipairs({ 'venv', '.venv', 'env', '.env' }) do
        local match = vim.fs.joinpath(workspace, pattern, 'bin', 'python')
        if vim.fn.filereadable(match) == 1 then
            return match
        end
    end

    return 'python3'
end

-- Pyright LSP configuration
vim.lsp.config.pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git'
    },
    capabilities = shared.capabilities,

    on_attach = function(client, bufnr)
        -- Call the shared on_attach first
        shared.on_attach(client, bufnr)

        -- Python-specific keymap for organizing imports
        vim.keymap.set('n', '<leader>oi', organize_imports, {
            buffer = bufnr,
            desc = 'Organize imports'
        })
    end,

    settings = {
        python = {
            pythonPath = get_python_path(vim.fn.getcwd()),
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
                autoImportCompletions = true,
                diagnosticSeverityOverrides = {
                    reportUnusedVariable = "warning",
                    reportUnusedImport = "warning",
                },
            },
        },
    },
}

-- Closing paren-style bracket to match the opening bracket by starting with no indent
vim.g.pyindent_open_paren = 0
vim.g.pyindent_close_paren = 0
-- Closing [] to match the opening square bracket by starting with no indent
vim.g.pyindent_nested_paren = 0
vim.g.pyindent_continue = 0

-- Enable Pyright for Python files
vim.lsp.enable('pyright')

-- Create user command
vim.api.nvim_create_user_command('PyrightOrganizeImports', organize_imports, {
    desc = 'Organize Python imports using Pyright'
})

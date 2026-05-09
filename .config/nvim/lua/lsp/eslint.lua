local shared = require('lsp.shared')

local filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
    'astro',
}

local function fix_all()
    vim.lsp.buf.code_action({
        context = {
            only = { 'source.fixAll.eslint' },
            diagnostics = {},
        },
        apply = true,
    })
end

vim.lsp.config.eslint = {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    filetypes = filetypes,
    root_markers = {
        '.eslintrc',
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        '.eslintrc.json',
        'eslint.config.js',
        'eslint.config.mjs',
        'eslint.config.cjs',
        'eslint.config.ts',
        'package.json',
    },
    capabilities = shared.capabilities,

    settings = {
        validate = 'on',
        packageManager = 'npm',
        useESLintClass = false,
        experimental = {
            useFlatConfig = false,
        },
        codeActionOnSave = {
            enable = false,
            mode = 'all',
        },
        format = true,
        quiet = false,
        onIgnoredFiles = 'off',
        rulesCustomizations = {},
        run = 'onType',
        problems = {
            shortenToSingleLine = false,
        },
        nodePath = '',
        workingDirectory = {
            mode = 'location',
        },
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = 'separateLine',
            },
            showDocumentation = {
                enable = true,
            },
        },
    },

    on_attach = shared.make_on_attach(function(client, bufnr)
        vim.keymap.set('n', '<leader>ef', fix_all, { buffer = bufnr, desc = 'ESLint fix all' })
    end),
}

vim.lsp.enable('eslint')

vim.api.nvim_create_user_command('EslintFixAll', fix_all, { desc = 'Fix all ESLint issues' })

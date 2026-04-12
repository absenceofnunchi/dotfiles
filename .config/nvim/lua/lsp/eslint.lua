local shared = require('lsp.shared')

vim.lsp.config.eslint = {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
        "svelte",
        "astro"
    },
    root_markers = {
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.json",
        "eslint.config.js",
        "package.json",
    },
    capabilities = shared.capabilities,

    settings = {
        validate = "on",
        packageManager = "npm",
        useESLintClass = false,
        experimental = {
            useFlatConfig = false,
        },
        codeActionOnSave = {
            enable = false,
            mode = "all",
        },
        format = true,
        quiet = false,
        onIgnoredFiles = "off",
        rulesCustomizations = {},
        run = "onType",
        problems = {
            shortenToSingleLine = false,
        },
        nodePath = "",
        workingDirectory = {
            mode = "location",
        },
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = "separateLine"
            },
            showDocumentation = {
                enable = true,
            },
        },
    },

    -- Use make_on_attach to add ESLint-specific keymaps
    on_attach = shared.make_on_attach(function(client, bufnr)
        -- ESLint-specific keymap
        vim.keymap.set('n', '<leader>ef', function()
            vim.lsp.buf.code_action({
                context = {
                    only = { 'source.fixAll.eslint' },
                    diagnostics = {},
                },
                apply = true,
            })
        end, { buffer = bufnr, desc = 'ESLint fix all' })
    end),
}

-- Enable ESLint for JavaScript/TypeScript files
vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    callback = function()
        vim.lsp.enable('eslint')
    end,
})

-- ESLint commands
vim.api.nvim_create_user_command('EslintFixAll', function()
    vim.lsp.buf.code_action({
        context = {
            only = { 'source.fixAll.eslint' },
            diagnostics = {},
        },
        apply = true,
    })
end, {
    desc = 'Fix all ESLint issues',
})

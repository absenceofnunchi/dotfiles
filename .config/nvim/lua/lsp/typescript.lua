local shared = require('lsp.shared')

vim.lsp.config.ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx'
    },
    root_markers = {
        'tsconfig.json',
        'jsconfig.json',
        'package.json',
        '.git'
    },
    capabilities = shared.capabilities,
    on_attach = function(client, bufnr)
        shared.on_attach(client, bufnr)

        -- TypeScript-specific keymaps
        vim.keymap.set('n', '<leader>to', function()
            vim.lsp.buf.execute_command({
                command = '_typescript.organizeImports',
                arguments = { vim.api.nvim_buf_get_name(bufnr) },
            })
        end, { buffer = bufnr, desc = 'Organize Imports' })

        vim.keymap.set('n', '<leader>tr', function()
            vim.lsp.buf.execute_command({
                command = '_typescript.removeUnusedImports',
                arguments = { vim.api.nvim_buf_get_name(bufnr) },
            })
        end, { buffer = bufnr, desc = 'Remove Unused Imports' })

        vim.keymap.set('n', '<leader>tf', function()
            vim.lsp.buf.execute_command({
                command = '_typescript.addMissingImports',
                arguments = { vim.api.nvim_buf_get_name(bufnr) },
            })
        end, { buffer = bufnr, desc = 'Add Missing Imports' })
    end,

    init_options = {
        hostInfo = 'neovim',
        preferences = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
        },
    },

    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
        },
    },
}

vim.lsp.enable('ts_ls')

-- User commands for TypeScript operations
vim.api.nvim_create_user_command('TSOrganizeImports', function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.buf.execute_command({
        command = '_typescript.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
    })
end, { desc = 'Organize TypeScript imports' })

vim.api.nvim_create_user_command('TSRemoveUnusedImports', function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.buf.execute_command({
        command = '_typescript.removeUnusedImports',
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
    })
end, { desc = 'Remove unused TypeScript imports' })

vim.api.nvim_create_user_command('TSAddMissingImports', function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.buf.execute_command({
        command = '_typescript.addMissingImports',
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
    })
end, { desc = 'Add missing TypeScript imports' })

-- The prettier from conform.nvim saves files to 2, but the neovim local buffer settings set the indent to 4, such as when you enter 'o'
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

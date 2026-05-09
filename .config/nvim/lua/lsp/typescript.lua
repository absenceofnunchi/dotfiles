local shared = require('lsp.shared')

local filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
}

local inlay_hints = {
    includeInlayParameterNameHints = 'all',
    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayVariableTypeHintsWhenTypeMatchesName = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
}

local function exec_ts_command(command)
    return function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.lsp.buf.execute_command({
            command = command,
            arguments = { vim.api.nvim_buf_get_name(bufnr) },
        })
    end
end

local ts_actions = {
    { keymap = '<leader>to', cmd = 'TSOrganizeImports',     action = '_typescript.organizeImports',     desc = 'Organize Imports' },
    { keymap = '<leader>tr', cmd = 'TSRemoveUnusedImports', action = '_typescript.removeUnusedImports', desc = 'Remove Unused Imports' },
    { keymap = '<leader>tf', cmd = 'TSAddMissingImports',   action = '_typescript.addMissingImports',   desc = 'Add Missing Imports' },
}

vim.lsp.config.ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = filetypes,
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    capabilities = shared.capabilities,
    on_attach = shared.make_on_attach(function(client, bufnr)
        for _, a in ipairs(ts_actions) do
            vim.keymap.set('n', a.keymap, exec_ts_command(a.action), { buffer = bufnr, desc = a.desc })
        end
    end),
    init_options = {
        hostInfo = 'neovim',
        preferences = inlay_hints,
    },
    settings = {
        typescript = { inlayHints = inlay_hints },
        javascript = { inlayHints = inlay_hints },
    },
}

vim.lsp.enable('ts_ls')

for _, a in ipairs(ts_actions) do
    vim.api.nvim_create_user_command(a.cmd, exec_ts_command(a.action), { desc = a.desc })
end

-- prettier from conform.nvim formats with width 2; force buffer indent to match
vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.expandtab = true
    end,
})

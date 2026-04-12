local shared = require('lsp.shared')

vim.lsp.config.lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    capabilities = shared.capabilities,
    on_attach = shared.on_attach,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },
            },
            completion = { callSnippet = 'Replace' },
            telemetry = { enable = false },
            hint = { enable = true },
        },
    },
}

-- Simply enable the server
vim.lsp.enable('lua_ls')

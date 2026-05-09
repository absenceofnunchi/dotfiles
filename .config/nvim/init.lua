-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("options")

require("lazy").setup({
    { import = "plugins" },
}, {
    ui = {
        icons = {
            cmd = "",
            config = "",
            event = "",
            ft = "",
            init = "",
            keys = "",
            plugin = "",
            runtime = "",
            require = "",
            source = "",
            start = "",
            task = "",
            lazy = "",
        },
    },
})

require("autocmds")

for _, server in ipairs({
    "pyright", "clangd", "sourcekit", "typescript", "go",
    "eslint", "info", "html", "tailwindcss", "emmet",
    "kotlin_language_server", "lua_ls", "dockerls",
}) do
    require("lsp." .. server)
end

require("keymaps")

return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    config = function()
        require("nvim-tree").setup({
            view = {
                width = 35,
                side = "left",
                relativenumber = true,
            },
            git = {
                enable = true,
                ignore = false,
            },
            filters = {
                dotfiles = false,
                custom = { "^.git$" },
                git_ignored = false,
            },
            trash = { cmd = nil },
        })
    end,
}

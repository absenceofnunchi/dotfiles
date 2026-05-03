return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "c", "cpp", "json", "javascript", "typescript", "tsx",
                "go", "swift", "python", "dockerfile", "yaml", "bash",
                "markdown", "graphql", "kotlin",
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                disable = {},
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gnn",
                    node_incremental = "gnr",
                    scope_incremental = "gnc",
                    node_decremental = "gnm",
                },
            },
            indent = { enable = true },
        })
    end,
}

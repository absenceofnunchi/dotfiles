return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        local parsers = {
            "c", "cpp", "json", "javascript", "typescript", "tsx",
            "go", "swift", "python", "dockerfile", "yaml", "bash",
            "markdown", "markdown_inline", "graphql", "kotlin",
        }
        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "c", "cpp", "json",
                "javascript", "javascriptreact",
                "typescript", "typescriptreact",
                "go", "swift", "python",
                "dockerfile", "yaml", "bash", "sh",
                "markdown", "graphql", "kotlin",
            },
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}

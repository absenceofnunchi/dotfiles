return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/vim-vsnip",
        "hrsh7th/cmp-vsnip",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-cmdline",
        "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
        require("tailwindcss-colorizer-cmp").setup({ color_square_width = 2 })

        local cmp = require("cmp")
        local lspkind = require("lspkind")

        cmp.setup({
            completion = {
                completeopt = "menu,menuone,preview,noinsert",
            },
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "vsnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item = lspkind.cmp_format({
                        maxwidth = 50,
                        ellipsis_char = "...",
                    })(entry, vim_item)
                    return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
                end,
            },
        })

        vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets"
    end,
}

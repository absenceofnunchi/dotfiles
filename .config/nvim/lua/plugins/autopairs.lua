return {
    "windwp/nvim-autopairs",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true,
            ts_config = {
                go = { "string", "source" },
            },
            disable_filetype = { "TelescopePrompt", "vim" },
            fast_wrap = {},
        })

        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
}

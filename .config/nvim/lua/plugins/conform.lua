return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            mode = { "n", "v" },
            function()
                require("conform").format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 500,
                })
            end,
            desc = "Format file or range",
        },
    },
    opts = {
        formatters_by_ft = {
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            css = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            lua = { "stylua" },
            swift = { "swift_format" },
        },
        format_on_save = {
            timeout_ms = 500,
            lsp_fallback = true,
        },
        formatters = {
            prettier = {
                prepend_args = { "--single-quote", "--trailing-comma", "es5" },
            },
            swift_format = {
                command = "swift-format",
                args = function(_, ctx)
                    local project = vim.fs.find(".swift-format", {
                        upward = true,
                        path = ctx.dirname,
                        type = "file",
                    })[1]
                    local config = project
                        or (vim.fn.stdpath("config") .. "/swift-format.json")
                    return { "--configuration", config, "-" }
                end,
                stdin = true,
            },
        },
    },
}

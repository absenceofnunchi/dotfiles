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
                -- Only auto-format when the project opted into prettier with
                -- its own config. Otherwise prettier silently rewrites the
                -- codebase to whatever defaults are in scope — quotes, line
                -- wrapping, trailing commas — which is rude in projects that
                -- weren't authored with prettier. `stop = HOME` prevents the
                -- walk-up from picking up a stray ~/.prettierrc.
                condition = function(_, ctx)
                    local cfg = {
                        ".prettierrc", ".prettierrc.json",
                        ".prettierrc.yaml", ".prettierrc.yml",
                        ".prettierrc.js", ".prettierrc.cjs",
                        ".prettierrc.mjs", ".prettierrc.toml",
                        "prettier.config.js", "prettier.config.cjs",
                        "prettier.config.mjs",
                    }
                    return vim.fs.find(cfg, {
                        upward = true,
                        path = ctx.dirname,
                        type = "file",
                        stop = vim.env.HOME,
                    })[1] ~= nil
                end,
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

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
        "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
        require("tailwindcss-colorizer-cmp").setup({ color_square_width = 2 })

        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_vscode").lazy_load({
            paths = vim.fn.stdpath("config") .. "/snippets",
        })

        local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0
                and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
                    :sub(col, col)
                    :match("%s") == nil
        end

        -- vim-visual-multi can't replay cmp.confirm() (which mutates the buffer
        -- via nvim_buf_set_text) across its other cursors. Instead, when VM is
        -- active, dismiss the menu and type the completion as keystrokes so VM
        -- sees per-character edits and replays them at every cursor.
        local vm_complete = function(select_first)
            if not vim.b.visual_multi then
                return false
            end
            local entry = cmp.get_selected_entry()
            if not entry and select_first then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                entry = cmp.get_selected_entry()
            end
            if not entry then
                return false
            end
            local word = entry.word or entry:get_word()
            if not word or word == "" then
                return false
            end
            local _, col = unpack(vim.api.nvim_win_get_cursor(0))
            local before = vim.api.nvim_get_current_line():sub(1, col)
            local prefix = before:match("[%w_]+$") or ""
            cmp.close()
            local bs = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
            vim.api.nvim_feedkeys(string.rep(bs, vim.fn.strchars(prefix)) .. word, "n", false)
            return true
        end

        cmp.setup({
            completion = {
                completeopt = "menu,menuone,preview,noinsert",
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            experimental = {
                ghost_text = true,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        if not vm_complete(false) then
                            cmp.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace })
                        end
                        return
                    end
                    -- Expand {|}, [|], (|) into an indented block, and
                    -- ```|```, """|""", '''|''' into a fence (cursor on the
                    -- middle line). cmp's <CR> mapping shadows autopairs's
                    -- expr-mapping, and round-tripping autopairs_cr() through
                    -- feedkeys mangles <CMD>/<Up>/<End> keycodes — so do the
                    -- expansion directly.
                    local pair_close = { ["{"] = "}", ["["] = "]", ["("] = ")" }
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    local line = vim.api.nvim_get_current_line()
                    local prev = col > 0 and line:sub(col, col) or ""
                    local next_ch = line:sub(col + 1, col + 1)
                    if pair_close[prev] == next_ch and next_ch ~= "" then
                        local base = line:match("^%s*") or ""
                        local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
                        local inner = base .. string.rep(" ", sw)
                        vim.api.nvim_set_current_line(line:sub(1, col))
                        vim.api.nvim_buf_set_lines(0, row, row, false, { inner, base .. line:sub(col + 1) })
                        vim.api.nvim_win_set_cursor(0, { row + 1, #inner })
                        return
                    end
                    if col >= 3 then
                        local trip = line:sub(col - 2, col)
                        if (trip == "```" or trip == '"""' or trip == "'''")
                            and line:sub(col + 1, col + 3) == trip then
                            local base = line:match("^%s*") or ""
                            vim.api.nvim_set_current_line(line:sub(1, col))
                            vim.api.nvim_buf_set_lines(0, row, row, false, { base, base .. line:sub(col + 1) })
                            vim.api.nvim_win_set_cursor(0, { row + 1, #base })
                            return
                        end
                    end
                    fallback()
                end, { "i", "s" }),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        if not vm_complete(true) then
                            cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })
                        end
                    elseif luasnip.expand_or_jumpable() and not vim.b.visual_multi then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            sorting = {
                priority_weight = 2,
                comparators = {
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },
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

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline({
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        if not cmp.get_selected_entry() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        end
                        cmp.confirm()
                    else
                        fallback()
                    end
                end, { "c" }),
            }),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
            matching = { disallow_symbol_nonprefix_matching = false },
        })
    end,
}

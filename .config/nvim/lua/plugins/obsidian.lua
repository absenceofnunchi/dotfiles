local vault = "/Users/gin/mac-backup-main/ObsidianVault"

local function grep_to_qf(pattern, title)
    local out = vim.fn.systemlist({ "rg", "-l", "--", pattern, vault })
    if #out == 0 then
        vim.notify("no matches: " .. title, vim.log.levels.INFO)
        return
    end
    vim.fn.setqflist({}, " ", {
        title = title,
        items = vim.tbl_map(function(p) return { filename = p, lnum = 1 } end, out),
    })
    vim.cmd("copen")
end

return {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    event = {
        -- `**/*.md` alone compiles to `.../ObsidianVault/.*/.*\.md$`, whose `/.*/`
        -- REQUIRES a subdirectory — so notes in the vault ROOT (e.g. Yazi.md) never
        -- match and obsidian (hence obsidian-ls completion) never loads. List both.
        { event = { "BufReadPre", "BufNewFile" }, pattern = { vault .. "/*.md", vault .. "/**/*.md" } },
    },
    cmd = { "Obsidian", "Temp", "Today" },
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
        -- Native LSP completion for obsidian's in-process `obsidian-ls` server.
        -- Registered in init() (startup, pre-load) so it exists before obsidian-ls
        -- attaches to the first vault buffer. Trigger chars are hacked to every ASCII
        -- byte so `[[` and `#` pop the menu live; `noselect` stops auto-accepting a
        -- candidate (which would accidentally create a new note). Requires Neovim 0.11+.
        local trigger_chars = {}
        for i = 32, 126 do
            table.insert(trigger_chars, string.char(i))
        end
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("ObsidianLspCompletion", { clear = true }),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client and client.name == "obsidian-ls" then
                    client.server_capabilities.completionProvider.triggerCharacters = trigger_chars
                    vim.bo[ev.buf].completeopt = "menuone,noselect,fuzzy,nosort"
                    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
                end
            end,
        })

        vim.api.nvim_create_user_command("Created", function(o)
            local date = (o.args ~= "" and o.args) or os.date("%Y-%m-%d")
            grep_to_qf("^Date: " .. date, "Created " .. date)
        end, { nargs = "?", desc = "Vault: notes with frontmatter Date == arg (default today)" })

        vim.api.nvim_create_user_command("Tag", function(o)
            local t = o.args
            grep_to_qf([[(?i)(^tags:.*\b]] .. t .. [[\b|#]] .. t .. [[\b)]], "#" .. t)
        end, { nargs = 1, desc = "Vault: notes with tag (frontmatter list or inline #tag)" })

        vim.api.nvim_create_user_command("Today", function()
            vim.cmd("Obsidian today")
        end, { desc = "Obsidian: open today's daily note" })

        vim.api.nvim_create_user_command("Temp", function()
            vim.cmd("Obsidian new_from_template")
        end, { desc = "Obsidian: new note from template" })
    end,
    opts = {
        workspaces = {
            {
                name = "Obsidian",
                path = vault,
            },
        },
        -- You use native vim.lsp.completion (wired in init() above) via the in-process
        -- `obsidian-ls` LSP. The old `nvim_cmp`/`blink` flags are deprecated (stripped +
        -- warned now, removed in obsidian.nvim 4.0) — completion is LSP-only, so omit them.
        -- min_chars = number of query chars before notes are offered (still live; read by
        -- the refs/tags/new completion sources). 1 → `[[f` lists `file.md`; set 0 to mimic
        -- Obsidian (bare `[[` lists the whole vault).
        completion = { min_chars = 1 },
        picker = { name = "telescope.nvim" },
        legacy_commands = false,
        -- Backlink/word counters recompute on every BufEnter/refresh — disable.
        footer = { enabled = false },
        statusline = { enabled = false },
        note_id_func = function(title)
            return (title and title ~= "") and title or require("obsidian.builtin").zettel_id()
        end,
        templates = {
            folder = "Templates",
            date_format = "%Y-%m-%d-%a",
            time_format = "%H:%M",
        },
        daily_notes = {
            folder = "Journal/Daily",
            date_format = "%Y-%m-%d",
            alias_format = "%B %-d, %Y",
            default_tags = { "journal" },
            template = "Daily_Template.md",
        },
        checkbox = {
            order = { " ", "~", "!", ">", "x" },
        },
        ui = {
            enable = true,
            -- Silence the conceallevel=0 warning (issue #286). conceallevel is
            -- window-local, so it can read 0 in a window the FileType autocmd
            -- below never touched (e.g. a picker/split opened by :Obsidian template).
            ignore_conceal_warn = true,
            -- Full-buffer extmark rescan on every TextChanged* — throttle hard.
            update_debounce = 1500,
            max_file_length = 1500,
            bullets = { char = "•", hl_group = "ObsidianBullet" },
            external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            reference_text = { hl_group = "ObsidianRefText" },
            highlight_text = { hl_group = "ObsidianHighlightText" },
            tags = { hl_group = "ObsidianTag" },
            block_ids = { hl_group = "ObsidianBlockID" },
            hl_groups = {
                obsidiantodo = { bold = true, fg = "#f78c6c" },
                obsidiandone = { bold = true, fg = "#89ddff" },
                obsidianrightarrow = { bold = true, fg = "#f78c6c" },
                obsidiantilde = { bold = true, fg = "#ff5370" },
                obsidianimportant = { bold = true, fg = "#d73128" },
                ObsidianBullet = { bold = true, fg = "#89ddff" },
                ObsidianRefText = { underline = true, fg = "#c792ea" },
                ObsidianExtLinkIcon = { fg = "#c792ea" },
                ObsidianTag = { italic = true, fg = "#89ddff" },
                ObsidianBlockID = { italic = true, fg = "#89ddff" },
                ObsidianHighlightText = { bg = "#75662e" },
            },
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)
        local group = vim.api.nvim_create_augroup("ObsidianMarkdown", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            group = group,
            callback = function()
                vim.opt_local.conceallevel = 1
                vim.opt_local.linebreak = true
            end,
        })
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
            pattern = vault .. "/**/*.md",
            group = group,
            callback = function(args)
                vim.keymap.set("n", "gf", "<cmd>Obsidian follow_link<CR>", {
                    buffer = args.buf,
                    silent = true,
                    desc = "Obsidian: follow link",
                })
                vim.keymap.set("n", "<CR>", function()
                    return require("obsidian.api").smart_action()
                end, {
                    buffer = args.buf,
                    expr = true,
                    desc = "Obsidian: follow link / toggle checkbox / show tag / cycle fold",
                })
                vim.keymap.set("n", "]o", function()
                    require("obsidian.api").nav_link("next")
                end, { buffer = args.buf, silent = true, desc = "Obsidian: next link" })
                vim.keymap.set("n", "[o", function()
                    require("obsidian.api").nav_link("prev")
                end, { buffer = args.buf, silent = true, desc = "Obsidian: prev link" })
            end,
        })
    end,
}

local vault = "/Users/gin/Library/Mobile Documents/iCloud~md~obsidian"

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
        { event = { "BufReadPre", "BufNewFile" }, pattern = vault .. "/**/*.md" },
    },
    cmd = { "Obsidian", "Today" },
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
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
    end,
    opts = {
        workspaces = {
            {
                name = "Obsidian",
                path = vault,
            },
        },
        completion = { nvim_cmp = true, min_chars = 2 },
        picker = { name = "telescope.nvim" },
        legacy_commands = false,
        note_id_func = function(title)
            return (title and title ~= "") and title or require("obsidian.builtin").zettel_id()
        end,
        templates = {
            subdir = "Documents/Templates/",
            date_format = "%Y-%m-%d-%a",
            time_format = "%H:%M",
        },
        daily_notes = {
            folder = "Documents/Journal/Daily",
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
            update_debounce = 200,
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
                vim.keymap.set("n", "gx", function()
                    local line = vim.api.nvim_get_current_line()
                    local col = vim.fn.col(".")
                    for s, url, e in line:gmatch("()%[[^%]]*%]%((%S-)%)()") do
                        if col >= s and col < e then
                            vim.ui.open(url)
                            return
                        end
                    end
                    local url = vim.fn.expand("<cWORD>"):match("https?://%S+")
                    if url then
                        vim.ui.open(url)
                    else
                        vim.notify("no URL under cursor", vim.log.levels.WARN)
                    end
                end, { buffer = args.buf, silent = true, desc = "Open external link" })
                vim.api.nvim_buf_create_user_command(args.buf, "Temp", "Obsidian new_from_template", {
                    desc = "Obsidian: insert from template",
                })
            end,
        })
    end,
}

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

-- Planner agenda — same ripgrep→quickfix idiom as :Created/:Tag, but for tasks.
-- All date logic lives in bin/agenda (one source of truth); this just
-- loads its --format=quickfix output, scanning the WHOLE vault (--root vault).
local agenda = vault .. "/bin/agenda"

local function load_agenda_qf(title, extra)
    local cmd = { agenda, "--format", "quickfix", "--root", vault }
    vim.list_extend(cmd, extra or {})
    local lines = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify("agenda failed:\n" .. table.concat(lines, "\n"), vim.log.levels.ERROR)
        return
    end
    if #lines == 0 then
        vim.notify("planner: nothing in '" .. title .. "'", vim.log.levels.INFO)
        return
    end
    local parsed = vim.fn.getqflist({ lines = lines, efm = "%f:%l:%c: %m" })
    vim.fn.setqflist({}, " ", { title = title, items = parsed.items })
    vim.cmd("copen")
end

-- Periodic notes (day→week→month→quarter→year). ALL date math + scaffolding lives
-- in bin/journal (one source of truth); these just shell out. `ensure` creates a
-- note from its skeleton if absent and re-stamps the nav/calendar blocks; `locate`
-- prints a neighbour's path. Dailies are NOT scaffolded here — they stay on
-- obsidian.nvim's :Today template (one daily code path, no accidental day files).
local journal = vault .. "/bin/journal"
local PERIOD_OF_DIR = { Weekly = "week", Monthly = "month", Quarterly = "quarter", Yearly = "year" }
local KIND_OF_DIR   = { Daily = "day", Weekly = "week", Monthly = "month", Quarterly = "quarter", Yearly = "year" }

local function journal_run(args)
    local cmd = { journal }
    vim.list_extend(cmd, args)
    local out = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify("journal: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
        return nil
    end
    return out[#out] -- last stdout line is the absolute path (ensure/locate)
end

local function open_period(period, date)
    -- Resolve the path WITHOUT creating (journal path) so a missing note can prompt
    -- first; existing notes still get re-stamped (nav/calendar) by `ensure` on open.
    local resolve = { "path", "--root", vault, "--period", period }
    if date and date ~= "" then vim.list_extend(resolve, { "--date", date }) end
    local path = journal_run(resolve)
    if not (path and path ~= "") then return end
    if vim.fn.filereadable(path) == 0 then
        local id = vim.fn.fnamemodify(path, ":t:r")
        if vim.fn.confirm(("Create %s note %s?"):format(period, id), "&Yes\n&No", 2) ~= 1 then return end
    end
    local args = { "ensure", "--root", vault, "--period", period }
    if date and date ~= "" then vim.list_extend(args, { "--date", date }) end
    local final = journal_run(args)
    if final and final ~= "" then vim.cmd("edit " .. vim.fn.fnameescape(final)) end
end

-- Scaffold a MISSING period note (week/month/quarter/year) on open — but ASK first, so
-- merely navigating to a not-yet-existing period doesn't silently create a file. Returns
-- the path to open, or nil if it's missing and the user declines. Existing notes,
-- dailies, and non-period notes pass straight through.
local function ensure_path(path)
    if vim.fn.filereadable(path) == 1 then return path end
    local period = PERIOD_OF_DIR[path:match("/Journal/(%w+)/") or ""]
    if not period then return path end
    local id = vim.fn.fnamemodify(path, ":t:r")
    if vim.fn.confirm(("Create %s note %s?"):format(period, id), "&Yes\n&No", 2) ~= 1 then
        return nil -- declined → caller opens nothing
    end
    local p = journal_run({ "ensure", "--root", vault, "--period", period, "--id", id })
    return (p and p ~= "") and p or path
end

-- Zoom from the period note you're in: rel = up (parent) | prev | next (sibling).
local function zoom(rel)
    local dir, stem = vim.api.nvim_buf_get_name(0):match("/Journal/(%w+)/(.+)%.md$")
    local kind = dir and KIND_OF_DIR[dir]
    if not kind then
        vim.notify("Not a journal period note", vim.log.levels.INFO); return
    end
    local out = vim.fn.systemlist({ journal, "locate", "--root", vault, "--period", kind, "--id", stem, "--rel", rel })
    if vim.v.shell_error ~= 0 then
        vim.notify("journal: " .. table.concat(out, "\n"), vim.log.levels.WARN); return
    end
    local path = out[1]
    if not path or path == "" then
        vim.notify("No " .. rel .. " period from " .. stem, vim.log.levels.INFO); return -- e.g. year has no parent
    end
    if path:match("/Journal/Daily/") and vim.fn.filereadable(path) == 0 then
        vim.notify("No daily " .. vim.fn.fnamemodify(path, ":t:r") .. " yet (use :Today)", vim.log.levels.INFO); return
    end
    local target = ensure_path(path)
    if target then vim.cmd("edit " .. vim.fn.fnameescape(target)) end
end

-- Context sidebar — a vertical split showing, for the file you're editing: the
-- 30-day task agenda + recently created/modified (global) + shared-tags +
-- backlinks, as [[wikilinks]]. Event-driven (debounced BufWinEnter) and async
-- (vim.system) — zero idle cost, never blocks typing. Data comes from
-- bin/context (one source of truth); gf/<CR> on a bullet open
-- the target in the MAIN editor window (tasks jump to their exact line) via a
-- line→path map the script emits, so same-basename notes resolve deterministically.
local context_script  = vault .. "/bin/context"
local context_sidebar = vault .. "/bin/.context-sidebar.md" -- real, gitignored
local CTX_WIDTH, CTX_DEBOUNCE = 42, 200

local Context = { buf = nil, win = nil, main_win = nil, timer = nil, path_map = {} }

function Context.is_vault_md(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" or name == context_sidebar or not name:match("%.md$") then
        return false
    end
    return name:sub(1, #vault + 1) == vault .. "/"
end

function Context.is_open()
    return Context.win ~= nil and vim.api.nvim_win_is_valid(Context.win)
end

-- split the script's %%context-map block into Context.path_map; show the rest.
-- caller MUST split stdout WITHOUT trimming empties, so line numbers stay aligned.
local function context_apply(lines)
    if not (Context.buf and vim.api.nvim_buf_is_valid(Context.buf)) then return end
    local display, map, in_map = {}, {}, false
    for _, l in ipairs(lines) do
        if l == "%%context-map" then
            in_map = true
        elseif in_map then
            if l == "%%" then break end
            local n, lnum, p = l:match("^(%d+)::(%d+)::(.+)$")
            if n then map[tonumber(n)] = { path = p, lnum = tonumber(lnum) } end
        else
            display[#display + 1] = l
        end
    end
    Context.path_map = map
    vim.bo[Context.buf].modifiable = true
    vim.api.nvim_buf_set_lines(Context.buf, 0, -1, false, display)
    vim.bo[Context.buf].modifiable = false
    vim.bo[Context.buf].modified = false -- never nag about the unsaved scratch buffer
end

local function context_refresh(file)
    vim.system(
        { context_script, "--root", vault, "--file", file, "--format", "md", "--limit", "8" },
        { text = true },
        function(res)
            if res.code ~= 0 then return end
            local lines = vim.split(res.stdout, "\n", { plain = true }) -- keep empties!
            vim.schedule(function() context_apply(lines) end)
        end
    )
end

function Context.schedule_refresh()
    local cur = vim.api.nvim_get_current_buf()
    if cur == Context.buf or not Context.is_vault_md(cur) then return end
    Context.main_win = vim.api.nvim_get_current_win() -- where gf should land
    local file = vim.api.nvim_buf_get_name(cur)
    if Context.timer then Context.timer:stop() end
    Context.timer = vim.uv.new_timer()
    Context.timer:start(CTX_DEBOUNCE, 0, function()
        Context.timer:stop()
        Context.timer:close()
        Context.timer = nil
        vim.schedule(function()
            if Context.is_open() then context_refresh(file) end
        end)
    end)
end

-- gf/<CR> in the sidebar: open the target in the MAIN window via the map.
local function context_open_under_cursor()
    local entry = Context.path_map[vim.api.nvim_win_get_cursor(0)[1]]
    if not entry then return end -- header / blank / _none_ line
    -- A not-yet-created week/month/quarter/year (e.g. a Calendar link) prompts to
    -- scaffold from its skeleton; decline → stay in the sidebar and open nothing.
    -- ensure_path is a no-op for existing notes, dailies, and non-period notes.
    local dest = ensure_path(entry.path)
    if not dest then return end
    local target = Context.main_win
    if not (target and vim.api.nvim_win_is_valid(target)) or target == Context.win then
        target = nil
        for _, w in ipairs(vim.api.nvim_list_wins()) do
            if w ~= Context.win then target = w; break end
        end
    end
    if target then vim.fn.win_gotoid(target) end
    vim.cmd("edit " .. vim.fn.fnameescape(dest))
    if entry.lnum and entry.lnum > 1 then -- tasks jump to their exact line
        pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, 0 })
    end
end

function Context.open()
    local origin = vim.api.nvim_get_current_win()
    vim.cmd("botright vsplit " .. vim.fn.fnameescape(context_sidebar))
    Context.win = vim.api.nvim_get_current_win()
    Context.buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_width(Context.win, CTX_WIDTH)
    vim.wo[Context.win].number = false
    vim.wo[Context.win].relativenumber = false
    vim.wo[Context.win].winfixwidth = true
    vim.wo[Context.win].conceallevel = 1 -- render [[ ]] here too
    vim.wo[Context.win].concealcursor = "nc"
    vim.wo[Context.win].wrap = false
    vim.bo[Context.buf].buflisted = false
    vim.bo[Context.buf].swapfile = false
    vim.bo[Context.buf].bufhidden = "hide"
    -- our own gf/<CR> (set AFTER the split so they win over obsidian's vault gf)
    vim.keymap.set("n", "gf", context_open_under_cursor, { buffer = Context.buf, silent = true, desc = "Context: open in main window" })
    vim.keymap.set("n", "<CR>", context_open_under_cursor, { buffer = Context.buf, silent = true, desc = "Context: open in main window" })
    vim.keymap.set("n", "q", function() Context.close() end, { buffer = Context.buf, silent = true, desc = "Context: close sidebar" })
    if vim.api.nvim_win_is_valid(origin) then
        vim.api.nvim_set_current_win(origin) -- restore focus; don't steal it
    end
    Context.schedule_refresh()
end

function Context.close()
    if Context.is_open() then vim.api.nvim_win_close(Context.win, true) end
    Context.win, Context.buf = nil, nil
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

        -- Planner task views (whole vault) → quickfix; <CR> jumps to the task line.
        vim.api.nvim_create_user_command("Agenda", function()
            load_agenda_qf("Agenda — today", { "--bucket", "focus" })
        end, { desc = "Planner: appts + overdue + today (whole vault)" })

        vim.api.nvim_create_user_command("Overdue", function()
            load_agenda_qf("Overdue", { "--bucket", "overdue" })
        end, { desc = "Planner: overdue tasks" })

        vim.api.nvim_create_user_command("Tasks", function()
            load_agenda_qf("All scheduled", { "--bucket", "all" })
        end, { desc = "Planner: everything scheduled" })

        vim.api.nvim_create_user_command("Week", function(o)
            local n = (o.args ~= "" and o.args) or "7"
            load_agenda_qf("Next " .. n .. " days", { "--bucket", "week", "--days", n })
        end, { nargs = "?", desc = "Planner: upcoming N days (default 7)" })

        -- Periodic NOTE navigation (adjective commands; the noun :Week stays the agenda
        -- view above). :Daily keeps obsidian.nvim's template; the rest call bin/journal.
        vim.api.nvim_create_user_command("Daily", function()
            vim.cmd("Obsidian today")
        end, { desc = "Journal: open today's daily note" })
        for _, spec in ipairs({ { "Weekly", "week" }, { "Monthly", "month" },
                                { "Quarterly", "quarter" }, { "Yearly", "year" } }) do
            vim.api.nvim_create_user_command(spec[1], function(o)
                open_period(spec[2], o.args)
            end, { nargs = "?", desc = "Journal: open/create the " .. spec[2] .. " note (default today; arg: YYYY-MM-DD)" })
        end

        vim.api.nvim_create_user_command("Context", function()
            if Context.is_open() then Context.close() else Context.open() end
        end, { desc = "Toggle the context sidebar" })
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

        -- Context sidebar: refresh per file (debounced/async; zero idle cost when
        -- closed) and auto-open on the FIRST vault note — so the vimo workspace
        -- gets it automatically while non-vault (code) sessions stay untouched.
        -- The flag means a manual close stays closed (reopen with :Context).
        local ctx_auto_opened = false
        local function context_tick()
            if Context.is_open() then
                Context.schedule_refresh()
            elseif not ctx_auto_opened and Context.is_vault_md(vim.api.nvim_get_current_buf()) then
                ctx_auto_opened = true
                Context.open()
            end
        end
        vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
            group = group,
            callback = context_tick,
        })

        -- Keep the sidebar at its fixed width across terminal/tmux geometry changes.
        -- winfixwidth resists INTERNAL nvim resizes, but when a tmux pane (e.g. the
        -- <prefix> C Claude split, which shrinks nvim by 40 cols) opens/closes the whole
        -- nvim process resizes — the sidebar can be squeezed below CTX_WIDTH and is not
        -- restored on grow-back. Re-assert the width on every resize while it's open.
        vim.api.nvim_create_autocmd("VimResized", {
            group = group,
            callback = function()
                if Context.is_open() then
                    pcall(vim.api.nvim_win_set_width, Context.win, CTX_WIDTH)
                end
            end,
        })

        -- Toggle the sidebar. The :Context command already toggles; bind a key to it
        -- (same idiom as <leader>e → :NvimTreeToggle). <leader> is the default `\`.
        vim.keymap.set("n", "<leader>tc", "<cmd>Context<CR>",
            { silent = true, desc = "Toggle the context sidebar" })

        -- Journal navigation under <leader>j (safe everywhere): open this day/week/
        -- month/quarter/year, or zoom out/sideways from the period note you're in.
        for key, cmd in pairs({ jd = "Daily", jw = "Weekly", jm = "Monthly", jq = "Quarterly", jy = "Yearly" }) do
            vim.keymap.set("n", "<leader>" .. key, "<cmd>" .. cmd .. "<CR>",
                { silent = true, desc = "Journal: open " .. cmd:lower() })
        end
        vim.keymap.set("n", "<leader>ju", function() zoom("up") end,   { silent = true, desc = "Journal: zoom out (parent period)" })
        vim.keymap.set("n", "<leader>j]", function() zoom("next") end, { silent = true, desc = "Journal: next sibling period" })
        vim.keymap.set("n", "<leader>j[", function() zoom("prev") end, { silent = true, desc = "Journal: prev sibling period" })

        -- The bracket pairs ALSO zoom, but ONLY inside Journal/ period notes, so they
        -- don't shadow Vim's ]p/]P/[P (paste-with-reindent) anywhere else. [p is left alone.
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
            group = group,
            pattern = vault .. "/Journal/*/*.md",
            callback = function(a)
                vim.keymap.set("n", "]p", function() zoom("up") end,   { buffer = a.buf, silent = true, desc = "Journal: zoom out (parent period)" })
                vim.keymap.set("n", "]P", function() zoom("next") end, { buffer = a.buf, silent = true, desc = "Journal: next sibling period" })
                vim.keymap.set("n", "[P", function() zoom("prev") end, { buffer = a.buf, silent = true, desc = "Journal: prev sibling period" })
            end,
        })

        vim.schedule(context_tick) -- catch the buffer that triggered plugin load
    end,
}

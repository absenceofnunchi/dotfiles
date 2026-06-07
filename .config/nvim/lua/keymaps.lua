-- Delete the current buffer's file — but confirm first, and route to macOS Trash
-- (the `trash` CLI if installed, which keeps Finder "Put Back"; otherwise a
-- collision-safe move into ~/.Trash) instead of an irreversible unlink.
local function trash_current_file()
    local file = vim.fn.expand("%:p")
    if file == "" or vim.fn.filereadable(file) == 0 then
        vim.notify("No saved file in this buffer to delete", vim.log.levels.WARN)
        return
    end
    if vim.fn.confirm("Move to Trash:  " .. vim.fn.fnamemodify(file, ":~") .. " ?", "&Yes\n&No", 2) ~= 1 then
        return
    end
    if vim.fn.executable("trash") == 1 then
        vim.fn.system({ "trash", file })
    else
        local dest = vim.fn.expand("~/.Trash/") .. vim.fn.fnamemodify(file, ":t")
        if vim.fn.filereadable(dest) == 1 or vim.fn.isdirectory(dest) == 1 then
            dest = dest .. "." .. os.date("%Y%m%d%H%M%S") -- don't clobber a same-named trashed file
        end
        vim.fn.system({ "mv", file, dest })
    end
    if vim.v.shell_error ~= 0 then
        vim.notify("Trash failed for " .. file, vim.log.levels.ERROR)
        return
    end
    vim.cmd("bdelete!")
    vim.notify("Trashed " .. vim.fn.fnamemodify(file, ":t"), vim.log.levels.INFO)
end

vim.keymap.set("n", "<Leader>rm", trash_current_file, { desc = "Move current file to Trash" })
vim.keymap.set("n", "<Leader>tn", ":tabnext<CR>", { silent = true, desc = "Next tab" })
vim.keymap.set("n", "<Leader>tp", ":tabprevious<CR>", { silent = true, desc = "Previous tab" })
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<Leader>bp", ":bprev<CR>", { silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree", silent = true })

-- Resize panes
vim.keymap.set("n", "<C-M-l>", ":vertical resize -5<CR>", { silent = true, desc = "Shrink window width" })
vim.keymap.set("n", "<C-M-h>", ":vertical resize +5<CR>", { silent = true, desc = "Grow window width" })
vim.keymap.set("n", "<C-M-k>", ":resize +5<CR>", { silent = true, desc = "Grow window height" })
vim.keymap.set("n", "<C-M-j>", ":resize -5<CR>", { silent = true, desc = "Shrink window height" })
vim.keymap.set("n", "<C-S-Up>", ":resize +5<CR>", { silent = true, desc = "Grow window height" })
vim.keymap.set("n", "<C-S-Down>", ":resize -5<CR>", { silent = true, desc = "Shrink window height" })
vim.keymap.set("n", "<C-S-Left>", ":vertical resize -5<CR>", { silent = true, desc = "Shrink window width" })
vim.keymap.set("n", "<C-S-Right>", ":vertical resize +5<CR>", { silent = true, desc = "Grow window width" })

-- Toggle a single terminal buffer (preserves shell state)
local function toggle_terminal()
    local term_buf
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            term_buf = buf
            break
        end
    end
    if term_buf then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == term_buf then
                vim.api.nvim_win_hide(win)
                return
            end
        end
        vim.cmd("belowright sbuffer " .. term_buf)
        vim.cmd("startinsert")
        return
    end
    vim.cmd("belowright split | terminal")
end
vim.keymap.set("n", "<C-t>", toggle_terminal, { silent = true, desc = "Toggle terminal" })

-- Terminal mode: window navigation and escape
local function term_nav(key)
    return string.format("<C-\\><C-N><C-w>%s", key)
end
vim.keymap.set("t", "<C-Left>", term_nav("h"), { silent = true, desc = "Move to left window from terminal" })
vim.keymap.set("t", "<C-Down>", term_nav("j"), { silent = true, desc = "Move to lower window from terminal" })
vim.keymap.set("t", "<C-Up>", term_nav("k"), { silent = true, desc = "Move to upper window from terminal" })
vim.keymap.set("t", "<C-Right>", term_nav("l"), { silent = true, desc = "Move to right window from terminal" })
vim.keymap.set("t", "<C-a>h", term_nav("h"), { silent = true, desc = "Move to left window from terminal" })
vim.keymap.set("t", "<C-a>j", term_nav("j"), { silent = true, desc = "Move to lower window from terminal" })
vim.keymap.set("t", "<C-a>k", term_nav("k"), { silent = true, desc = "Move to upper window from terminal" })
vim.keymap.set("t", "<C-a>l", term_nav("l"), { silent = true, desc = "Move to right window from terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, desc = "Leave terminal mode" })

-- Window navigation
vim.keymap.set("n", "<C-Left>", "<C-w>h", { silent = true, desc = "Move to left window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { silent = true, desc = "Move to lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { silent = true, desc = "Move to upper window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { silent = true, desc = "Move to right window" })
vim.keymap.set("n", "<C-a>h", "<C-w>h", { silent = true, desc = "Move to left window" })
vim.keymap.set("n", "<C-a>j", "<C-w>j", { silent = true, desc = "Move to lower window" })
vim.keymap.set("n", "<C-a>k", "<C-w>k", { silent = true, desc = "Move to upper window" })
vim.keymap.set("n", "<C-a>l", "<C-w>l", { silent = true, desc = "Move to right window" })

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- Open the URL/file under the cursor in the OS default browser (vim.ui.open).
-- <cfile> grabs whole URLs (query strings included) but only when the cursor is
-- ON the URL — for a markdown [text](url) the cursor usually sits on the text, so
-- scan the line for the [..](url) span first, then fall back to a bare URL/<cfile>.
vim.keymap.set("n", "gx", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col(".")
    local url
    for s, target, e in line:gmatch("()%[[^%]]*%]%((%S-)%)()") do
        if col >= s and col < e then
            url = target
            break
        end
    end
    if not url or url == "" then
        url = vim.fn.expand("<cWORD>"):match("https?://%S+") or vim.fn.expand("<cfile>")
    end
    if url and url ~= "" then
        vim.ui.open(url)
    else
        vim.notify("gx: no URL or file under cursor", vim.log.levels.WARN)
    end
end, { silent = true, desc = "Open URL/file under cursor (default browser)" })

-- Zoom
vim.keymap.set("n", "<Leader>rz", "<C-w>_<C-w>|", { desc = "Full size" })
vim.keymap.set("n", "<Leader>rZ", "<C-w>=", { desc = "Even size" })

-- Run an Android project's scripts/run.sh in a dedicated bottom terminal.
-- <Leader>ra opens a picker over attached devices + available AVDs and runs
-- the script with ANDROID_SERIAL or AVD set accordingly.
-- <Leader>rA reruns the last selection without prompting.
local run_android_buf
local run_android_last

local function list_attached()
    local out = {}
    for _, line in ipairs(vim.fn.systemlist({ "adb", "devices", "-l" })) do
        local serial = line:match("^(%S+)%s+device%f[%s\0]")
        if serial then
            local model = line:match("model:(%S+)")
            table.insert(out, { serial = serial, model = model and model:gsub("_", " ") or "" })
        end
    end
    return out
end

local function list_avds()
    if vim.fn.executable("emulator") == 0 then return {} end
    local lines = vim.fn.systemlist({ "emulator", "-list-avds" })
    local out = {}
    for _, name in ipairs(lines) do
        if name ~= "" and not name:match("^INFO") then table.insert(out, name) end
    end
    return out
end

local function running_avd_serial(name)
    for _, dev in ipairs(list_attached()) do
        if dev.serial:match("^emulator%-") then
            local got = vim.fn.system({ "adb", "-s", dev.serial, "emu", "avd", "name" })
            local first = (vim.split(got, "\n")[1] or ""):gsub("%s+$", "")
            if first == name then return dev.serial end
        end
    end
end

local function spawn_run(choice)
    local start = vim.fn.expand("%:p:h")
    if start == "" then start = vim.fn.getcwd() end
    local script = vim.fs.find("scripts/run.sh", { upward = true, path = start, type = "file" })[1]
    if not script then
        vim.notify("scripts/run.sh not found above " .. start, vim.log.levels.ERROR)
        return
    end
    local root = vim.fs.dirname(vim.fs.dirname(script))

    if run_android_buf and vim.api.nvim_buf_is_valid(run_android_buf) then
        vim.api.nvim_buf_delete(run_android_buf, { force = true })
    end

    local env = vim.fn.environ()
    if choice.kind == "serial" then env.ANDROID_SERIAL = choice.value end
    if choice.kind == "avd" then env.AVD = choice.value end

    vim.cmd("belowright 15split | enew")
    run_android_buf = vim.api.nvim_get_current_buf()
    vim.fn.jobstart({ "bash", script }, { cwd = root, env = env, term = true })
    vim.api.nvim_buf_set_name(run_android_buf, "[Run Android: " .. choice.label .. "]")
    vim.cmd("startinsert")
    run_android_last = choice
end

local function pick_and_run()
    local items = {}
    for _, dev in ipairs(list_attached()) do
        local label = dev.model ~= "" and (dev.serial .. " (" .. dev.model .. ")") or dev.serial
        table.insert(items, { label = "[connected] " .. label, kind = "serial", value = dev.serial })
    end
    for _, name in ipairs(list_avds()) do
        local serial = running_avd_serial(name)
        if serial then
            table.insert(items, {
                label = "[avd-running] " .. name .. " → " .. serial,
                kind = "serial",
                value = serial,
            })
        else
            table.insert(items, { label = "[avd-boot] " .. name, kind = "avd", value = name })
        end
    end
    if #items == 0 then
        vim.notify("No connected devices or AVDs found.", vim.log.levels.ERROR)
        return
    end
    vim.ui.select(items, {
        prompt = "Run Android on:",
        format_item = function(item) return item.label end,
    }, function(choice)
        if choice then spawn_run(choice) end
    end)
end

vim.keymap.set("n", "<Leader>ra", pick_and_run, { silent = true, desc = "Run Android (pick device)" })
vim.keymap.set("n", "<Leader>rA", function()
    if run_android_last then
        spawn_run(run_android_last)
    else
        pick_and_run()
    end
end, { silent = true, desc = "Run Android (rerun last)" })

-- Tab navigation with \
for i = 1, 9 do
    vim.keymap.set("n", "\\" .. i, ":tabn " .. i .. "<CR>", { silent = true, desc = "Go to tab " .. i })
end

-- Harpoon
local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon Add File" })
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon to file 1" })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon to file 2" })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon to file 3" })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon to file 4" })

-- Diagnostics float (cursor must be on the error)
vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Line diagnostics" })

-- Center cursor after scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
vim.keymap.set("n", "<C-f>", "<C-f>zz", { desc = "Page down (centered)" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { desc = "Page up (centered)" })

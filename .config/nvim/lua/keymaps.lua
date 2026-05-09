vim.keymap.set("n", "<Leader>rm", function()
    vim.fn.delete(vim.fn.expand("%"))
    vim.cmd("bdelete!")
end, { desc = "Delete current file" })
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

-- Open URL/file under cursor in Brave
vim.keymap.set("n", "gx", function()
    vim.fn.jobstart({ "open", "-a", "Brave Browser", vim.fn.expand("<cfile>") }, { detach = true })
end, { silent = true, desc = "Open URL/file under cursor in Brave" })

-- Zoom
vim.keymap.set("n", "<Leader>rz", "<C-w>_<C-w>|", { desc = "Full size" })
vim.keymap.set("n", "<Leader>rZ", "<C-w>=", { desc = "Even size" })

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

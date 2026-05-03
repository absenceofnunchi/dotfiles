vim.keymap.set("n", "<Leader>rm", function()
    vim.fn.delete(vim.fn.expand("%"))
end, { desc = "Delete current file" })
vim.keymap.set("n", "<Leader>tn", ":tabnext<CR>", { silent = true })
vim.keymap.set("n", "<Leader>tp", ":tabprevious<CR>", { silent = true })
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<Leader>bp", ":bprev<CR>", { silent = true })
vim.keymap.set("n", "<leader>c", ":s/^/-- /<CR>", { silent = true, desc = "Comment line (-- )" })
vim.keymap.set("n", "<leader>u", [[:s/^--\s*//<CR>]], { silent = true, desc = "Uncomment line (-- )" })

vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree", silent = true })

-- Resize panes
vim.keymap.set("n", "<C-M-l>", ":vertical resize -5<CR>", { silent = true })
vim.keymap.set("n", "<C-M-h>", ":vertical resize +5<CR>", { silent = true })
vim.keymap.set("n", "<C-M-k>", ":resize +5<CR>", { silent = true })
vim.keymap.set("n", "<C-M-j>", ":resize -5<CR>", { silent = true })
vim.keymap.set("n", "<C-S-Up>", ":resize +5<CR>", { silent = true })
vim.keymap.set("n", "<C-S-Down>", ":resize -5<CR>", { silent = true })
vim.keymap.set("n", "<C-S-Left>", ":vertical resize -5<CR>", { silent = true })
vim.keymap.set("n", "<C-S-Right>", ":vertical resize +5<CR>", { silent = true })

-- Toggle a single terminal buffer
local function toggle_terminal()
    for _, buf_nr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf_nr].buftype == "terminal" then
            vim.api.nvim_buf_delete(buf_nr, { force = true })
            return
        end
    end
    vim.cmd("belowright split | terminal")
end
vim.keymap.set("n", "<C-t>", toggle_terminal, { silent = true, desc = "Toggle terminal" })

-- Terminal mode: window navigation and escape
local function term_nav(key)
    return string.format("<C-\\><C-N><C-w>%s", key)
end
vim.keymap.set("t", "<C-Left>", term_nav("h"), { silent = true })
vim.keymap.set("t", "<C-Down>", term_nav("j"), { silent = true })
vim.keymap.set("t", "<C-Up>", term_nav("k"), { silent = true })
vim.keymap.set("t", "<C-Right>", term_nav("l"), { silent = true })
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", { silent = true })

-- Window navigation
vim.keymap.set("n", "<C-a>h", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-a>j", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-a>k", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-a>l", "<C-w>l", { silent = true })
vim.keymap.set("n", "<C-Left>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { silent = true })

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- Open URL/file under cursor in Brave
vim.keymap.set("n", "gx", function()
    vim.fn.jobstart({ "open", "-a", "Brave Browser", vim.fn.expand("<cfile>") }, { detach = true })
end, { silent = true })

-- Zoom
vim.keymap.set("n", "<Leader>rz", "<C-w>_<C-w>|", { desc = "Full size" })
vim.keymap.set("n", "<Leader>rZ", "<C-w>=", { desc = "Even size" })

-- Tab navigation with \
vim.keymap.set("n", "\\gt", ":tabnext<CR>", { silent = true })
for i = 1, 9 do
    vim.keymap.set("n", "\\" .. i, ":tabn " .. i .. "<CR>", { silent = true })
end

-- Harpoon
local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon Add File" })
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)

-- Diagnostics float (cursor must be on the error)
vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Line diagnostics" })

-- Center cursor after scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")

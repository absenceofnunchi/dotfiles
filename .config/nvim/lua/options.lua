-- OSC 52 copy/paste from remote machine
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
}

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.spelllang = "en"

vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.inccommand = "split"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.wildmode = "list:longest,list:full"
vim.opt.fileencoding = "utf-8"
vim.opt.wildignore:append({
    "*.o", "*~", "*.pyc", "*.class", "*.swp", "*.bak",
    "*.DS_Store", "*.git", "*.svn", "*.hg", "*.fzf*",
    "*/node_modules/*",
})

vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]

vim.diagnostic.config({
    virtual_text = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
        },
    },
})

-- Rounded borders for all floats (hover, signatureHelp, diagnostics, ...)
vim.o.winborder = "rounded"

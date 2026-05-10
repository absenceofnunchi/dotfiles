-- Clipboard: OSC 52 for copy (works locally and over SSH via tmux's `set-clipboard on`),
-- pbpaste for paste. Never OSC 52 paste — it blocks nvim waiting for a terminal response
-- that tmux popups + many terminals never send ("Waiting for OSC 52 response"). To paste
-- the system clipboard into a remote nvim, use Cmd+V in insert mode (bracketed paste
-- from the terminal — no provider needed on the remote side).
vim.opt.clipboard = "unnamedplus"
local osc52 = require("vim.ui.clipboard.osc52")
local paste_fn = vim.fn.executable("pbpaste") == 1
    and function() return vim.split(vim.fn.system("pbpaste"), "\n") end
    or function() return vim.split(vim.fn.getreg('"'), "\n") end
vim.g.clipboard = {
    name = "osc52-copy + pbpaste",
    copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
    },
    paste = {
        ["+"] = paste_fn,
        ["*"] = paste_fn,
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
vim.opt.fillchars:append({ eob = " " }) -- hide ~ on empty lines past end-of-buffer
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

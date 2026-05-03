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
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.spell = true
vim.opt.spelllang = "en"

vim.opt.signcolumn = "number"
vim.opt.termguicolors = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.inccommand = "split"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest,list:full"
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.autoread = true
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.wildignore:append({
    "*.o", "*~", "*.pyc", "*.class", "*.swp", "*.bak",
    "*.DS_Store", "*.git", "*.svn", "*.hg", "*.fzf*",
    "*/node_modules/*",
})

vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]

-- Diagnostics
vim.diagnostic.config({ virtual_text = true })
vim.fn.sign_define("LspDiagnosticsSignError", { text = "", texthl = "LspDiagnosticsSignError" })
vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "", texthl = "LspDiagnosticsSignWarning" })

-- LSP floats with rounded borders and size limits
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded", max_width = 80, max_height = 20,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded", max_width = 80, max_height = 20,
})

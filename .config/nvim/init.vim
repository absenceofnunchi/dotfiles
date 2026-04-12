set number
set noswapfile
"nnoremap <leader>t :NvimTreeToggle<CR>
nnoremap <Leader>rm :call delete(expand('%')) \
nnoremap <Leader>tn :tabnext<CR>
nnoremap <Leader>tp :tabprevious<CR>
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprev<CR>
nnoremap <leader>c :s/^/-- /<CR>
nnoremap <leader>u :s/^--\s*//<CR>
"nnoremap <Leader>d :call delete(expand('%'))<CR>
command! -nargs=1 DelFile call delete(<q-args>)

lua << EOF

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
    })
end

-- OSC 52 Copy and paste from remote machine
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
vim.opt.rtp:prepend(lazypath)
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

vim.diagnostic.config({
    virtual_text = true,
})
vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest,list:full" -- don't insert, show options
vim.opt.signcolumn = "number"
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.spelllang = "en"
vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.backup = false
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.expandtab = true
vim.opt.inccommand = "split"
-- vim.opt.scrolloff = 10
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.backspace = {"start", "eol", "indent"}
vim.opt.wildignore:append({"*.o", "*~", "*.pyc", "*.class", "*.swp", "*.bak", "*.DS_Store", "*.git", "*.svn", "*.hg", "*.fzf*", "*/node_modules/*"})

vim.fn.sign_define("LspDiagnosticsSignError", {text = "", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "", texthl = "LspDiagnosticsSignWarning"})
vim.cmd([[command! Temp ObsidianTemplate]])
vim.g.netrw_list_hide = '\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'

-- Disable spell checking for specific syntax groups
vim.api.nvim_command('autocmd FileType go syntax match SpellBad "\\<\\w\\+\\>" contains=@NoSpell')
vim.api.nvim_command('autocmd FileType go setlocal spell spelllang=en')
vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    command = "wincmd L",
})

-- The external changes done by LazyGit should be reflected while the NeoVim session is running
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})
vim.api.nvim_exec([[
  autocmd FileType swift setlocal nospell
]], false)
-- vim.lsp.set_log_level("debug")
-- Enable wrapping in LSP floating windows
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "rounded",
    max_width = 80,  -- You can adjust the max width
    max_height = 20,
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = "rounded",
    max_width = 80,
    max_height = 20,
  }
)

require('plugins')
require('lsp.pyright')
require('lsp.clangd')
require('lsp.sourcekit')
require('lsp.typescript')
require('lsp.go')
require('lsp.eslint')
require('lsp.info')
require('lsp.html')
require('lsp.tailwindcss')
require('lsp.emmet')
require('keymaps')

EOF


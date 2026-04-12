local shared = require('lsp.shared')

-- HTML
vim.lsp.config.html = {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html', 'javascriptreact', 'typescriptreact' },
  root_markers = { 'package.json', '.git' },
  capabilities = shared.capabilities,
  on_attach = shared.on_attach,
  settings = {
    html = {
      format = { enable = true },
      validate = { scripts = true, styles = true },
    },
  },
}

-- CSS
vim.lsp.config.cssls = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  capabilities = shared.capabilities,
  on_attach = shared.on_attach,
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
}

vim.lsp.enable({ 'html', 'cssls' })

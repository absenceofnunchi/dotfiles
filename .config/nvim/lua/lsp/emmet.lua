local shared = require('lsp.shared')

vim.lsp.config.emmet_language_server = {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'scss',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = { '.git', 'package.json' },
  capabilities = shared.capabilities,
  on_attach = shared.on_attach,
  init_options = {
    showSuggestionsAsSnippets = true,
    showExpandedAbbreviation = 'always',
    showAbbreviationSuggestions = true,
  },
}

vim.lsp.enable('emmet_language_server')

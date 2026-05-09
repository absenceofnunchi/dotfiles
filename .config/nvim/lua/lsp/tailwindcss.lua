local shared = require('lsp.shared')

vim.lsp.config.tailwindcss = {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
  },
  capabilities = shared.capabilities,
  on_attach = shared.on_attach,
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)

    -- Config files that indicate a Tailwind project
    local root_files = {
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'postcss.config.cjs',
      'postcss.config.mjs',
      'postcss.config.ts',
    }

    -- First, try to find a traditional config file
    local found = vim.fs.find(root_files, { path = fname, upward = true })[1]
    if found then
      on_dir(vim.fs.dirname(found))
      return
    end

    -- For Tailwind v4 CSS-first projects, look for package.json with tailwindcss dependency
    local package_json = vim.fs.find('package.json', { path = fname, upward = true })[1]
    if package_json then
      local package_dir = vim.fs.dirname(package_json)
      local ok, content = pcall(vim.fn.readfile, package_json)
      if not ok then return end
      local decoded_ok, pkg = pcall(vim.json.decode, table.concat(content, '\n'))
      if not decoded_ok or type(pkg) ~= 'table' then return end
      local deps = pkg.dependencies or {}
      local dev_deps = pkg.devDependencies or {}
      if deps.tailwindcss or dev_deps.tailwindcss then
        on_dir(package_dir)
        return
      end
    end
  end,
  settings = {
    tailwindCSS = {
      validate = true,
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidScreen = 'error',
        invalidVariant = 'error',
        invalidConfigPath = 'error',
        invalidTailwindDirective = 'error',
        recommendedVariantOrder = 'warning',
      },
      classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
    },
  },
}

vim.lsp.enable('tailwindcss')

local M = {}

-- Shared capabilities for autocompletion
local cmp_nvim_lsp = require('cmp_nvim_lsp')
M.capabilities = cmp_nvim_lsp.default_capabilities()

-- Utility functions to replace lspconfig.util
M.path = {}

-- Check if a file or directory exists
M.path.exists = function(filepath)
    local stat = vim.loop.fs_stat(filepath)
    return stat ~= nil
end

-- Join path components
M.path.join = function(...)
    local args = { ... }
    return table.concat(args, '/')
end

-- Find root directory by searching for marker files
M.root_pattern = function(...)
    local patterns = { ... }
    return function(startpath)
        local path = startpath
        if vim.fn.filereadable(path) == 1 then
            path = vim.fn.fnamemodify(path, ':h')
        end

        -- Walk up the directory tree
        while path ~= '/' do
            for _, pattern in ipairs(patterns) do
                local target = M.path.join(path, pattern)
                if M.path.exists(target) then
                    return path
                end
            end
            path = vim.fn.fnamemodify(path, ':h')
        end

        return nil
    end
end

-- Closes the location list (or quickfix) right after the selection automatically
local function lsp_definition_and_close_list()
  -- Make sure any previous list windows don't stick around
  pcall(vim.cmd, "lclose")
  pcall(vim.cmd, "cclose")

  vim.lsp.buf.definition({
    on_list = function(opts)
      -- Neovim uses location-list by default for LSP lists
      -- but handle both just in case.
      if opts.items == nil or vim.tbl_isempty(opts.items) then
        return
      end

      -- Populate list (loclist or quickfix) and jump to the first item.
      -- You can change behavior here if you want a picker UI instead.
      vim.fn.setloclist(0, {}, " ", opts)
      vim.cmd("lopen")          -- open it briefly so user can choose if they want
      vim.cmd("ll")             -- jump to current entry (first by default)

      -- Close the list once we’ve jumped
      vim.cmd("lclose")
    end,
  })
end

-- Shared keymaps
M.setup_keymaps = function(bufnr)
    local opns = { noremap = true, silent = true, buffer = bufnr }

    -- Navigation
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gd", lsp_definition_and_close_list, { desc = "Go to definition (close list)" })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)

    -- Hover and signatures
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)

    -- Code actions
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Formatting
    vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = true })
    end, opts)

    -- Diagnostics
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
end

-- Optional: Shared on_attach that can be extended
M.on_attach = function(client, bufnr)
    M.setup_keymaps(bufnr)
    print(string.format("LSP '%s' attached to buffer %d", client.name, bufnr))
end

-- Optional: Helper to merge custom on_attach with shared setup
M.make_on_attach = function(custom_fn)
    return function(client, bufnr)
        M.setup_keymaps(bufnr)
        if custom_fn then
            custom_fn(client, bufnr)
        end
        print(string.format("LSP '%s' attached to buffer %d", client.name, bufnr))
    end
end

-- Helper to enable LSP for specific filetypes
M.enable_for_filetypes = function(lsp_name, filetypes)
    vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function()
            vim.lsp.enable(lsp_name)
        end,
    })
end

return M

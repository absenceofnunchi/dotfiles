local M = {}

-- Shared capabilities for autocompletion
local cmp_nvim_lsp = require('cmp_nvim_lsp')
M.capabilities = cmp_nvim_lsp.default_capabilities()

-- Utility functions to replace lspconfig.util
M.path = {}

-- Check if a file or directory exists
M.path.exists = function(filepath)
    local stat = vim.uv.fs_stat(filepath)
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
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
    end

    -- Navigation
    map("n", "gd", lsp_definition_and_close_list, "Go to definition (close list)")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "Find references")
    map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")

    -- Hover and signatures
    map("n", "gh", vim.lsp.buf.hover, "Hover")
    map("n", "gs", vim.lsp.buf.signature_help, "Signature help")

    -- Code actions
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

    -- Diagnostics. Formatting is owned by conform.nvim (with lsp_fallback).
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
    map("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to loclist")

    map("n", "<leader>ih", function()
        if not vim.lsp.inlay_hint then return end
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    end, "Toggle inlay hints")
end

local function maybe_enable_inlay_hints(client, bufnr)
    if not vim.lsp.inlay_hint then return end
    if not (client.server_capabilities and client.server_capabilities.inlayHintProvider) then
        return
    end
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

-- Optional: Shared on_attach that can be extended
M.on_attach = function(client, bufnr)
    M.setup_keymaps(bufnr)
    maybe_enable_inlay_hints(client, bufnr)
end

M.make_on_attach = function(custom_fn)
    return function(client, bufnr)
        M.setup_keymaps(bufnr)
        maybe_enable_inlay_hints(client, bufnr)
        if custom_fn then
            custom_fn(client, bufnr)
        end
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

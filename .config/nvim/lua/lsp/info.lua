-- Enable `LspInfo` to check the status of the LSP

vim.api.nvim_create_user_command('LspInfo', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    local lines = {}
    table.insert(lines, 'Language client log: ' .. vim.lsp.get_log_path())
    table.insert(lines, 'Detected filetype: ' .. vim.bo[bufnr].filetype)
    table.insert(lines, '')

    if #clients == 0 then
        table.insert(lines, 'No LSP clients attached to this buffer')
    else
        table.insert(lines, string.format('%d client(s) attached to this buffer:', #clients))
        table.insert(lines, '')

        for _, client in ipairs(clients) do
            table.insert(lines, string.format('Client: %s (id: %d)', client.name, client.id))
            table.insert(lines, string.format('  filetypes: %s', table.concat(client.config.filetypes or {}, ', ')))
            table.insert(lines, string.format('  root directory: %s', client.config.root_dir or 'Not set'))
            table.insert(lines, string.format('  cmd: %s', table.concat(client.config.cmd or {}, ' ')))

            -- Show server capabilities
            local capabilities = {}
            if client.server_capabilities.completionProvider then
                table.insert(capabilities, 'completion')
            end
            if client.server_capabilities.hoverProvider then
                table.insert(capabilities, 'hover')
            end
            if client.server_capabilities.definitionProvider then
                table.insert(capabilities, 'definition')
            end
            if client.server_capabilities.referencesProvider then
                table.insert(capabilities, 'references')
            end
            if client.server_capabilities.documentFormattingProvider then
                table.insert(capabilities, 'formatting')
            end
            if client.server_capabilities.renameProvider then
                table.insert(capabilities, 'rename')
            end

            if #capabilities > 0 then
                table.insert(lines, string.format('  capabilities: %s', table.concat(capabilities, ', ')))
            end
            table.insert(lines, '')
        end
    end

    -- Show all configured language servers
    table.insert(lines, 'Configured language servers:')
    local configs = vim.tbl_keys(vim.lsp.config)
    table.sort(configs)
    for _, name in ipairs(configs) do
        local config = vim.lsp.config[name]
        if config then
            local filetypes = config.filetypes or {}
            table.insert(lines, string.format('  %s (%s)', name, table.concat(filetypes, ', ')))
        end
    end

    -- Create a scratch buffer for the info
    local info_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(info_bufnr, 0, -1, false, lines)
    vim.bo[info_bufnr].modifiable = false
    vim.bo[info_bufnr].filetype = 'lspinfo'

    -- Open in a floating window
    local width = 80
    local height = math.min(#lines + 2, vim.o.lines - 4)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' LSP Info ',
        title_pos = 'center',
    }

    local win = vim.api.nvim_open_win(info_bufnr, true, opts)

    -- Set up keymaps to close the window
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = info_bufnr, nowait = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = info_bufnr, nowait = true })
end, { desc = 'Show LSP information' })
return {}

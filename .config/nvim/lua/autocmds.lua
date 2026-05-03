local function aug(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Spell-check Go but skip identifiers
vim.api.nvim_create_autocmd("FileType", {
    group = aug("GoSpell"),
    pattern = "go",
    callback = function()
        vim.cmd([[syntax match SpellBad "\<\w\+\>" contains=@NoSpell]])
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = aug("SwiftSpell"),
    pattern = "swift",
    callback = function()
        vim.opt_local.spell = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = aug("HelpFullHeight"),
    pattern = "help",
    command = "wincmd L",
})

-- Kotlin: <leader>kr compiles + runs the current file (.kt) or evals it as a script (.kts).
-- Brew's openjdk is keg-only so /usr/bin/java can't find it; point JAVA_HOME at the brew install.
local kotlin_term_win = nil
local kotlin_term_buf = nil
vim.api.nvim_create_autocmd("FileType", {
    group = aug("KotlinRun"),
    pattern = "kotlin",
    callback = function(args)
        vim.keymap.set("n", "<leader>kr", function()
            local file = vim.fn.expand("%:p")
            if file == "" then
                vim.notify("Save the file before running", vim.log.levels.WARN)
                return
            end
            vim.cmd("write")
            local java_home = "/opt/homebrew/opt/openjdk"
            local env = string.format(
                "JAVA_HOME=%s PATH=%s/bin:$PATH",
                vim.fn.shellescape(java_home),
                java_home
            )
            local cmd
            if file:match("%.kts$") then
                cmd = string.format("%s kotlinc -script %s", env, vim.fn.shellescape(file))
            else
                local jar = vim.fn.tempname() .. ".jar"
                cmd = string.format(
                    "%s kotlinc %s -include-runtime -d %s && %s java -jar %s",
                    env,
                    vim.fn.shellescape(file),
                    vim.fn.shellescape(jar),
                    env,
                    vim.fn.shellescape(jar)
                )
            end
            local origin_win = vim.api.nvim_get_current_win()
            if kotlin_term_win and vim.api.nvim_win_is_valid(kotlin_term_win) then
                vim.api.nvim_win_close(kotlin_term_win, true)
            end
            if kotlin_term_buf and vim.api.nvim_buf_is_valid(kotlin_term_buf) then
                vim.api.nvim_buf_delete(kotlin_term_buf, { force = true })
            end
            vim.api.nvim_set_current_win(origin_win)
            vim.cmd("belowright split | resize 15 | terminal " .. cmd)
            kotlin_term_win = vim.api.nvim_get_current_win()
            kotlin_term_buf = vim.api.nvim_get_current_buf()
        end, { buffer = args.buf, desc = "Kotlin: compile & run current file" })
    end,
})

-- Reload buffer if file changed externally (paired with vim.opt.autoread)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = aug("AutoRead"),
    pattern = "*",
    command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
    group = aug("SyntaxSpellTopLevel"),
    pattern = "*",
    callback = function()
        vim.cmd([[syntax spell toplevel]])
    end,
})

-- Spell on for these filetypes (swift handled separately above)
vim.api.nvim_create_autocmd("FileType", {
    group = aug("SpellByFiletype"),
    pattern = {
        "markdown", "gitcommit", "text",
        "c", "obj", "python",
        "go", "gomod", "gowork", "gotmpl",
        "typescript", "typescriptreact", "typescript.tsx",
        "javascript", "javascriptreact", "javascript.jsx",
    },
    callback = function()
        vim.opt_local.spell = true
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = aug("TrimWhitespace"),
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = aug("YankHighlight"),
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- User commands
vim.api.nvim_create_user_command("DelFile", function(opts)
    vim.fn.delete(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("Temp", "ObsidianTemplate", {})

-- Hard-wrap ONLY plain prose paragraphs in Markdown, at WIDTH columns.
-- Everything else — tasks, tables, fenced code, frontmatter, headings, quotes,
-- lists — is GUARDED (left as one line), so bin/agenda's ripgrep parsing, Obsidian
-- tables/frontmatter, wikilinks, and pasted shell commands are never broken by a
-- stray newline. Design is an ALLOWLIST: wrap only when Treesitter confirms the
-- cursor's OUTERMOST block is a bare `paragraph`; anything else — known syntax or
-- syntax that doesn't exist yet — falls through to "don't wrap." Fail-safe: every
-- uncertain case (no parser, odd node, blank line) resolves to no-wrap, never to a
-- wrong break. A missed wrap costs you a `gqq`; a wrong wrap breaks a table.

local WIDTH = 80

-- Outermost-block types that must never auto-wrap. The top-level check below is the
-- real guarantee; this set is just an explicit early-out for nested cases (a task's
-- text is a `paragraph` INSIDE a `list_item`, so we must stop at the list_item).
local GUARD = {
    fenced_code_block = true, indented_code_block = true,
    pipe_table = true, list = true, list_item = true,
    block_quote = true, minus_metadata = true, plus_metadata = true,
    html_block = true, atx_heading = true, setext_heading = true,
}

-- True only when the cursor sits in a bare top-level prose paragraph.
local function in_prose(buf)
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1] - 1, pos[2]

    -- Inline Dataview/agenda field on this line (e.g. [project:: x]) → structural,
    -- never split. The one line-based convention this vault adds atop CommonMark.
    if vim.api.nvim_get_current_line():find("%[%w[%w%-]*::") then return false end

    -- Query the markdown BLOCK tree (not the injected markdown_inline tree), so node
    -- types are block-level and walking parents is meaningful.
    local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
    if not ok or not parser then return false end          -- no parser → fail safe
    local trees = parser:parse()
    if not (trees and trees[1]) then return false end
    local node = trees[1]:root():named_descendant_for_range(row, col, row, col)

    while node do
        if GUARD[node:type()] then return false end        -- inside a guarded container
        local parent = node:parent()
        local ptype = parent and parent:type()
        if parent == nil or ptype == "document" or ptype == "section" then
            return node:type() == "paragraph"              -- outermost block: wrap iff prose
        end
        node = parent
    end
    return false                                            -- unsure → guard
end

local function retune()
    vim.bo.textwidth = in_prose(0) and WIDTH or 0
end

local aug = vim.api.nvim_create_augroup("ProseWrap", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = aug,
    pattern = "markdown",
    callback = function(args)
        local buf = args.buf
        vim.bo[buf].textwidth = WIDTH
        local fo = vim.opt_local.formatoptions
        fo:append("t")   -- auto-wrap text as you type past textwidth  ← the core behavior
        fo:append("q")   -- allow `gq` to reflow a paragraph (use on pasted prose)
        fo:append("n")   -- keep list indentation if you ever `gq` a list
        fo:append("l")   -- do NOT reflow an already-long line just because you edit it
        fo:remove("a")   -- never continuously auto-format (that would fight the guard)
        if not vim.b[buf].prose_wrap then
            vim.b[buf].prose_wrap = true                    -- register cursor hooks once/buffer
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
                group = aug, buffer = buf, callback = retune,
            })
        end
        retune()
    end,
})

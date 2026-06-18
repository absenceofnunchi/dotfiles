return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/flash.nvim" },
    keys = {
        { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
        { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live Grep" },
        { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find Buffers" },
        { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help Tags" },
        { "<leader>fs", function() require("telescope.builtin").grep_string() end, desc = "Grep String" },
        { "<leader>fo", function() require("telescope.builtin").oldfiles() end, desc = "Find Old Files" },
        { "<leader>ch", function() require("telescope.builtin").command_history() end, desc = "Command History" },
        { "<leader>gi", function() require("telescope.builtin").git_files() end, desc = "Git Files" },
    },
    opts = function()
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local function flash(prompt_bufnr)
            require("flash").jump({
                pattern = "^",
                label = { after = { 0, 0 } },
                search = {
                    mode = "search",
                    exclude = {
                        function(win)
                            return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                        end,
                    },
                },
                action = function(match)
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    picker:set_selection(match.pos[1] - 1)
                end,
            })
        end

        local function open_in_tab(prompt_bufnr)
            local selected_entry = action_state.get_selected_entry()
            local filename = selected_entry.value
            actions.close(prompt_bufnr)
            vim.cmd("tabedit " .. filename)
        end

        return {
            defaults = {
                file_ignore_patterns = {
                    "node_modules",
                    "Pods/",
                    "%.ruff_cache",
                    "%.git/",
                    "%.mypy_cache",
                    "%.class$",
                    "%.jar$",
                    "%.gradle/",
                    "%.kotlin/",
                    "%.idea/",
                    "build/",
                    "target/",
                    "out/",
                    "bin/",
                    "%.next/",
                },
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<Down>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<Up>"] = actions.move_selection_previous,
                        ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
                        ["<C-t>"] = open_in_tab,
                        ["<C-s>"] = flash,
                    },
                    n = {
                        ["<C-t>"] = open_in_tab,
                        ["s"] = flash,
                    },
                },
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                },
                preview = { hide_on_startup = false, treesitter = false },
            },
            pickers = {
                -- prune node_modules/.git during the walk; file_ignore_patterns only filters post-walk (too slow at 100k+ files)
                find_files = { find_command = { "rg", "--files", "--color", "never", "--hidden", "--no-ignore", "-g", "!.git", "-g", "!node_modules" } },
                git_files = { show_untracked = true },
            },
        }
    end,
}

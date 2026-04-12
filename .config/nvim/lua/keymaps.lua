vim.api.nvim_set_keymap('n', '<leader>t', ':NvimTreeToggle<CR>', { desc = "Toggle NvimTree", noremap = true, silent = true })
-- Resize panes
vim.api.nvim_set_keymap('n', '<C-M-l>', ':vertical resize -5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-h>', ':vertical resize +5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-k>', ':resize +5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-j>', ':resize -5<CR>', { noremap = true, silent = true })

-- Function to toggle terminal
_G.toggle_terminal = function()
  local term_buf_nr = nil

  for _, buf_nr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_nr].buftype == 'terminal' then
      term_buf_nr = buf_nr
      break
    end
  end

  if term_buf_nr then
    print("Closing terminal buffer " .. term_buf_nr)
    vim.api.nvim_buf_delete(term_buf_nr, {force = true})
  else
    print("Opening a new terminal")
    vim.cmd('belowright split | terminal')
  end
end

vim.api.nvim_set_keymap('n', '<C-t>', [[:lua toggle_terminal()<CR>]], { noremap = true, silent = true })

local function term_escape_and_move(key)
  return string.format('<C-\\><C-N><C-w>%s', key)
end

-- Key mappings for window navigation in terminal mode
vim.api.nvim_set_keymap('t', '<C-Left>', term_escape_and_move('h'), { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-Down>', term_escape_and_move('j'), { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-Up>', term_escape_and_move('k'), { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-Right>', term_escape_and_move('l'), { noremap = true, silent = true })

-- Key mappings for escaping the terminal mode
vim.api.nvim_set_keymap('t', '<C-[>', '<C-\\><C-n>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights', noremap = true, silent = true  })
vim.api.nvim_set_keymap('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights', noremap = true, silent = true  })

-- Key mappings for resizing splits with Control + Shift + Arrow keys
vim.api.nvim_set_keymap('n', '<C-S-Up>', ':resize +5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-Down>', ':resize -5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-Left>', ':vertical resize -5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-Right>', ':vertical resize +5<CR>', { noremap = true, silent = true })

-- Key mappings for window navigation in normal mode
vim.api.nvim_set_keymap('n', '<C-a>h', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-a>j', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-a>k', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-a>l', '<C-w>l', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-Left>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Down>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Up>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Right>', '<C-w>l', { noremap = true, silent = true })

-- Key mapping for opening a link with Brave
vim.api.nvim_set_keymap('n', 'gx', "<Cmd>lua vim.fn.jobstart({'open', '-a', 'Brave Browser', vim.fn.expand('<cfile>')}, {detach=true})<CR>", {noremap = true, silent = true})

-- Zoom in and out
vim.keymap.set("n", "<Leader>rz", "<C-w>_<C-w>|", { desc = "full si[z]e" })
vim.keymap.set("n", "<Leader>rZ", "<C-w>=", { desc = "even si[Z]e" })

-- Compile and run C++ code
-- vim.api.nvim_set_keymap('n', '<Leader>cr', ':w<CR>:!g++ -o main main.cpp && ./main<CR>', { noremap = true, silent = true })

-- Compile and run C++ code with debug information
-- vim.api.nvim_set_keymap('n', '<Leader>cr', ':w<CR>:!echo "Starting compilation..." && g++ -std=c++17 -o program main.cpp && echo "Compilation done" && ./program<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>br', ':w<CR>:!cd ~/Documents/Code/C++/test2/build && make && echo "Running program..." && ./Test<CR>', { noremap = true, silent = true })

-- Function to run 'cmake --build build'
local function build_project()
  local build_command = "cmake --build build"
  -- Open a new terminal buffer and run the build command
  vim.cmd("split term://".. build_command)
end

-- Set a keymap for the build command
-- Here, '<leader>b' is used as the shortcut (typically '\' in Neovim)
-- vim.api.nvim_set_keymap('n', '<leader>b', ':w<CR>:!cd /Users/jeff/Documents/Code/C++/fitness_tracker/build && sudo cmake .. && sudo cmake --build .<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>cr', ':w<CR>:!clang++ -std=c++20 -o %:r % && echo "Compilation done" && %:r<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>br', ':w<CR>:!cd build && make<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>r', ':w<CR>:!node ./cognito-quicksight-auth.js<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>r', ':w<CR>:!cmake --build build && ./build/fitness_server<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>r', ':w<CR>:!npm start<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>r', ':w<CR>:!sudo /usr/local/bin/manage_valhalla.sh build<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>m', ':w<CR>:!sudo /usr/local/bin/manage_valhalla.sh make<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>bp', ':w<CR>:!sudo /usr/local/bin/manage_valhalla.sh bp<CR>', { noremap = true, silent = true })

-- neovim-dap
vim.api.nvim_set_keymap('n', '<F5>', '<Cmd>lua require"dap".continue()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F10>', '<Cmd>lua require"dap".step_over()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F11>', '<Cmd>lua require"dap".step_into()<CR>', { noremap = true })

-- Locust
-- vim.api.nvim_set_keymap('n', '<Leader>r', '<Cmd>:!~/Documents/Code/RideFlag/load-testing/restart-locust.sh<CR>', { noremap = true })

-- Valhalla build commands
-- _G.build_valhalla = function()
--     vim.cmd('!cmake -B build -DCMAKE_BUILD_TYPE=Release')
--     vim.cmd('!make -C build -j$(nproc)')
--     vim.cmd('!sudo make -C build install')
--     -- vim.cmd('!valhalla_build_tiles -c valhalla.json ontario-latest.osm.pbf')
--     vim.cmd('!find valhalla_tiles | sort -n | tar cf valhalla_tiles.tar --no-recursion -T -')
--     vim.cmd('!valhalla_service valhalla.json 1')
--     print("Valhalla has been rebuilt and restarted.")
-- end
-- _G.build_valhalla = function()
--     vim.cmd('!cmake -B build -DCMAKE_BUILD_TYPE=Release')
--     vim.cmd('!make -C build -j$(nproc)')
--     vim.cmd('!sudo make -C build install')
--     vim.cmd('!find valhalla_tiles | sort -n | tar cf valhalla_tiles.tar --no-recursion -T -')
--
--     -- Start valhalla_service in the background and save its PID
--     local pid = vim.fn.system('valhalla_service valhalla.json 1 & echo $!')
--     vim.g.valhalla_pid = tonumber(pid)
--
--     print("Valhalla has been rebuilt and restarted.")
-- end
--
-- vim.api.nvim_set_keymap('n', '<Leader>bv', ':lua _G.build_valhalla()<CR>', { noremap = true, silent = false })

_G.stop_valhalla = function()
    if vim.g.valhalla_pid then
        vim.cmd('!' .. 'kill ' .. vim.g.valhalla_pid)
        vim.g.valhalla_pid = nil
        print("Valhalla service stopped.")
    else
        print("No Valhalla service is running.")
    end
end

-- Add a keymap to stop Valhalla
vim.api.nvim_set_keymap('n', '<Leader>sv', ':lua _G.stop_valhalla()<CR>', { noremap = true, silent = false })

-- vim.cmd('tabnew | terminal')
-- vim.cmd([[exec 'term //bin/sh -c "valhalla_service valhalla.json 1 & echo $! > /tmp/valhalla_pid"' ]])
vim.api.nvim_set_keymap('n', '<Leader>ar', ':AsyncRun cmake --build build && ./build/test2<CR>', { noremap = true, silent = true })

-- Map \gt to :tabnext
vim.api.nvim_set_keymap('n', '\\gt', ':tabnext<CR>', { noremap = true, silent = true })

-- Go to the 1st tab \1
vim.api.nvim_set_keymap('n', '\\1', ':tabn 1<CR>', { noremap = true, silent = true })

-- Go to the 2nd tab
vim.api.nvim_set_keymap('n', '\\2', ':tabn 2<CR>', { noremap = true, silent = true })

-- Go to the 3rd tab
vim.api.nvim_set_keymap('n', '\\3', ':tabn 3<CR>', { noremap = true, silent = true })

-- Go to the 4rd tab
vim.api.nvim_set_keymap('n', '\\4', ':tabn 3<CR>', { noremap = true, silent = true })

-- Go to the 5rd tab
vim.api.nvim_set_keymap('n', '\\5', ':tabn 3<CR>', { noremap = true, silent = true })

-- Go to the 6rd tab
vim.api.nvim_set_keymap('n', '\\6', ':tabn 3<CR>', { noremap = true, silent = true })

-- Function to toggle Copilot
function ToggleCopilot()
    if vim.g.copilot_enabled == 1 then
        vim.g.copilot_enabled = 0
        print("Copilot disabled")
    else
        vim.g.copilot_enabled = 1
        print("Copilot enabled")
    end
end

-- Key binding to toggle Copilot
vim.api.nvim_set_keymap('n', '<leader>co', ':lua ToggleCopilot()<CR>', { noremap = true, silent = true })

local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon Add File" })
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })

-- Navigate to files
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)

-- Diagnostics: Open Float, it shows the full error message since the floating one doesn't wrap round text and not visible. The cursor should be on the error.
vim.keymap.set('n', 'gl', function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { desc = 'Line diagnostics' })

-- -- For parentheses
-- vim.keymap.set('v', '(', 'c()<Esc>P')
-- vim.keymap.set('v', ')', 'c()<Esc>P')
--
-- -- For square brackets
-- vim.keymap.set('v', '[', 'c[]<Esc>P')
-- vim.keymap.set('v', ']', 'c[]<Esc>P')
--
-- -- For curly braces
-- vim.keymap.set('v', '{', 'c{}<Esc>P')
-- vim.keymap.set('v', '}', 'c{}<Esc>P')
--
-- -- Alternative mappings using leader key
-- vim.keymap.set('v', '<leader>(', 'c()<Esc>P')
-- vim.keymap.set('v', '<leader>[', 'c[]<Esc>P')
-- vim.keymap.set('v', '<leader>{', 'c{}<Esc>P')

-- Auto-pair mappings for insert mode
-- vim.keymap.set('i', '(', '()<Left>')
-- vim.keymap.set('i', '[', '[]<Left>')
-- vim.keymap.set('i', '{', '{}<Left>')
-- vim.keymap.set('i', '"', '""<Left>')
-- vim.keymap.set('i', "'", "''<Left>")
-- vim.keymap.set('i', '`', '``<Left>')
--
-- -- Optional: Add mappings to skip over closing character
-- vim.keymap.set('i', ')', function()
--     if string.sub(vim.fn.getline('.'), vim.fn.col('.'), vim.fn.col('.')) == ')' then
--         return '<Right>'
--     else
--         return ')'
--     end
-- end, { expr = true })

-- Function to surround selected text with characters
-- local function surround_visual(open_char, close_char)
--     return function()
--         local mode = vim.api.nvim_get_mode().mode
--         if mode == 'v' or mode == 'V' then
--             vim.api.nvim_input("<Esc>`>a" .. close_char .. "<Esc>`<i" .. open_char .. "<Esc>")
--         else
--             return open_char .. close_char .. "<Left>"
--         end
--     end
-- end
--
-- -- Auto-pair mappings for insert and visual mode
-- vim.keymap.set({'i', 'v'}, '(', surround_visual('(', ')'), { expr = true })
-- vim.keymap.set({'i', 'v'}, '[', surround_visual('[', ']'), { expr = true })
-- vim.keymap.set({'i', 'v'}, '{', surround_visual('{', '}'), { expr = true })
-- vim.keymap.set({'i', 'v'}, '"', surround_visual('"', '"'), { expr = true })
-- vim.keymap.set({'i', 'v'}, "'", surround_visual("'", "'"), { expr = true })
-- vim.keymap.set({'i', 'v'}, '`', surround_visual('`', '`'), { expr = true })
--
-- -- Optional: Add mappings to skip over closing character
-- vim.keymap.set('i', ')', function()
--     if string.sub(vim.fn.getline('.'), vim.fn.col('.'), vim.fn.col('.')) == ')' then
--         return '<Right>'
--     else
--         return ')'
--     end
-- end, { expr = true })
--
-- -- Preserve Ctrl+{ and Ctrl+} navigation
-- vim.keymap.set('n', '<C-{>', '<C-{>', { noremap = true })

-- Replacement for Harpoon using Vim's argument list

-- vim.keymap.set("n", "<leader>a", function()
--     vim.cmd("argadd %")
--     vim.cmd("argdedup")
-- end, { desc = "Add file to arglist" })
--
-- -- Show list (similar to Harpoon menu)
-- vim.keymap.set("n", "<C-e>", function()
--     vim.cmd("args")
-- end, { desc = "Show arglist" })
--
-- -- Navigate to files (same as <leader>1–4)
-- vim.keymap.set("n", "<leader>1", function()
--     vim.cmd("silent! 1argument")
-- end, { desc = "Go to arglist file 1" })
--
-- vim.keymap.set("n", "<leader>2", function()
--     vim.cmd("silent! 2argument")
-- end, { desc = "Go to arglist file 2" })
--
-- vim.keymap.set("n", "<leader>3", function()
--     vim.cmd("silent! 3argument")
-- end, { desc = "Go to arglist file 3" })
--
-- vim.keymap.set("n", "<leader>4", function()
--     vim.cmd("silent! 4argument")
-- end, { desc = "Go to arglist file 4" })
--

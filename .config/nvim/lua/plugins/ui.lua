return {
    ui = {
        icons = {
            cmd = "",
            config = "",
            event = "",
            ft = "",
            init = "",
            keys = "",
            plugin = "",
            runtime = "",
            require = "",
            source = "",
            start = "",
            task = "",
            lazy = "",
        },
    },
    -- {
    --     "shaunsingh/nord.nvim",
    --     config = function()
    --         vim.g.nord_contrast = true
    --         vim.g.nord_borders = false
    --         vim.g.nord_disable_background = true
    --         vim.g.nord_italic = false
    --         vim.g.nord_uniform_diff_background = true
    --         vim.g.nord_bold = false
    --
    --         require('nord').set()
    --     end,
    -- },

    -- {
    --     'AlexvZyl/nordic.nvim',
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require 'nordic' .load()
    --     end
    -- },
    -- {
    --     'rebelot/kanagawa.nvim',
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.cmd("colorscheme kanagawa")
    --     end
    -- },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            term_colors = true,
            transparent_background = true,
            dim_inactive = {
                enabled = false, -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15, -- percentage of the shade to apply to the inactive window
            },
            integrations = {
                cmp = true,
                gitsigns = true,
                treesitter = true,
                harpoon = true,
                telescope = true,
                mason = true,
                noice = true,
                notify = true,
                which_key = true,
                fidget = true,
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                    },
                    inlay_hints = {
                        background = true,
                    },
                },
                mini = {
                    enabled = true,
                    indentscope_color = "",
                },
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },

    -- lua/plugins/rose-pine.lua
    -- {
    --     "rose-pine/neovim",
    --     priority = 1000,
    --     config = function()
    --         require("rose-pine").setup({
    --             variant = "main", -- auto, main, moon, or dawn
    --             dark_variant = "main", -- main, moon, or dawn
    --             dim_inactive_windows = false,
    --             extend_background_behind_borders = true,
    --
    --             enable = {
    --                 terminal = true,
    --                 legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
    --                 migrations = true, -- Handle deprecated options automatically
    --             },
    --
    --             styles = {
    --                 bold = true,
    --                 italic = false,
    --                 transparency = true,
    --             },
    --
    --             groups = {
    --                 border = "muted",
    --                 link = "iris",
    --                 panel = "surface",
    --
    --                 error = "love",
    --                 hint = "iris",
    --                 info = "foam",
    --                 note = "pine",
    --                 todo = "rose",
    --                 warn = "gold",
    --
    --                 git_add = "foam",
    --                 git_change = "rose",
    --                 git_delete = "love",
    --                 git_dirty = "rose",
    --                 git_ignore = "muted",
    --                 git_merge = "iris",
    --                 git_rename = "pine",
    --                 git_stage = "iris",
    --                 git_text = "rose",
    --                 git_untracked = "subtle",
    --
    --                 h1 = "iris",
    --                 h2 = "foam",
    --                 h3 = "rose",
    --                 h4 = "gold",
    --                 h5 = "pine",
    --                 h6 = "foam",
    --             },
    --
    --             highlight_groups = {
    --                 -- Comment = { fg = "foam" },
    --                 -- VertSplit = { fg = "muted", bg = "muted" },
    --                 NormalFloat = { bg = "none" },
    --             },
    --         })
    --
    --         -- vim.cmd("colorscheme rose-pine")
    --         vim.cmd("colorscheme rose-pine-main")
    --         -- vim.cmd("colorscheme rose-pine-moon")
    --         -- vim.cmd("colorscheme rose-pine-dawn")
    --     end,
    -- },
    -- Lazy
    -- {
    --     "vague2k/vague.nvim",
    --     config = function()
    --         require("vague").setup({
    --             transparent = true,
    --             style = {
    --                 -- "none" is the same thing as default. But "italic" and "bold" are also valid options
    --                 boolean = "none",
    --                 number = "none",
    --                 float = "none",
    --                 error = "none",
    --                 comments = "none",
    --                 conditionals = "none",
    --                 functions = "none",
    --                 headings = "bold",
    --                 operators = "none",
    --                 strings = "none",
    --                 variables = "none",
    --
    --                 -- keywords
    --                 keywords = "none",
    --                 keyword_return = "none",
    --                 keywords_loop = "none",
    --                 keywords_label = "none",
    --                 keywords_exception = "none",
    --
    --                 -- builtin
    --                 builtin_constants = "none",
    --                 builtin_functions = "none",
    --                 builtin_types = "none",
    --                 builtin_variables = "none",
    --             },
    --             -- Override colors
    --             colors = {
    --                 -- bg = "#18191a",
    --                 -- fg = "#cdcdcd",
    --                 -- floatBorder = "#878787",
    --                 -- line = "#282830",
    --                 -- comment = "#646477",
    --                 -- builtin = "#bad1ce",
    --                 func = "#bc96b0",
    --                 string = "#deb896",
    --                 number = "#8f729e",
    --                 -- property = "#c7c7d4",
    --                 -- constant = "#b4b4ce",
    --                 -- parameter = "#b9a3ba",
    --                 -- visual = "#363738",
    --                 -- error = "#d2788c",
    --                 -- warning = "#e6be8c",
    --                 -- hint = "#8ca0dc",
    --                 -- operator = "#96a3b2",
    --                 -- keyword = "#787bab",
    --                 -- type = "#a1b3b9",
    --                 -- search = "#465362",
    --                 -- plus = "#8faf77",
    --                 -- delta = "#e6be8c",
    --             },
    --         })
    --     end
    -- },

    {
        "kyazdani42/nvim-web-devicons",
        config = function()
            require('lazy').setup({
                {'glepnir/nerdicons.nvim', cmd = 'NerdIcons', config = function() require('nerdicons').setup({}) end}
            })
            require("nvim-web-devicons").setup()
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {
            indent = {
                char = '╎',
                -- char = '▏',
            },
        },
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = { left = '', right = ''},
                    section_separators = { left = '', right = ''},
                    always_divide_middle = true,
                    globalstatus = false,
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'branch', 'diff', 'diagnostics'},
                    lualine_c = {
                        {
                            'filename',
                            path = 1, -- 🔥 0 = filename, 1 = relative, 2 = absolute
                        }
                    },
                    lualine_x = {'encoding', 'fileformat', 'filetype'},
                    lualine_y = {'progress'},
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {{ 'filename', path = 2 }},
                    lualine_x = {'location'},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {
                    lualine_a = {},
                },
                extensions = {}
            }
        end
    }
,
}

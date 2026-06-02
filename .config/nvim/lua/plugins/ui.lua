return {
    -- {
    --     "nyoom-engineering/oxocarbon.nvim",
    --     priority = 1000,
    --     config = function()
    --         vim.opt.background = "dark"
    --         vim.cmd.colorscheme("oxocarbon")
    --         vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "IblIndent", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "IblWhitespace", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "IblScope", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
    --         vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
    --     end,
    -- },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            term_colors = true,
            transparent_background = true,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
            highlight_overrides = {
                all = function(colors)
                    return {
                        TelescopeNormal = { bg = "NONE" },
                        TelescopeBorder = { bg = "NONE" },
                        TelescopePromptNormal = { bg = "NONE" },
                        TelescopePromptBorder = { bg = "NONE" },
                        TelescopePromptTitle = { bg = "NONE" },
                        TelescopePreviewNormal = { bg = "NONE" },
                        TelescopePreviewBorder = { bg = "NONE" },
                        TelescopePreviewTitle = { bg = "NONE" },
                        TelescopeResultsNormal = { bg = "NONE" },
                        TelescopeResultsBorder = { bg = "NONE" },
                        TelescopeResultsTitle = { bg = "NONE" },
                    }
                end,
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
    {
        "kyazdani42/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup()
        end,
    },
    {
        "glepnir/nerdicons.nvim",
        cmd = "NerdIcons",
        config = function() require("nerdicons").setup({}) end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {
            indent = {
                char = "╎",
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local theme = require("lualine.themes.auto")
            for _, mode in pairs(theme) do
                for _, section in pairs(mode) do
                    if type(section) == "table" then
                        section.bg = "NONE"
                    end
                end
            end

            -- Macro-recording indicator. cmdheight=0 hides the default
            -- "recording @q" message, so surface it in the statusline instead.
            local function macro_recording()
                local reg = vim.fn.reg_recording()
                if reg == "" then return "" end
                return " REC @" .. reg
            end

            -- lualine doesn't refresh on these events by default, so the
            -- indicator would lag a keystroke without an explicit refresh.
            local rec_group = vim.api.nvim_create_augroup("LualineMacroRec", { clear = true })
            vim.api.nvim_create_autocmd("RecordingEnter", {
                group = rec_group,
                callback = function() require("lualine").refresh() end,
            })
            vim.api.nvim_create_autocmd("RecordingLeave", {
                group = rec_group,
                -- reg_recording() is still set at RecordingLeave; defer so the
                -- indicator clears instead of lingering one frame.
                callback = function()
                    vim.defer_fn(function() require("lualine").refresh() end, 50)
                end,
            })

            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = theme,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    always_divide_middle = true,
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = {
                        {
                            "branch",
                            color = { fg = '#666666'}
                        },
                        {
                            "diagnostics",
                            color = { fg = '#666666'}
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            path = 2,
                            color = { fg = '#666666'}
                        },
                    }, -- 0 = filename, 1 = relative, 2 = absolute, 3 = absolute with ~

                    lualine_x = {
                        { "encoding", color = { fg = '#666666'} },
                        { "fileformat", color = { fg = '#666666'} },
                        { "filetype", color = { fg = '#666666'} },
                    },
                    lualine_y = {
                        { macro_recording, color = { fg = "#ed8796", gui = "bold" } },
                    },
                    lualine_z = { },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 2 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = { lualine_a = {} },
                extensions = {},
            })
        end,
    },
}

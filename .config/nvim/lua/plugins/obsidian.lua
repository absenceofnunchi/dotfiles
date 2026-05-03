return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        workspaces = {
            {
                name = "Obsidian",
                path = "/Users/gin/Library/Mobile Documents/iCloud~md~obsidian",
            },
        },
        ui = { enable = false },
        templates = {
            subdir = "Documents/Templates/",
            date_format = "%Y-%m-%d-%a",
            time_format = "%H:%M",
        },
        daily_notes = {
            folder = "Documents/Journal/Daily",
            date_format = "%Y-%m-%d",
            alias_format = "%B %-d, %Y",
            default_tags = { "journal" },
            template = "Daily_Template.md",
        },
    },
}

return {
    { "MunifTanjim/nui.nvim", lazy = true },
    { "mfussenegger/nvim-dap", lazy = true },
    { "nvim-neotest/nvim-nio", lazy = true },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        lazy = true,
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()
            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
        end,
    },

    {
        "wojciech-kulik/xcodebuild.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        cmd = {
            "XcodebuildSetup",
            "XcodebuildBuild",
            "XcodebuildCleanBuild",
            "XcodebuildBuildRun",
            "XcodebuildRun",
            "XcodebuildTest",
            "XcodebuildTestClass",
            "XcodebuildTestSelected",
            "XcodebuildTestRepeat",
            "XcodebuildPicker",
            "XcodebuildToggleLogs",
            "XcodebuildSelectDevice",
            "XcodebuildSelectScheme",
            "XcodebuildSelectConfig",
            "XcodebuildSelectTestPlan",
            "XcodebuildCancel",
            "XcodebuildOpenInXcode",
        },
        ft = "swift",
        keys = {
            { "<leader>xs", "<cmd>XcodebuildPicker<cr>", desc = "Xcode picker" },
            { "<leader>xS", "<cmd>XcodebuildSetup<cr>", desc = "Xcode setup wizard" },
            { "<leader>xb", "<cmd>XcodebuildBuild<cr>", desc = "Xcode build" },
            { "<leader>xB", "<cmd>XcodebuildCleanBuild<cr>", desc = "Xcode clean build" },
            { "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Xcode build & run" },
            { "<leader>xR", "<cmd>XcodebuildRun<cr>", desc = "Xcode run (no rebuild)" },
            { "<leader>xD", "<cmd>XcodebuildCleanDerivedData<cr>", desc = "Deletes project's DerivedData" },
            { "<leader>xt", "<cmd>XcodebuildTest<cr>", desc = "Xcode run all tests" },
            { "<leader>xT", "<cmd>XcodebuildTestClass<cr>", desc = "Xcode run test class" },
            { "<leader>x.", "<cmd>XcodebuildTestRepeat<cr>", desc = "Xcode repeat last test" },
            { "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Xcode toggle logs" },
            { "<leader>xv", "<cmd>XcodebuildSelectDevice<cr>", desc = "Xcode select device" },
            { "<leader>xc", "<cmd>XcodebuildCancel<cr>", desc = "Xcode cancel job" },
            { "<leader>xo", "<cmd>XcodebuildOpenInXcode<cr>", desc = "Open in Xcode" },

            {
                "<leader>xd",
                function() require("xcodebuild.integrations.dap").build_and_debug() end,
                desc = "Xcode build & debug",
            },
            {
                "<leader>xD",
                function() require("xcodebuild.integrations.dap").debug_without_build() end,
                desc = "Xcode debug (no rebuild)",
            },

            {
                "<leader>Db",
                function() require("dap").toggle_breakpoint() end,
                desc = "DAP toggle breakpoint",
            },
            {
                "<leader>Dc",
                function() require("dap").continue() end,
                desc = "DAP continue",
            },
            {
                "<leader>Dn",
                function() require("dap").step_over() end,
                desc = "DAP step over",
            },
            {
                "<leader>Di",
                function() require("dap").step_into() end,
                desc = "DAP step into",
            },
            {
                "<leader>DO",
                function() require("dap").step_out() end,
                desc = "DAP step out",
            },
            {
                "<leader>Dt",
                function() require("dap").terminate() end,
                desc = "DAP terminate",
            },
            {
                "<leader>Dr",
                function() require("dap").repl.toggle() end,
                desc = "DAP toggle REPL",
            },
            {
                "<leader>Du",
                function() require("dapui").toggle() end,
                desc = "DAP UI toggle",
            },
        },
        config = function()
            require("xcodebuild").setup({
                auto_save = true,
                show_build_progress_bar = true,
                logs = {
                    auto_open_on_failed_build = true,
                    auto_open_on_failed_tests = true,
                    auto_close_on_app_launch = false,
                    auto_focus = true,
                },
                test_search = {
                    lsp_client = "sourcekit",
                    lsp_timeout = 200,
                },
                code_coverage = {
                    enabled = false,
                },
                integrations = {
                    pymobiledevice = {
                        enabled = true,
                    },
                },
            })

            -- Xcode 16+ ships lldb-dap, which xcodebuild.nvim wires up automatically.
            -- The boolean controls auto-loading saved breakpoints (default true).
            require("xcodebuild.integrations.dap").setup()
        end,
    },
}

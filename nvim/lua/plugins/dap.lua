-- -- lua/plugins/dap.lua
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "mxsdev/nvim-dap-vscode-js", -- For JavaScript/TypeScript
  },
  event = "VeryLazy",
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Setup codelldb for Rust, C, and C++
    dap.adapters.codelldb = {
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      executable = {
        command = "codelldb",
        args = { "--port", "${port}" },
      },
    }

    -- Setup delve for Go
    dap.adapters.delve = {
      type = "server",
      port = "${port}",
      executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
      },
    }

    -- Setup node-debug2 for TypeScript/JavaScript
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }

    -- Rust configuration
    dap.configurations.rust = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name = "Debug Test (Stop on Entry)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = true, -- This will stop at the beginning
        args = { "--nocapture", "--test-threads=1" },
      },
      {
        name = "Debug Test",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = { "--nocapture", "--test-threads=1" },
      },
      {
        name = "Debug Specific Test",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
          local test_name = vim.fn.input("Test name (e.g., test_function_name): ")
          if test_name == "" then
            return { "--nocapture", "--test-threads=1" }
          else
            return { test_name, "--exact", "--nocapture", "--test-threads=1" }
          end
        end,
      },
    }

    -- C configuration
    dap.configurations.c = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name = "Attach to process",
        type = "codelldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        args = {},
      },
    }

    -- C++ configuration
    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name = "Debug Tests (Google Test)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/build/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = { "--gtest_break_on_failure" }, -- Breaks on test failure
      },
      {
        name = "Debug Tests (Catch2)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/build/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = { "--break" }, -- Breaks on test failure
      },
      {
        name = "Debug Specific Test",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/build/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
          local test_filter = vim.fn.input("Test filter (e.g., --gtest_filter=TestName.*): ")
          return vim.split(test_filter, " ")
        end,
      },
      {
        name = "Attach to process",
        type = "codelldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        args = {},
      },
    }

    -- Go configuration
    dap.configurations.go = {
      {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}",
      },
      {
        type = "delve",
        name = "Debug test",
        request = "launch",
        mode = "test",
        program = "${file}",
      },
      {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
      },
    }

    -- TypeScript/JavaScript configuration
    dap.configurations.typescript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
      },
    }

    -- JavaScript uses the same configuration as TypeScript
    dap.configurations.javascript = dap.configurations.typescript

    -- Initialize DAP UI
    dapui.setup()

    -- Auto-open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Setup virtual text
    require("nvim-dap-virtual-text").setup()

    -- Keybindings for debugging
    local keymap_opts = { noremap = true, silent = true }

    vim.api.nvim_set_keymap("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>dc", "<cmd>lua require('dap').continue()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>do", "<cmd>lua require('dap').step_over()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>di", "<cmd>lua require('dap').step_into()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>du", "<cmd>lua require('dap').step_out()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>dl", "<cmd>lua require('dap').run_last()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>dq", "<cmd>lua require('dap').terminate()<CR>", keymap_opts)
    vim.api.nvim_set_keymap("n", "<leader>dui", "<cmd>lua require('dapui').toggle()<CR>", keymap_opts)
  end,
}
-- lua/plugins/dap.lua
-- return {
--   "mfussenegger/nvim-dap", -- Debug Adapter Protocol (DAP) client
--   dependencies = {
--     "rcarriga/nvim-dap-ui", -- UI for nvim-dap
--     "theHamsta/nvim-dap-virtual-text", -- Virtual text for debugging
--     "mxsdev/nvim-dap-vscode-js", -- Optional: For JavaScript/TypeScript debugging
--   },
--   config = function()
--     local dap = require("dap")
--     local dapui = require("dapui")
--
--     -- Setup codelldb for Rust
--     dap.adapters.codelldb = {
--       type = "server",
--       host = "127.0.0.1",
--       port = "${port}",
--       executable = {
--         command = "codelldb",
--         args = { "--port", "${port}" },
--       },
--     }
--
--     -- Rust debug configuration
--     dap.configurations.rust = {
--       {
--         name = "Launch",
--         type = "codelldb",
--         request = "launch",
--         program = function()
--           return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
--         end,
--         cwd = "${workspaceFolder}",
--         stopOnEntry = false,
--       },
--     }
--
--     -- Initialize DAP UI
--     dapui.setup()
--
--     -- Keybindings for debugging
--     -- vim.api.nvim_set_keymap("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>dc", "<cmd>lua require('dap').continue()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>do", "<cmd>lua require('dap').step_over()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>di", "<cmd>lua require('dap').step_into()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>du", "<cmd>lua require('dap').step_out()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>dl", "<cmd>lua require('dap').run_last()<CR>", { noremap = true, silent = true })
--     -- vim.api.nvim_set_keymap("n", "<leader>dq", "<cmd>lua require('dap').terminate()<CR>", { noremap = true, silent = true })
--   end,
-- }

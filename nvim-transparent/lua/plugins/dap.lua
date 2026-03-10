-- lua/plugins/dap.lua
return {
  "mfussenegger/nvim-dap", -- Debug Adapter Protocol (DAP) client
  dependencies = {
    "rcarriga/nvim-dap-ui", -- UI for nvim-dap
    "theHamsta/nvim-dap-virtual-text", -- Virtual text for debugging
    "mxsdev/nvim-dap-vscode-js", -- Optional: For JavaScript/TypeScript debugging
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Setup codelldb for Rust
    dap.adapters.codelldb = {
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      executable = {
        command = "codelldb",
        args = { "--port", "${port}" },
      },
    }

    -- Rust debug configuration
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
    }

    -- Initialize DAP UI
    dapui.setup()

    -- Keybindings for debugging
    -- vim.api.nvim_set_keymap("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>dc", "<cmd>lua require('dap').continue()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>do", "<cmd>lua require('dap').step_over()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>di", "<cmd>lua require('dap').step_into()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>du", "<cmd>lua require('dap').step_out()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>dl", "<cmd>lua require('dap').run_last()<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>dq", "<cmd>lua require('dap').terminate()<CR>", { noremap = true, silent = true })
  end,
}

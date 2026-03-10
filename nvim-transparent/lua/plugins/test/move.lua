-- Move language test configuration using overseer
return {
  {
    "stevearc/overseer.nvim",
    opts = {},
    config = function()
      local overseer = require("overseer")
      overseer.setup({
        templates = { "builtin" },
      })

      -- Sui Move test template
      overseer.register_template({
        name = "sui_move_test",
        builder = function()
          return {
            cmd = { "sui" },
            args = { "move", "test", "--gas-limit", "100000000" },
            name = "Sui Move Test",
            cwd = vim.fn.getcwd(),
            components = {
              { "on_output_quickfix", open_on_match = "FAIL" },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable("Move.toml") == 1 and vim.fn.executable("sui") == 1
          end,
        },
      })

      -- Sui Move test with filter
      overseer.register_template({
        name = "sui_move_test_filter",
        builder = function()
          local filter = vim.fn.input("Test filter: ")
          if filter == "" then
            return nil
          end
          return {
            cmd = { "sui" },
            args = { "move", "test", "--filter", filter, "--gas-limit", "100000000" },
            name = "Sui Move Test (Filtered)",
            cwd = vim.fn.getcwd(),
            components = {
              { "on_output_quickfix", open_on_match = "FAIL" },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable("Move.toml") == 1 and vim.fn.executable("sui") == 1
          end,
        },
      })

      -- Aptos Move test template
      overseer.register_template({
        name = "aptos_move_test",
        builder = function()
          return {
            cmd = { "aptos" },
            args = { "move", "test" },
            name = "Aptos Move Test",
            cwd = vim.fn.getcwd(),
            components = {
              { "on_output_quickfix", open_on_match = "FAILED" },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable("Move.toml") == 1 and vim.fn.executable("aptos") == 1
          end,
        },
      })

      -- Aptos Move test with filter
      overseer.register_template({
        name = "aptos_move_test_filter",
        builder = function()
          local filter = vim.fn.input("Test filter: ")
          if filter == "" then
            return nil
          end
          return {
            cmd = { "aptos" },
            args = { "move", "test", "--filter", filter },
            name = "Aptos Move Test (Filtered)",
            cwd = vim.fn.getcwd(),
            components = {
              { "on_output_quickfix", open_on_match = "FAILED" },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable("Move.toml") == 1 and vim.fn.executable("aptos") == 1
          end,
        },
      })

      -- Generic Move test (tries to detect which platform)
      overseer.register_template({
        name = "move_test_auto",
        builder = function()
          local cmd, args
          if vim.fn.executable("sui") == 1 then
            cmd = "sui"
            args = { "move", "test", "--gas-limit", "100000000" }
          elseif vim.fn.executable("aptos") == 1 then
            cmd = "aptos"
            args = { "move", "test" }
          else
            vim.notify("Neither 'sui' nor 'aptos' command found", vim.log.levels.ERROR)
            return nil
          end

          return {
            cmd = { cmd },
            args = args,
            name = "Move Test (Auto)",
            cwd = vim.fn.getcwd(),
            components = {
              { "on_output_quickfix", open_on_match = "FAIL" },
              "default",
            },
          }
        end,
        condition = {
          callback = function()
            return vim.fn.filereadable("Move.toml") == 1
          end,
        },
      })
    end,
    keys = {
      -- Move test keybindings
      {
        "<leader>tm",
        function()
          require("overseer").run_template("move_test_auto")
        end,
        desc = "Run Move Tests (Auto)",
      },
      {
        "<leader>ts",
        function()
          require("overseer").run_template("sui_move_test")
        end,
        desc = "Run Sui Move Tests",
      },
      {
        "<leader>tS",
        function()
          require("overseer").run_template("sui_move_test_filter")
        end,
        desc = "Run Sui Move Tests (Filtered)",
      },
      {
        "<leader>ta",
        function()
          require("overseer").run_template("aptos_move_test")
        end,
        desc = "Run Aptos Move Tests",
      },
      {
        "<leader>tA",
        function()
          require("overseer").run_template("aptos_move_test_filter")
        end,
        desc = "Run Aptos Move Tests (Filtered)",
      },
      { "<leader>to", "<cmd>OverseerToggle<cr>", desc = "Toggle Overseer" },
      { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run Overseer Task" },
    },
    -- Only load in Move projects
    cond = function()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/Move.toml") == 1
    end,
  },
}

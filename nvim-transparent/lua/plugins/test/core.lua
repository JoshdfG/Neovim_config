return {
  -- Neotest configuration for core languages only
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Language-specific adapters
      "nvim-neotest/neotest-plenary", -- For plenary.test (Lua)
      "nvim-neotest/neotest-python", -- Python
      "nvim-neotest/neotest-go", -- Go
      "mrcjkb/rustaceanvim", -- Rust (includes Neotest adapter)
      "marilari88/neotest-vitest", -- JavaScript/TypeScript
      -- Optional: For C++ (no dedicated adapter, using generic test runners)
      "nvim-neotest/neotest-vim-test", -- Fallback for C++
      "stevearc/overseer.nvim",
      "maxandron/neotest-cairo",
      "llllvvuu/neotest-foundry",
    },
    opts = function()
      -- Helper function to check if we're in a Rust project
      local function is_rust_project()
        local cwd = vim.fn.getcwd()
        return vim.fn.filereadable(cwd .. "/Cargo.toml") == 1
      end

      -- Helper function to check if we're in a Cairo project
      local function is_cairo_project()
        local cwd = vim.fn.getcwd()
        return vim.fn.filereadable(cwd .. "/Scarb.toml") == 1
      end

      -- Build adapters list
      local adapters = {}

      -- Always include these adapters
      table.insert(adapters, require("neotest-plenary"))

      -- Python adapter
      table.insert(
        adapters,
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
          args = { "--log-level=INFO" },
        })
      )

      -- Go adapter
      table.insert(
        adapters,
        require("neotest-go")({
          -- experimental = { test_table = true },
          args = { "-v" },
        })
      )
      -- Foundry adapter
      table.insert(adapters, require("neotest-foundry"))

      -- Cairo adapter
      if is_cairo_project() then
        table.insert(adapters, require("neotest-cairo"))
      end
      -- Rust adapter
      if is_rust_project() then
        table.insert(adapters, require("rustaceanvim.neotest"))
      end

      -- Vim-test fallback for C++
      table.insert(
        adapters,
        require("neotest-vim-test")({
          ignore_filetypes = { "python", "go", "rust" },
          allow_file_types = { "cpp" },
        })
      )

      -- Vitest for JavaScript/TypeScript
      table.insert(adapters, require("neotest-vitest"))

      return {
        adapters = adapters,
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            -- Check if trouble is available before using it
            local ok, trouble = pcall(require, "trouble")
            if ok then
              trouble.open({ mode = "quickfix", focus = false })
            else
              vim.cmd("copen")
            end
          end,
        },
        consumers = {
          trouble = function(client)
            local ok, trouble = pcall(require, "trouble")
            if not ok then
              return {}
            end

            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end
              local tree = assert(client:get_position(nil, { adapter = adapter_id }))
              local failed = 0
              for pos_id, result in pairs(results) do
                if result.status == "failed" and tree:get_key(pos_id) then
                  failed = failed + 1
                end
              end
              vim.schedule(function()
                if trouble.is_open() then
                  trouble.refresh()
                  if failed == 0 then
                    trouble.close()
                  end
                end
              end)
            end
            return {}
          end,
        },
      }
    end,
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      require("neotest").setup(opts)
    end,
    keys = {
      { "<leader>t", "", desc = "+test" },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File (Neotest)",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Test Files (Neotest)",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest (Neotest)",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last (Neotest)",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary (Neotest)",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output (Neotest)",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel (Neotest)",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop (Neotest)",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch (Neotest)",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug Nearest (Neotest)",
      },
    },
  },
  -- DAP for debugging (optional)
  {
    "mfussenegger/nvim-dap",
    optional = true,
  },
}
-- works well
-- return {
--   -- Neotest configuration for core languages only
--   {
--     "nvim-neotest/neotest",
--     dependencies = {
--       "nvim-neotest/nvim-nio",
--       "nvim-lua/plenary.nvim",
--       "antoinemadec/FixCursorHold.nvim",
--       "nvim-treesitter/nvim-treesitter",
--       -- Language-specific adapters
--       "nvim-neotest/neotest-plenary", -- For plenary.test (Lua)
--       "nvim-neotest/neotest-python", -- Python
--       "nvim-neotest/neotest-go", -- Go
--       "mrcjkb/rustaceanvim", -- Rust (includes Neotest adapter)
--       "marilari88/neotest-vitest", -- JavaScript/TypeScript
--       -- Optional: For C++ (no dedicated adapter, using generic test runners)
--       "nvim-neotest/neotest-vim-test", -- Fallback for C++
--     },
--     opts = function()
--       -- Helper function to check if we're in a Rust project
--       local function is_rust_project()
--         local cwd = vim.fn.getcwd()
--         return vim.fn.filereadable(cwd .. "/Cargo.toml") == 1
--       end
--
--       -- Build adapters list
--       local adapters = {}
--
--       -- Always include these adapters
--       table.insert(adapters, require("neotest-plenary"))
--
--       -- Python adapter
--       table.insert(
--         adapters,
--         require("neotest-python")({
--           dap = { justMyCode = false },
--           runner = "pytest",
--           args = { "--log-level=INFO" },
--         })
--       )
--
--       -- Go adapter
--       table.insert(
--         adapters,
--         require("neotest-go")({
--           experimental = { test_table = true },
--           args = { "-v" },
--         })
--       )
--
--       -- Rust adapter
--       if is_rust_project() then
--         table.insert(adapters, require("rustaceanvim.neotest"))
--       end
--
--       -- Vim-test fallback for C++
--       table.insert(
--         adapters,
--         require("neotest-vim-test")({
--           ignore_filetypes = { "python", "go", "rust" },
--           allow_file_types = { "cpp" },
--         })
--       )
--
--       -- Vitest for JavaScript/TypeScript
--       table.insert(adapters, require("neotest-vitest"))
--
--       return {
--         adapters = adapters,
--         status = { virtual_text = true },
--         output = { open_on_run = true },
--         quickfix = {
--           open = function()
--             -- Check if trouble is available before using it
--             local ok, trouble = pcall(require, "trouble")
--             if ok then
--               trouble.open({ mode = "quickfix", focus = false })
--             else
--               vim.cmd("copen")
--             end
--           end,
--         },
--         consumers = {
--           trouble = function(client)
--             local ok, trouble = pcall(require, "trouble")
--             if not ok then
--               return {}
--             end
--
--             client.listeners.results = function(adapter_id, results, partial)
--               if partial then
--                 return
--               end
--               local tree = assert(client:get_position(nil, { adapter = adapter_id }))
--               local failed = 0
--               for pos_id, result in pairs(results) do
--                 if result.status == "failed" and tree:get_key(pos_id) then
--                   failed = failed + 1
--                 end
--               end
--               vim.schedule(function()
--                 if trouble.is_open() then
--                   trouble.refresh()
--                   if failed == 0 then
--                     trouble.close()
--                   end
--                 end
--               end)
--             end
--             return {}
--           end,
--         },
--       }
--     end,
--     config = function(_, opts)
--       local neotest_ns = vim.api.nvim_create_namespace("neotest")
--       vim.diagnostic.config({
--         virtual_text = {
--           format = function(diagnostic)
--             local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
--             return message
--           end,
--         },
--       }, neotest_ns)
--
--       require("neotest").setup(opts)
--     end,
--     keys = {
--       { "<leader>t", "", desc = "+test" },
--       {
--         "<leader>tt",
--         function()
--           require("neotest").run.run(vim.fn.expand("%"))
--         end,
--         desc = "Run File (Neotest)",
--       },
--       {
--         "<leader>tT",
--         function()
--           require("neotest").run.run(vim.uv.cwd())
--         end,
--         desc = "Run All Test Files (Neotest)",
--       },
--       {
--         "<leader>tr",
--         function()
--           require("neotest").run.run()
--         end,
--         desc = "Run Nearest (Neotest)",
--       },
--       {
--         "<leader>tl",
--         function()
--           require("neotest").run.run_last()
--         end,
--         desc = "Run Last (Neotest)",
--       },
--       {
--         "<leader>ts",
--         function()
--           require("neotest").summary.toggle()
--         end,
--         desc = "Toggle Summary (Neotest)",
--       },
--       {
--         "<leader>to",
--         function()
--           require("neotest").output.open({ enter = true, auto_close = true })
--         end,
--         desc = "Show Output (Neotest)",
--       },
--       {
--         "<leader>tO",
--         function()
--           require("neotest").output_panel.toggle()
--         end,
--         desc = "Toggle Output Panel (Neotest)",
--       },
--       {
--         "<leader>tS",
--         function()
--           require("neotest").run.stop()
--         end,
--         desc = "Stop (Neotest)",
--       },
--       {
--         "<leader>tw",
--         function()
--           require("neotest").watch.toggle(vim.fn.expand("%"))
--         end,
--         desc = "Toggle Watch (Neotest)",
--       },
--       {
--         "<leader>td",
--         function()
--           require("neotest").run.run({ strategy = "dap" })
--         end,
--         desc = "Debug Nearest (Neotest)",
--       },
--     },
--   },
--   -- Rustaceanvim for Rust support (separate plugin)
--   {
--     "mrcjkb/rustaceanvim",
--     version = "^6",
--     lazy = false,
--     ft = { "rust" },
--   },
--   -- DAP for debugging (optional)
--   {
--     "mfussenegger/nvim-dap",
--     optional = true,
--   },
-- }
--  works for rust flawlessly
-- return {
--   -- Single Neotest configuration with all adapters
--   {
--     "nvim-neotest/neotest",
--     dependencies = {
--       "nvim-neotest/nvim-nio",
--       "nvim-lua/plenary.nvim",
--       "antoinemadec/FixCursorHold.nvim",
--       "nvim-treesitter/nvim-treesitter",
--       -- Language-specific adapters
--       "nvim-neotest/neotest-plenary", -- For plenary.test (Lua)
--       "nvim-neotest/neotest-python", -- Python
--       "nvim-neotest/neotest-go", -- Go
--       "mrcjkb/rustaceanvim", -- Rust (includes Neotest adapter)
--       "maxandron/neotest-cairo", -- Cairo
--       "marilari88/neotest-vitest", -- JavaScript/TypeScript (if needed)
--       -- Optional: For C++ (no dedicated adapter, using generic test runners)
--       "nvim-neotest/neotest-vim-test", -- Fallback for C++ via vim-test
--       -- Optional: overseer for custom test runners
--       "stevearc/overseer.nvim",
--     },
--     opts = function()
--       -- Helper function to check if we're in a Cairo project
--       local function is_cairo_project()
--         local cwd = vim.fn.getcwd()
--         return vim.fn.filereadable(cwd .. "/Scarb.toml") == 1
--       end
--
--       -- Helper function to check if we're in a Rust project (but not Cairo)
--       local function is_rust_project()
--         local cwd = vim.fn.getcwd()
--         return vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 and not is_cairo_project()
--       end
--
--       -- Build adapters list conditionally
--       local adapters = {}
--
--       -- Always include these adapters
--       table.insert(adapters, require("neotest-plenary"))
--
--       -- Python adapter
--       table.insert(
--         adapters,
--         require("neotest-python")({
--           dap = { justMyCode = false },
--           runner = "pytest",
--           args = { "--log-level=INFO" },
--         })
--       )
--
--       -- Go adapter
--       table.insert(
--         adapters,
--         require("neotest-go")({
--           experimental = { test_table = true },
--           args = { "-v" },
--         })
--       )
--
--       -- Conditionally add Rust adapter (only if not Cairo project)
--       if is_rust_project() then
--         table.insert(adapters, require("rustaceanvim.neotest"))
--       end
--
--       -- Conditionally add Cairo adapter (only if Cairo project)
--       if is_cairo_project() then
--         table.insert(adapters, require("neotest-cairo"))
--       end
--
--       -- Vim-test fallback for other languages
--       table.insert(
--         adapters,
--         require("neotest-vim-test")({
--           ignore_filetypes = { "python", "go", "rust", "cairo" },
--           allow_file_types = { "cpp" },
--         })
--       )
--
--       -- Vitest for JavaScript/TypeScript
--       table.insert(adapters, require("neotest-vitest"))
--
--       return {
--         adapters = adapters,
--         status = { virtual_text = true },
--         output = { open_on_run = true },
--         quickfix = {
--           open = function()
--             -- Check if trouble is available before using it
--             local ok, trouble = pcall(require, "trouble")
--             if ok then
--               trouble.open({ mode = "quickfix", focus = false })
--             else
--               vim.cmd("copen")
--             end
--           end,
--         },
--         consumers = {
--           overseer = function()
--             local ok, overseer_consumer = pcall(require, "neotest.consumers.overseer")
--             if ok then
--               return overseer_consumer
--             end
--             return {}
--           end,
--           trouble = function(client)
--             local ok, trouble = pcall(require, "trouble")
--             if not ok then
--               return {}
--             end
--
--             client.listeners.results = function(adapter_id, results, partial)
--               if partial then
--                 return
--               end
--               local tree = assert(client:get_position(nil, { adapter = adapter_id }))
--               local failed = 0
--               for pos_id, result in pairs(results) do
--                 if result.status == "failed" and tree:get_key(pos_id) then
--                   failed = failed + 1
--                 end
--               end
--               vim.schedule(function()
--                 if trouble.is_open() then
--                   trouble.refresh()
--                   if failed == 0 then
--                     trouble.close()
--                   end
--                 end
--               end)
--             end
--             return {}
--           end,
--         },
--       }
--     end,
--     config = function(_, opts)
--       local neotest_ns = vim.api.nvim_create_namespace("neotest")
--       vim.diagnostic.config({
--         virtual_text = {
--           format = function(diagnostic)
--             local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
--             return message
--           end,
--         },
--       }, neotest_ns)
--
--       -- Setup overseer if available
--       local ok, overseer = pcall(require, "overseer")
--       if ok then
--         overseer.setup()
--
--         -- Custom overseer tasks for unsupported languages
--         overseer.register_template({
--           name = "Solidity Foundry Test",
--           builder = function(params)
--             return {
--               cmd = { "forge" },
--               args = { "test" },
--               name = "Solidity Foundry Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "solidity" },
--           },
--         })
--
--         overseer.register_template({
--           name = "Sui Move Test",
--           builder = function(params)
--             return {
--               cmd = { "sui" },
--               args = { "move", "test" },
--               name = "Sui Move Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "move" },
--           },
--         })
--
--         overseer.register_template({
--           name = "Stellar Soroban Test",
--           builder = function(params)
--             return {
--               cmd = { "soroban" },
--               args = { "contract", "test" },
--               name = "Stellar Soroban Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "rust" }, -- Assuming Soroban uses Rust
--           },
--         })
--
--         overseer.register_template({
--           name = "Xion Test",
--           builder = function(params)
--             return {
--               cmd = { "xiond" },
--               args = { "test" },
--               name = "Xion Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "rust" }, -- Assuming Xion uses Rust
--           },
--         })
--       end
--
--       require("neotest").setup(opts)
--     end,
--     keys = {
--       {
--         "<leader>tt",
--         function()
--           require("neotest").run.run(vim.fn.expand("%"))
--         end,
--         desc = "Run File (Neotest)",
--       },
--       {
--         "<leader>tT",
--         function()
--           require("neotest").run.run(vim.uv.cwd())
--         end,
--         desc = "Run All Test Files (Neotest)",
--       },
--       {
--         "<leader>tr",
--         function()
--           require("neotest").run.run()
--         end,
--         desc = "Run Nearest (Neotest)",
--       },
--       {
--         "<leader>tl",
--         function()
--           require("neotest").run.run_last()
--         end,
--         desc = "Run Last (Neotest)",
--       },
--       {
--         "<leader>ts",
--         function()
--           require("neotest").summary.toggle()
--         end,
--         desc = "Toggle Summary (Neotest)",
--       },
--       {
--         "<leader>to",
--         function()
--           require("neotest").output.open({ enter = true, auto_close = true })
--         end,
--         desc = "Show Output (Neotest)",
--       },
--       {
--         "<leader>tO",
--         function()
--           require("neotest").output_panel.toggle()
--         end,
--         desc = "Toggle Output Panel (Neotest)",
--       },
--       {
--         "<leader>tS",
--         function()
--           require("neotest").run.stop()
--         end,
--         desc = "Stop (Neotest)",
--       },
--       {
--         "<leader>tw",
--         function()
--           require("neotest").watch.toggle(vim.fn.expand("%"))
--         end,
--         desc = "Toggle Watch (Neotest)",
--       },
--       {
--         "<leader>td",
--         function()
--           require("neotest").run.run({ strategy = "dap" })
--         end,
--         desc = "Debug Nearest (Neotest)",
--       },
--     },
--   },
--   -- Rustaceanvim for Rust support (separate plugin)
--   {
--     "mrcjkb/rustaceanvim",
--     version = "^6",
--     lazy = false,
--     ft = { "rust" },
--   },
--   -- DAP for debugging (optional)
--   {
--     "mfussenegger/nvim-dap",
--     optional = true,
--   },
-- }
--
--return {
--   -- Single Neotest configuration with all adapters
--   {
--     "nvim-neotest/neotest",
--     dependencies = {
--       "nvim-neotest/nvim-nio",
--       "nvim-lua/plenary.nvim",
--       "antoinemadec/FixCursorHold.nvim",
--       "nvim-treesitter/nvim-treesitter",
--       -- Language-specific adapters
--       "nvim-neotest/neotest-plenary", -- For plenary.test (Lua)
--       "nvim-neotest/neotest-python", -- Python
--       "nvim-neotest/neotest-go", -- Go
--       "mrcjkb/rustaceanvim", -- Rust (includes Neotest adapter)
--       "maxandron/neotest-cairo", -- Cairo
--       "marilari88/neotest-vitest", -- JavaScript/TypeScript (if needed)
--       -- Optional: For C++ (no dedicated adapter, using generic test runners)
--       "nvim-neotest/neotest-vim-test", -- Fallback for C++ via vim-test
--       -- Optional: overseer for custom test runners
--       "stevearc/overseer.nvim",
--     },
--     opts = function()
--       return {
--         adapters = {
--           require("neotest-plenary"),
--           require("neotest-python")({
--             dap = { justMyCode = false }, -- Optional: for debugging
--             runner = "pytest", -- or "unittest"
--             args = { "--log-level=INFO" },
--           }),
--           require("neotest-go")({
--             experimental = { test_table = true },
--             args = { "-v" },
--           }),
--           require("rustaceanvim.neotest"), -- Rust adapter via rustaceanvim
--           require("neotest-cairo"), -- Cairo adapter
--           require("neotest-vim-test")({
--             ignore_filetypes = { "python", "go", "rust", "cairo" },
--             allow_file_types = { "cpp" }, -- For C++ testing
--           }),
--           require("neotest-vitest"), -- Optional: for JavaScript/TypeScript
--         },
--         status = { virtual_text = true },
--         output = { open_on_run = true },
--         quickfix = {
--           open = function()
--             -- Check if trouble is available before using it
--             local ok, trouble = pcall(require, "trouble")
--             if ok then
--               trouble.open({ mode = "quickfix", focus = false })
--             else
--               vim.cmd("copen")
--             end
--           end,
--         },
--         consumers = {
--           overseer = function()
--             local ok, overseer_consumer = pcall(require, "neotest.consumers.overseer")
--             if ok then
--               return overseer_consumer
--             end
--             return {}
--           end,
--           trouble = function(client)
--             local ok, trouble = pcall(require, "trouble")
--             if not ok then
--               return {}
--             end
--
--             client.listeners.results = function(adapter_id, results, partial)
--               if partial then
--                 return
--               end
--               local tree = assert(client:get_position(nil, { adapter = adapter_id }))
--               local failed = 0
--               for pos_id, result in pairs(results) do
--                 if result.status == "failed" and tree:get_key(pos_id) then
--                   failed = failed + 1
--                 end
--               end
--               vim.schedule(function()
--                 if trouble.is_open() then
--                   trouble.refresh()
--                   if failed == 0 then
--                     trouble.close()
--                   end
--                 end
--               end)
--             end
--             return {}
--           end,
--         },
--       }
--     end,
--     config = function(_, opts)
--       local neotest_ns = vim.api.nvim_create_namespace("neotest")
--       vim.diagnostic.config({
--         virtual_text = {
--           format = function(diagnostic)
--             local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
--             return message
--           end,
--         },
--       }, neotest_ns)
--
--       -- Setup overseer if available
--       local ok, overseer = pcall(require, "overseer")
--       if ok then
--         overseer.setup()
--
--         -- Custom overseer tasks for unsupported languages
--         overseer.register_template({
--           name = "Solidity Foundry Test",
--           builder = function(params)
--             return {
--               cmd = { "forge" },
--               args = { "test" },
--               name = "Solidity Foundry Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "solidity" },
--           },
--         })
--
--         overseer.register_template({
--           name = "Sui Move Test",
--           builder = function(params)
--             return {
--               cmd = { "sui" },
--               args = { "move", "test" },
--               name = "Sui Move Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "move" },
--           },
--         })
--
--         overseer.register_template({
--           name = "Stellar Soroban Test",
--           builder = function(params)
--             return {
--               cmd = { "soroban" },
--               args = { "contract", "test" },
--               name = "Stellar Soroban Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "rust" }, -- Assuming Soroban uses Rust
--           },
--         })
--
--         overseer.register_template({
--           name = "Xion Test",
--           builder = function(params)
--             return {
--               cmd = { "xiond" },
--               args = { "test" },
--               name = "Xion Test",
--               cwd = vim.fn.getcwd(),
--             }
--           end,
--           condition = {
--             filetype = { "rust" }, -- Assuming Xion uses Rust
--           },
--         })
--       end
--
--       require("neotest").setup(opts)
--     end,
--     keys = {
--       {
--         "<leader>tt",
--         function()
--           require("neotest").run.run(vim.fn.expand("%"))
--         end,
--         desc = "Run File (Neotest)",
--       },
--       {
--         "<leader>tT",
--         function()
--           require("neotest").run.run(vim.uv.cwd())
--         end,
--         desc = "Run All Test Files (Neotest)",
--       },
--       {
--         "<leader>tr",
--         function()
--           require("neotest").run.run()
--         end,
--         desc = "Run Nearest (Neotest)",
--       },
--       {
--         "<leader>tl",
--         function()
--           require("neotest").run.run_last()
--         end,
--         desc = "Run Last (Neotest)",
--       },
--       {
--         "<leader>ts",
--         function()
--           require("neotest").summary.toggle()
--         end,
--         desc = "Toggle Summary (Neotest)",
--       },
--       {
--         "<leader>to",
--         function()
--           require("neotest").output.open({ enter = true, auto_close = true })
--         end,
--         desc = "Show Output (Neotest)",
--       },
--       {
--         "<leader>tO",
--         function()
--           require("neotest").output_panel.toggle()
--         end,
--         desc = "Toggle Output Panel (Neotest)",
--       },
--       {
--         "<leader>tS",
--         function()
--           require("neotest").run.stop()
--         end,
--         desc = "Stop (Neotest)",
--       },
--       {
--         "<leader>tw",
--         function()
--           require("neotest").watch.toggle(vim.fn.expand("%"))
--         end,
--         desc = "Toggle Watch (Neotest)",
--       },
--       {
--         "<leader>td",
--         function()
--           require("neotest").run.run({ strategy = "dap" })
--         end,
--         desc = "Debug Nearest (Neotest)",
--       },
--     },
--   },
--   -- Rustaceanvim for Rust support (separate plugin)
--   {
--     "mrcjkb/rustaceanvim",
--     version = "^6",
--     lazy = false,
--     ft = { "rust" },
--   },
--   -- DAP for debugging (optional)
--   {
--     "mfussenegger/nvim-dap",
--     optional = true,
--   },
-- } -- return {
--   { 'nvim-neotest/neotest-plenary' },
--   {
--     'nvim-neotest/neotest',
--     dependencies = {
--       'nvim-neotest/nvim-nio',
--       -- 'nvim-neotest/neotest-jest',
--       'marilari88/neotest-vitest',
--     },
--     opts = {
--       adapters = {
--         'neotest-plenary',
--       },
--       status = { virtual_text = true },
--       output = { open_on_run = true },
--       quickfix = {
--         open = function()
--           require('trouble').open { mode = 'quickfix', focus = false }
--         end,
--       },
--     },
--     config = function(_, opts)
--       local neotest_ns = vim.api.nvim_create_namespace 'neotest'
--       vim.diagnostic.config({
--         virtual_text = {
--           format = function(diagnostic)
--             local message = diagnostic.message
--               :gsub('\n', ' ')
--               :gsub('\t', ' ')
--               :gsub('%s+', ' ')
--               :gsub('^%s+', '')
--             return message
--           end,
--         },
--       }, neotest_ns)
--
--       opts.consumers = opts.consumers or {}
--       -- Refresh and auto close trouble after running tests
--       ---@type neotest.Consumer
--       opts.consumers.trouble = function(client)
--         client.listeners.results = function(adapter_id, results, partial)
--           if partial then
--             return
--           end
--           local tree =
--             assert(client:get_position(nil, { adapter = adapter_id }))
--
--           local failed = 0
--           for pos_id, result in pairs(results) do
--             if result.status == 'failed' and tree:get_key(pos_id) then
--               failed = failed + 1
--             end
--           end
--           vim.schedule(function()
--             local trouble = require 'trouble'
--             if trouble.is_open() then
--               trouble.refresh()
--               if failed == 0 then
--                 trouble.close()
--               end
--             end
--           end)
--         end
--         return {}
--       end
--
--       opts.consumers.overseer = require 'neotest.consumers.overseer'
--
--       if opts.adapters then
--         local adapters = {
--           -- require 'neotest-jest',
--           require 'neotest-vitest',
--         }
--         for name, config in pairs(opts.adapters or {}) do
--           if type(name) == 'number' then
--             if type(config) == 'string' then
--               config = require(config)
--             end
--             adapters[#adapters + 1] = config
--           elseif config ~= false then
--             local adapter = require(name)
--             if type(config) == 'table' and not vim.tbl_isempty(config) then
--               local meta = getmetatable(adapter)
--               if adapter.setup then
--                 adapter.setup(config)
--               elseif adapter.adapter then
--                 adapter.adapter(config)
--                 adapter = adapter.adapter
--               elseif meta and meta.__call then
--                 adapter = adapter(config)
--               else
--                 error('Adapter ' .. name .. ' does not support setup')
--               end
--             end
--             adapters[#adapters + 1] = adapter
--           end
--         end
--         opts.adapters = adapters
--       end
--
--       require('neotest').setup(opts)
--     end,
--     -- stylua: ignore
--     keys = {
--       { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
--       { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
--       { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
--       { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
--       { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
--       { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
--       { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
--       { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
--       { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
--     },
--   },
--   {
--     'mfussenegger/nvim-dap',
--     optional = true,
--     -- stylua: ignore
--     keys = {
--       { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Debug Nearest (Neotest)" },
--     },
--   },
-- }

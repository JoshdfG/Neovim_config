local nargo_bin = "/Users/MAC/.nargo/bin/nargo"

return {
  -- 1. Register file type and enforce strict root directory matching
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.filetype.add({
        extension = {
          nr = "noir",
        },
      })

      opts.servers = opts.servers or {}
      opts.servers.nargo = {
        cmd = { nargo_bin, "lsp" },
        -- Tell lspconfig how to locate the workspace root for a Noir contract
        root_dir = function(fname)
          local util = require("lspconfig.util")
          -- 1. Look for Nargo.toml up the tree
          -- 2. Fall back to git root, or the current file's directory
          return util.root_pattern("Nargo.toml")(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
        end,
      }
    end,
  },

  -- 2. Noir plugin for syntax coloring
  {
    "noir-lang/noir-nvim",
    dependencies = { "neovim/nvim-lspconfig" },
  },

  -- 3. Advanced Multi-line Nargo Linter Parser using your absolute path
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local lint = require("lint")

      lint.linters.nargo = {
        name = "nargo",
        cmd = nargo_bin,
        args = { "check" },
        stdin = false,
        append_fname = false,
        stream = "stderr",
        ignore_exitcode = true,
        parser = function(output, bufnr)
          if output == "" or output == nil then
            return {}
          end

          local diagnostics = {}
          local current_msg = nil
          local current_severity = vim.diagnostic.severity.ERROR

          for line in string.gmatch(output, "[^\r\n]+") do
            local msg_match = string.match(line, "^error:%s*(.*)$")
            if msg_match then
              current_msg = msg_match
              current_severity = vim.diagnostic.severity.ERROR
            else
              local warn_match = string.match(line, "^warning:%s*(.*)$")
              if warn_match then
                current_msg = warn_match
                current_severity = vim.diagnostic.severity.WARN
              end
            end

            if current_msg then
              local file, lnum, col = string.match(line, "[┌│]%─*%s*([^:]+):(%d+):(%d+)")
              if file and lnum and col then
                table.insert(diagnostics, {
                  source = "nargo check",
                  lnum = tonumber(lnum) - 1,
                  col = tonumber(col) - 1,
                  end_lnum = tonumber(lnum) - 1,
                  end_col = tonumber(col) + 3,
                  severity = current_severity,
                  message = current_msg,
                })
                current_msg = nil
              end
            end
          end

          return diagnostics
        end,
      }

      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.noir = { "nargo" }
    end,
  },
} -- works but no error
-- return {
--   -- 1. Explicitly register the .nr filetype so Neovim recognizes "noir"
--   {
--     "neovim/nvim-lspconfig",
--     opts = function(_, opts)
--       vim.filetype.add({
--         extension = {
--           nr = "noir",
--         },
--       })
--
--       -- Hook nargo into LazyVim's native LSP management setup
--       opts.servers = opts.servers or {}
--       opts.servers.nargo = {}
--     end,
--   },
--
--   -- 2. Install the official Noir plugin for syntax coloring (without lazy-loading constraints)
--   {
--     "noir-lang/noir-nvim",
--     dependencies = { "neovim/nvim-lspconfig" },
--     -- Removing ft = "noir" ensures Vim-syntax definitions load instantly on startup
--   },
--
--   -- 3. Nargo linter execution for diagnostics on save
--   {
--     "mfussenegger/nvim-lint",
--     opts = function(_, opts)
--       local lint = require("lint")
--       lint.linters.nargo = {
--         name = "nargo",
--         cmd = "nargo",
--         args = { "check" },
--         stdin = false,
--         append_fname = false,
--         stream = "stderr",
--         ignore_exitcode = true,
--         parser = function(output, bufnr)
--           local diagnostics = {}
--           for line in string.gmatch(output, "[^\r\n]+") do
--             local file, lnum, col, msg = string.match(line, "([^:]+):(%d+):(%d+):%s*(.*)")
--             if file and lnum and col and msg then
--               table.insert(diagnostics, {
--                 source = "nargo",
--                 lnum = tonumber(lnum) - 1,
--                 col = tonumber(col) - 1,
--                 end_lnum = tonumber(lnum) - 1,
--                 end_col = tonumber(col),
--                 severity = string.match(msg:lower(), "error") and vim.diagnostic.severity.ERROR
--
--                   or vim.diagnostic.severity.WARN,
--                 message = msg,
--               })
--             end
--           end
--           return diagnostics
--         end,
--       }
--       opts.linters_by_ft = opts.linters_by_ft or {}
--       opts.linters_by_ft.noir = { "nargo" }
--     end,
--   },
-- }

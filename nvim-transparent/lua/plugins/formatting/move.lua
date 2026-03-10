-- lua/plugins/move_conform.lua (or a similar file dedicated to Move tools)

return {
  -- Ensure prettier is installed via Mason, as the Move plugin depends on the main prettier executable
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettier" } },
  },

  -- This conform.nvim configuration will ONLY handle Move formatting
  {
    "stevearc/conform.nvim",
    -- Lazy.nvim will load this plugin when a file with filetype 'move' is opened
    ft = { "move" },
    opts = function(_, opts)
      -- Initialize tables if they don't exist (good practice)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters = opts.formatters or {}

      -- *** Define the custom formatter specifically for Move ***
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters, {
        ["prettier-move-plugin"] = {
          command = "prettier", -- Use the standard prettier command (assumes it's in PATH)
          args = {
            "--stdin-filepath",
            "$FILENAME",
            "--plugin=prettier-plugin-move", -- Specify the globally installed move plugin
            "--parser=move", -- Specify the move parser
            -- If prettier struggles to find the globally installed plugin (less common for global installs)
            -- you might need to uncomment and adjust one of these based on your Node setup:
            -- "--plugin-search-dir=" .. vim.fn.expand("~/.nvm/versions/node/YOUR_NODE_VERSION/lib/node_modules"),
            -- env = { NODE_PATH = vim.fn.expand("~/.nvm/versions/node/YOUR_NODE_VERSION/lib/node_modules") }
          },
        },
      })

      -- *** Assign this specific formatter ONLY to the 'move' filetype ***
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, {
        move = { "prettier-move-plugin" },
        -- If you use prettierd configured for move, add it here too
        -- move = { "prettierd", "prettier-move-plugin" },
      })
      -- *** End of Move-specific formatter setup ***

      -- *** Enable format-on-save using Conform's built-in option ***
      -- Conform will automatically look up formatters_by_ft for the current buffer's filetype when saving
      opts.format_on_save = true
      -- *** End of built-in format-on-save setup ***

      -- We remove the custom opts.format_after_save function entirely
    end,
    -- Configure the BufWritePost autocmd to trigger the conform format function
    init = function()
      vim.opt.formatprg = "" -- Clear the old formatprg option

      -- This autocmd tells Conform to format on save.
      -- Because opts.format_on_save = true is set, and the plugin is loaded
      -- only for move files (ft = {"move"}), and formatters_by_ft is set only for move,
      -- this should effectively only format move files.
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("FormatMoveOnSave", { clear = true }), -- Use a distinct group name
        pattern = "*.move", -- Ensure this autocmd ONLY triggers for move files
        callback = function(args)
          -- Call conform's format function. Conform will use opts.format_on_save = true
          -- and opts.formatters_by_ft to determine what formatters to run.
          require("conform").format({ bufnr = args.buf, async = true })
        end,
      })
    end,
  },

  -- Ensure your generic prettier config for other languages is in a SEPARATE conform
  -- definition or handled by a different formatter source (like null-ls)

  -- Example (if you use another conform definition for generic prettier):
  -- {
  --   "stevearc/conform.nvim",
  --   -- Don't set ft = { "move" } here
  --   -- This instance will handle other filetypes
  --   opts = function(_, opts)
  --      -- Your config for generic prettier using the 'supported' list goes here
  --      opts.format_on_save = true -- Enable format on save for these other types
  --   end,
  --   init = function()
  --      vim.api.nvim_create_autocmd("BufWritePost", {
  --         group = vim.api.nvim_create_augroup("FormatOtherOnSave", { clear = true }),
  --         -- Pattern for your other filetypes
  --         pattern = "*.{css,html,js,json,ts,yaml}",
  --         callback = function(args)
  --             require("conform").format({ bufnr = args.buf, async = true })
  --         end,
  --      })
  --   end,
  -- }

  -- Example (if you use null-ls for generic prettier - often simpler):
  -- {
  --   "nvimtools/none-ls.nvim",
  --   -- Configure ft here if you want null-ls *not* to load for 'move'
  --   ft = { YOUR_OTHER_LANGUAGES_HERE },
  --   opts = function(_, opts)
  --      local nls = require("null-ls")
  --      table.insert(opts.sources, nls.builtins.formatting.prettier) -- Generic source
  --   end,
  -- }
}

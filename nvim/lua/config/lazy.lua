local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Require the transparency utility module.
-- Make sure this file exists at lua/utils/transparency.lua
local transparency_utils = require("util.transparency")

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        -- Disable LazyVim's default cmp config
        cmp = {
          enabled = false,
        },
        -- Explicitly disable AI extras
        extras = {
          ai = {
            copilot = false,
          },
        },
      },
    },
    -- import/override with your plugins
    { import = "plugins" },

    --- Colorscheme: folke/tokyonight.nvim
    -- This colorscheme has built-in transparency options.
    {
      "folke/tokyonight.nvim",
      lazy = false, -- Load this colorscheme on startup
      priority = 1000, -- Ensure it loads before other UI-related plugins
      opts = {
        style = "moon", -- Choose your preferred style: 'moon', 'storm', 'night', 'day'
        -- UNCOMMENT THIS BLOCK TO ACTIVATE TRANSPARENCY
        transparent = true, -- Enable core transparency
        styles = {
          sidebars = "transparent", -- Make sidebars (like NvimTree) transparent
          floats = "transparent", -- Make floating windows (like LSP info, Telescope) transparent
        },
      },
      -- config = function()
      --   vim.cmd.colorscheme("tokyonight")
      -- end,
    },

    --- Custom Transparency Logic and Toggle
    -- This dummy entry uses Lazy.nvim's 'config' to run your custom transparency setup.
    -- It ensures your custom transparency (and toggle) applies *after* the colorscheme.
    {
      "folke/lazy.nvim", -- Using lazy.nvim itself as a placeholder for config
      name = "my_custom_transparency_setup", -- A unique name for clarity
      lazy = false, -- Load this configuration on startup

      config = function()
        -- Initial transparency application when Neovim starts.
        -- This will be overridden by the colorscheme first, then reapplied by the autocommand.
        --
        -- AMD THIS ALSO
        transparency_utils.enable()

        -- Auto-reapply custom transparency after any colorscheme loads.
        -- This is crucial to ensure your custom highlight settings (bg=NONE)
        -- persist even if a colorscheme tries to set a background.
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = function()
            -- Only re-enable if our custom transparency is currently toggled on.
            if transparency_utils.is_enabled() then
              transparency_utils.enable()
            end
          end,
        })

        -- Define the keymap to toggle transparency.
        vim.keymap.set("n", "<leader>at", transparency_utils.toggle, {
          desc = "Toggle Neovim Transparency",
          noremap = true,
          silent = true,
        })
      end,
    },

    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "cairo" }, -- Add if parser available
        highlight = { enable = true },
      },
    },
    -- Add or modify this entry for mason-lspconfig.nvim
    {
      "williamboman/mason-lspconfig.nvim",
      lazy = false, -- THIS IS THE CRUCIAL LINE
      dependencies = { "williamboman/mason.nvim" },
    },
    -- { "tribela/vim-transparent" }, -- Keep commented out unless specifically needed.
    {
      "saghen/blink.cmp",
      enabled = false,
    },
    { import = "plugins.languages.astro" },
    { import = "plugins.languages.docker" },
    { import = "plugins.languages.go" },
    { import = "plugins.languages.markdown" },
    { import = "plugins.languages.mdx" },
    { import = "plugins.languages.python" },
    { import = "plugins.languages.typescript" },
    { import = "plugins.test.core" },
    { import = "plugins.formatting.conform" },
    { import = "plugins.formatting.prettier" },
    { import = "plugins.util.mini-hipatterns" },

    {
      "christoomey/vim-tmux-navigator",
      cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
      },
      keys = {
        { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
        { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
        { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
        { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
        { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
      },
    },
    { "ryanoasis/vim-devicons", lazy = true, event = "VeryLazy" }, -- Minimal setup
    {
      "yanganto/move.vim",
      branch = "sui-move",
    },
    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").setup({})
      end,
    },
    -- {
    --   "Pocco81/auto-save.nvim",
    --   opts = {
    --     enabled = true,
    --     events = { "InsertLeave", "TextChanged" }, -- Save on leaving insert mode or text changes
    --     write_all_buffers = false, -- Only save current buffer
    --     debounce_delay = 135, -- Delay to avoid excessive saves
    --   },
    -- },
    { "Mofiqul/vscode.nvim" },
    {
      "onsails/lspkind.nvim",
      lazy = true,
    },
    {
      "hrsh7th/nvim-cmp",
      enabled = true,
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
      },
    },
    -- null-ls for formatting
    {
      "jose-elias-alvarez/null-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  -- Lazy.nvim UI configuration (usually at the end)
  -- ui = {
  --   -- If you are using a Nerd Font: set icons to an empty table which will use the
  --   -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
  --   icons = vim.g.have_nerd_font and {} or {
  --     cmd = "⌘",
  --     config = "🛠",
  --     event = "📅",
  --     ft = "📂",
  --     init = "⚙",
  --     keys = "🗝",
  --     plugin = "🔌",
  --     runtime = "💻",
  --     require = "🌙",
  --     source = "📄",
  --     start = "🚀",
  --     task = "📌",
  --     lazy = "💤 ",
  --   },
  -- },
})
-- ---------------------------------------------------------------
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not (vim.uv or vim.loop).fs_stat(lazypath) then
--   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
--   local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
--   if vim.v.shell_error ~= 0 then
--     vim.api.nvim_echo({
--       { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
--       { out, "WarningMsg" },
--       { "\nPress any key to exit..." },
--     }, true, {})
--     vim.fn.getchar()
--     os.exit(1)
--   end
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- require("lazy").setup({
--   spec = {
--     -- add LazyVim and import its plugins
--     {
--       "LazyVim/LazyVim",
--       import = "lazyvim.plugins",
--       opts = {
--         -- Disable LazyVim's default cmp config
--         cmp = {
--           enabled = false,
--         },
--       },
--     },
--     -- import/override with your plugins
--     { import = "plugins" },
--
--     {
--       "folke/tokyonight.nvim",
--       opts = {
--         transparent = true,
--         styles = {
--           sidebars = "transparent",
--           floats = "transparent",
--         },
--       },
--     },
--     {
--       "nvim-treesitter/nvim-treesitter",
--       opts = {
--         ensure_installed = { "cairo" }, -- Add if parser available
--         highlight = { enable = true },
--       },
--     },
--     -- Add or modify this entry for mason-lspconfig.nvim
--     {
--       "williamboman/mason-lspconfig.nvim",
--       lazy = false, -- THIS IS THE CRUCIAL LINE
--       dependencies = { "williamboman/mason.nvim" },
--     },
--     -- { "tribela/vim-transparent" },
--     {
--       "saghen/blink.cmp",
--       enabled = false,
--     },
--     { import = "plugins.languages.astro" },
--     { import = "plugins.languages.docker" },
--     { import = "plugins.languages.go" },
--     { import = "plugins.languages.markdown" },
--     { import = "plugins.languages.mdx" },
--     { import = "plugins.languages.python" },
--     { import = "plugins.languages.typescript" },
--     { import = "plugins.test.core" },
--     { import = "plugins.formatting.conform" },
--     { import = "plugins.formatting.prettier" },
--     { import = "plugins.util.mini-hipatterns" },
--
--     {
--       "christoomey/vim-tmux-navigator",
--       cmd = {
--         "TmuxNavigateLeft",
--         "TmuxNavigateDown",
--         "TmuxNavigateUp",
--         "TmuxNavigateRight",
--         "TmuxNavigatePrevious",
--         "TmuxNavigatorProcessList",
--       },
--       keys = {
--         { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
--         { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
--         { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
--         { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
--         { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
--       },
--     },
--     { "ryanoasis/vim-devicons", lazy = true, event = "VeryLazy" }, -- Minimal setup
--     {
--       "yanganto/move.vim",
--       branch = "sui-move",
--     },
--     -- Telescope
--     {
--       "nvim-telescope/telescope.nvim",
--       dependencies = { "nvim-lua/plenary.nvim" },
--       config = function()
--         require("telescope").setup({})
--       end,
--     },
--     -- {
--     --   "Pocco81/auto-save.nvim",
--     --   opts = {
--     --     enabled = true,
--     --     events = { "InsertLeave", "TextChanged" }, -- Save on leaving insert mode or text changes
--     --     write_all_buffers = false, -- Only save current buffer
--     --     debounce_delay = 135, -- Delay to avoid excessive saves
--     --   },
--     -- },
--     { "Mofiqul/vscode.nvim" },
--     {
--       "onsails/lspkind.nvim",
--       lazy = true,
--     },
--     {
--       "hrsh7th/nvim-cmp",
--       enabled = true,
--       dependencies = {
--         "hrsh7th/cmp-nvim-lsp",
--         "hrsh7th/cmp-buffer",
--         "hrsh7th/cmp-path",
--         "saadparwaiz1/cmp_luasnip",
--         "L3MON4D3/LuaSnip",
--       },
--     },
--     -- null-ls for formatting
--     {
--       "jose-elias-alvarez/null-ls.nvim",
--       dependencies = { "nvim-lua/plenary.nvim" },
--     },
--   },
--   defaults = {
--     -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
--     -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
--     lazy = false,
--     -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
--     -- have outdated releases, which may break your Neovim install.
--     version = false, -- always use the latest git commit
--     -- version = "*", -- try installing the latest stable version for plugins that support semver
--   },
--   install = { colorscheme = { "tokyonight", "habamax" } },
--   checker = {
--     enabled = true, -- check for plugin updates periodically
--     notify = false, -- notify on update
--   }, -- automatically check for plugin updates
--   performance = {
--     rtp = {
--       -- disable some rtp plugins
--       disabled_plugins = {
--         "gzip",
--         -- "matchit",
--         -- "matchparen",
--         -- "netrwPlugin",
--         "tarPlugin",
--         "tohtml",
--         "tutor",
--         "zipPlugin",
--       },
--     },
--   },
--   {
--     ui = {
--       -- If you are using a Nerd Font: set icons to an empty table which will use the
--       -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
--       icons = vim.g.have_nerd_font and {} or {
--         cmd = "⌘",
--         config = "🛠",
--         event = "📅",
--         ft = "📂",
--         init = "⚙",
--         keys = "🗝",
--         plugin = "🔌",
--         runtime = "💻",
--         require = "🌙",
--         source = "📄",
--         start = "🚀",
--         task = "📌",
--         lazy = "💤 ",
--       },
--     },
--   },
-- })
-- -- Apply vscode.nvim after the UI is fully loaded and the loading screen is gone
-- -- vim.api.nvim_create_autocmd("UIEnter", {
-- --   callback = function()
-- --     vim.cmd("colorscheme vscode")
-- --   end,
-- -- })

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

-- Transparency utility module (lua/util/transparency.lua)
local transparency_utils = require("util.transparency")
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        -- Disable LazyVim's default cmp config
        -- cmp = {
        --   enabled = false,
        -- },
        -- Explicitly disable AI extras
        -- extras = {
        --   ai = {
        --     copilot = false,
        --   },
        -- },
      },
    },
    -- import/override with your plugins
    { import = "plugins" },

    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "cairo" }, -- Add if parser available
        highlight = { enable = true },
      },
    },
    -- Add or modify this entry for mason-lspconfig.nvim
    {
      "mason-org/mason-lspconfig.nvim",
      lazy = false, -- THIS IS THE CRUCIAL LINE
      dependencies = { "mason-org/mason.nvim" },
    },
    -- { "tribela/vim-transparent" }, -- Keep commented out unless specifically needed.
    -- {
    --   "saghen/blink.cmp",
    --   enabled = false,
    -- },
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
      "folke/noice.nvim",
      opts = {
        presets = {
          lsp_doc_border = true, -- adds border to hover docs and signature help
        },
      },
    },
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

    { "Mofiqul/vscode.nvim" },
    {
      "onsails/lspkind.nvim",
      lazy = true,
    },
    { "saghen/blink.cmp", enabled = true },
    {
      "saghen/blink.cmp",
      opts = {
        completion = {
          menu = { border = "rounded" },
          documentation = { window = { border = "rounded" } },
        },
      },
    },

    { "hrsh7th/nvim-cmp", enabled = false },
    { "hrsh7th/cmp-nvim-lsp", enabled = false },
    { "hrsh7th/cmp-buffer", enabled = false },
    { "hrsh7th/cmp-path", enabled = false },
    { "hrsh7th/cmp-emoji", enabled = false },
    { "saadparwaiz1/cmp_luasnip", enabled = false },
    --- Colorscheme: folke/tokyonight.nvim
    -- This colorscheme has built-in transparency options.
    {
      "folke/tokyonight.nvim",
      lazy = false, -- Load this colorscheme on startup
      priority = 1000, -- Ensure it loads before other UI-related plugins
      opts = {
        style = "moon", -- Choose your preferred style: 'moon', 'storm', 'night', 'day'
        -- UNCOMMENT THIS BLOCK TO ACTIVATE TRANSPARENCY
        styles = {
          -- sidebars = "transparent", -- Make sidebars (like NvimTree) transparent
          floats = "transparent", -- Make floating windows (like LSP info, Telescope) transparent
        },
      },
      -- config = function()
      --   vim.cmd.colorscheme("tokyonight")
      -- end,
    },
    -- null-ls for formatting
    {
      -- "jose-elias-alvarez/null-ls.nvim",
      "nvimtools/none-ls.nvim",
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
  -- install = { colorscheme = { "tokyonight", "habamax" } },
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
})
-- ======================
-- Transparency setup & persistent toggle (PRO VERSION)
-- ======================

local transparency_file = vim.fn.stdpath("data") .. "/transparency.txt"

local function save_transparency_state(enabled)
  local f = io.open(transparency_file, "w")
  if f then
    f:write(enabled and "true" or "false")
    f:close()
  end
end

local function load_transparency_state()
  local f = io.open(transparency_file, "r")
  if f then
    local state = f:read("*l")
    f:close()
    return state == "true"
  end
  return false
end

-- ======================
-- AUTOCMDS (robust + correct timing)
-- ======================

-- Reapply after ANY colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    if transparency_utils.is_enabled() then
      transparency_utils.reapply()
    end
  end,
})

-- LazyVim / lazy.nvim fully loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    if transparency_utils.is_enabled() then
      transparency_utils.reapply()
    end
  end,
})

-- Telescope fully rendered (CRUCIAL FIX)
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    if transparency_utils.is_enabled() then
      transparency_utils.reapply()
    end
  end,
})

-- Fallback for Telescope prompt edge cases
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function()
    if transparency_utils.is_enabled() then
      vim.schedule(transparency_utils.reapply)
    end
  end,
})

-- ======================
-- STARTUP STATE (clean + deterministic)
-- ======================

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local state = load_transparency_state()
    if state then
      transparency_utils.enable()
    else
      transparency_utils.disable()
    end
  end,
})

-- ======================
-- KEYMAP (toggle + persist)
-- ======================

vim.keymap.set("n", "<leader>at", function()
  transparency_utils.toggle()
  save_transparency_state(transparency_utils.is_enabled())
end, {
  desc = "Toggle Transparency",
  noremap = true,
  silent = true,
})

-- =======================
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
--       "mason-org/mason-lspconfig.nvim",
--       lazy = false, -- THIS IS THE CRUCIAL LINE
--       dependencies = { "mason-org/mason.nvim" },
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

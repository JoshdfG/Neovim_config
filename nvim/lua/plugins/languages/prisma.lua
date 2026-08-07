-- lua/plugins/prisma.lua
return {
  -- 1. Ensure Treesitter syntax highlighting for Prisma schema files
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        table.insert(opts.ensure_installed, "prisma")
      end
    end,
  },

  -- 2. Configure Mason to auto-install the Prisma Language Server
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "prisma-language-server")
    end,
  },

  -- 3. Configure nvim-lspconfig to enable prismals
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        prismals = {},
      },
    },
  },
}

local mason = {
  "mason-org/mason.nvim",
  cmd = "Mason",
  event = "BufReadPre",
  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  },
}

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

local mason_lspconfig = {
  capabilities = capabilities,
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      -- Existing servers
      "solidity_ls",
      "efm",
      "bashls",
      "ts_ls",
      "tailwindcss-language-server",
      "pyright",
      "lua_ls",
      "emmet_ls",
      "jsonls",
      "clangd",
      "dockerls",
      -- Add missing language servers
      "gopls", -- Go
      "marksman", -- Markdown
      "sqls", -- SQL
      "taplo", -- TOML
    },
    automatic_installation = true,
  },
  event = "BufReadPre",
  dependencies = "mason-org/mason.nvim",
}

-- Optionally, configure mason to install non-LSP tools
local mason_tools = {

  capabilities = capabilities,
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = {
        ensure_installed = {
          -- Linting and formatting tools
          "hadolint", -- Docker
          "golangci-lint", -- Go
          "delve", -- Go debugging
          "markdownlint", -- Markdown
          "prettier", -- JSON, Markdown, Tailwind, TypeScript
          "ruff", -- Python
          "black", -- Python
          "debugpy", -- Python debugging
          "sql-formatter", -- SQL
          "eslint_d", -- TypeScript (fixed from "eslint")
          "js-debug-adapter", -- TypeScript debugging
        },
      },
    },
  },
}

return {
  mason,
  mason_lspconfig,
  mason_tools,
}

-- local mason = {
-- 	"mason-org/mason.nvim",
-- 	cmd = "Mason",
-- 	event = "BufReadPre",
-- 	opts = {
-- 		ui = {
-- 			icons = {
-- 				package_installed = "✓",
-- 				package_pending = "➜",
-- 				package_uninstalled = "✗",
-- 			},
-- 		},
-- 	},
-- }
--
-- local mason_lspconfig = {
-- 	"mason-org/mason-lspconfig.nvim",
-- 	opts = {
-- 		ensure_installed = {
-- 			"solidity_ls",
-- 			"efm",
-- 			"bashls",
-- 			"ts_ls",
-- 			"tailwindcss",
-- 			"pyright",
-- 			"lua_ls",
-- 			"emmet_ls",
-- 			"jsonls",
-- 			"clangd",
-- 			"dockerls",
-- 		},
-- 		automatic_installation = true,
-- 	},
-- 	event = "BufReadPre",
-- 	dependencies = "mason-org/mason.nvim",
-- }
--
-- return {
-- 	mason,
-- 	mason_lspconfig,
-- }

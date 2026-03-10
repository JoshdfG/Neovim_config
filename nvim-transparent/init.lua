-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.autocmds")
-- require("neotest.logging"):set_level(vim.log.levels.INFO)
--
-- Set clipboard to use system clipboard
vim.opt.clipboard = "unnamedplus"

vim.lsp.enable("cairo_ls")

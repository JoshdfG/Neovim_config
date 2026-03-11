local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.swapfile = false
vim.fn.setfiletype({ "move" })
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.helpers")
require("noice").setup({ enabled = false })
require("snacks").setup({ image = { enabled = false } })
require("lspconfig").sqls.setup({})
-- Optional, you don't have to run setup.
-- v

-- Diagnostics floating window
vim.diagnostic.config({
  float = { border = "rounded" },
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Force cmp to load immediately after vim starts
    require("cmp")
  end,
})

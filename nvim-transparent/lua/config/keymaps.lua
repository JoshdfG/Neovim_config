-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Format SQL with pg_format manually
vim.keymap.set("n", "<leader>pf", ":%!pg_format -<CR>", { desc = "[P]ostgres [F]ormat" })

-- vim.keymap.set("n", "<leader>r", "<cmd>NeotreeRefresh<CR>", { desc = "♻️ Refresh Neo-tree" })
vim.keymap.set("n", "<leader>rr", ":source %<CR>", { desc = "♻️Reload current file (source %)" })

-- to view all diagnostic in a file
vim.keymap.set("n", "<leader>ca", function()
  vim.diagnostic.setqflist()
end, { desc = "Diagnostics (all)" })

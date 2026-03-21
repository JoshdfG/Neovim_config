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

-- map jk to ESC to prevent reaching for the ESC key each time
--
vim.api.nvim_set_keymap("i", "<leader>jk", "<Esc>", { noremap = false })

-- In an ftplugin file or your main init.lua with appropriate autocmd
-- Check if the popup menu is visible before deciding whether to navigate or just move the cursor
vim.api.nvim_set_keymap("i", "<expr>j", 'pumvisible() ? "\\<C-n>" : "j"', { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "<expr>k", 'pumvisible() ? "\\<C-p>" : "k"', { noremap = true, silent = true })

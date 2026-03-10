-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- auto-format on save
local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_fmt_group,
  callback = function()
    local efm = vim.lsp.get_clients({ name = "efm" })

    if vim.tbl_isempty(efm) then
      return
    end

    vim.lsp.buf.format({ name = "efm", async = true })
  end,
})

-- highlight on yank
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYankGroup", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_yank_group,
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- Autocommand for Solidity files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.sol",
  callback = function()
    vim.cmd("silent! !forge fmt %") -- Run forge fmt
    vim.cmd("e!") -- Reload the file to reflect changes
  end,
})
-- For Lua config
vim.cmd([[
  highlight Bold gui=NONE cterm=NONE
  hi! link htmlBold Bold
  hi! link markdownBold Bold
]])

-- Cairo lang formatter
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.cairo",
  callback = function()
    vim.cmd("silent! !scarb fmt %") -- Run forge fmt
    vim.cmd("e!") -- Reload the file to reflect changes
  end,
})
-- Format move files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.move",
--   callback = function()
--     vim.lsp.buf.format({
--       async = false,
--       filter = function(client)
--         return client.name == "move_analyzer" -- Only use Move LSP formatter
--       end,
--     })
--   end,
-- })

-- Auto-format SQL files on save using sqlfluff (PostgreSQL dialect)
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.sql",
--   callback = function()
--     -- Save cursor position
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     -- Format with sqlfluff (PostgreSQL mode)
--     vim.cmd("%!sqlfluff fix --dialect postgres -")
--     -- Restore cursor
--     vim.api.nvim_win_set_cursor(0, cursor_pos)
--   end,
-- })

-- Go
-- Autocommand for Go files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Auto-format PostgreSQL/SQL files on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.sql",
--   callback = function()
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     vim.cmd("%!pg_format -g -") -- 👈 '-g' removes space in functions
--     vim.api.nvim_win_set_cursor(0, cursor_pos)
--   end,
-- })
-- Autocommand for Rust files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*.rs",
--     callback = function()
--         vim.lsp.buf.format({ async = false })
--     end,
-- })

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.ts", "*.tsx", "*.jsx", "*.css", "*.scss", "*.html" },
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })

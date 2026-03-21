-- ~/.config/nvim/lua/config/keybindings.lua
local M = {}

M.on_attach = function(client, bufnr)
  -- Enable LSP keymaps only for supported capabilities
  local opts = { buffer = bufnr, silent = true }

  -- Always available mappings
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

  -- Only set up goto definition if supported
  if client.server_capabilities.definitionProvider then
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  end

  -- Only set up implementations if supported
  if client.server_capabilities.implementationProvider then
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  else
    -- Fallback to definition for Solidity
    if client.name == "solidity" then
      vim.keymap.set("n", "gi", vim.lsp.buf.definition, opts)
    end
  end

  -- Diagnostics
  vim.keymap.set("n", "[d", vim.diagnostic.get_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.get_next, opts)
end

return M

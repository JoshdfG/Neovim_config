-- local mapkey = require("util.keymapper").mapvimkey

local M = {}

-- M.on_attach = function(client, bufnr)
-- 	local opts = { noremap = true, silent = true, buffer = bufnr }

-- 	mapkey("<leader>fd", "Lspsaga finder", "n", opts) -- go to definition
-- 	mapkey("<leader>gd", "Lspsaga peek_definition", "n", opts) -- peak definition
-- 	mapkey("<leader>gD", "Lspsaga goto_definition", "n", opts) -- go to definition
-- 	mapkey("<leader>gS", "vsplit | Lspsaga goto_definition", "n", opts) -- go to definition
-- 	mapkey("<leader>ca", "Lspsaga code_action", "n", opts) -- see available code actions
-- 	mapkey("<leader>rn", "Lspsaga rename", "n", opts) -- smart rename
-- 	mapkey("<leader>D", "Lspsaga show_line_diagnostics", "n", opts) -- show  diagnostics for line
-- 	mapkey("<leader>d", "Lspsaga show_cursor_diagnostics", "n", opts) -- show diagnostics for cursor
-- 	mapkey("<leader>pd", "Lspsaga diagnostic_jump_prev", "n", opts) -- jump to prev diagnostic in buffer
-- 	mapkey("<leader>nd", "Lspsaga diagnostic_jump_next", "n", opts) -- jump to next diagnostic in buffer
-- 	mapkey("K", "Lspsaga hover_doc", "n", opts) -- show documentation for what is under cursor

-- 	if client.name == "pyright" then
-- 		mapkey("<leader>oi", "PyrightOrganizeImports", "n", opts) -- organise imports
-- 		mapkey("<leader>db", "DapToggleBreakpoint", "n", opts) -- toggle breakpoint
-- 		mapkey("<leader>dr", "DapContinue", "n", opts) -- continue/invoke debugger
-- 		mapkey("<leader>dt", "lua require('dap-python').test_method()", "n", opts) -- run tests
-- 	end

-- 	if client.name == "ts_ls" then
-- 		mapkey("<leader>oi", "TypeScriptOrganizeImports", "n", opts) -- organise imports
-- 	end
-- end

-- optional utility: organize imports for TS/JS

M.typescript_organise_imports = {
  description = "Organise Imports",
  function()
    local params = {
      command = "_typescript.organizeImports",
      arguments = { vim.fn.expand("%:p") },
    }

    -- new correct API
    vim.lsp.buf_request(0, "workspace/executeCommand", params, function(err)
      if err then
        vim.notify("Organise imports failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end,
}

-- proper on_attach used by all LSP servers
function M.on_attach(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    local opts = { buffer = bufnr, noremap = true, silent = true, desc = desc }
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- generic LSP keymaps
  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "gr", vim.lsp.buf.references, "Find references")
  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
end

return M


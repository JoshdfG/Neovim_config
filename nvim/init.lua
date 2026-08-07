-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.autocmds")
-- require("neotest.logging"):set_level(vim.log.levels.INFO)
--
-- Set clipboard to use system clipboard
vim.opt.clipboard = "unnamedplus"

vim.lsp.enable("cairo_ls")

-- File to persist colorscheme
local theme_file = vim.fn.stdpath("data") .. "/colorscheme.txt"

-- Load saved colorscheme on startup
local f = io.open(theme_file, "r")
if f then
  local scheme = f:read("*l")
  f:close()
  if scheme and scheme ~= "" then
    vim.cmd.colorscheme(scheme)
  end
end

-- -- Warm grey split divider (overrides colorscheme default)
-- local function set_split_color()
--   vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#333", bg = "NONE" })
--   vim.api.nvim_set_hl(0, "VertSplit", { fg = "#333", bg = "NONE" })
-- end
-- set_split_color()

-- Auto-save colorscheme whenever it changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local file = io.open(theme_file, "w")
    if file then
      file:write(vim.g.colors_name)
      file:close()
    end
  end,
})

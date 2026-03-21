-- lazydocker.nvim
return {
  "mgierada/lazydocker.nvim",
  dependencies = { "akinsho/toggleterm.nvim" },
  config = function()
    require("lazydocker").setup({
      border = "curved", -- valid options are "single" | "double" | "shadow" | "curved"
    })
  end,
  event = "BufRead",
  keys = {
    {
      "<leader>ld",
      function()
        require("lazydocker").open()
      end,
      desc = "Open Lazydocker floating window",
    },
  },
}
-- return {
--   -- Add lazydocker integration
--   {
--     "akinsho/toggleterm.nvim",
--     version = "*",
--     config = function()
--       require("toggleterm").setup({
--         size = 20,
--         open_mapping = [[<c-\>]],
--         hide_numbers = true,
--         shade_filetypes = {},
--         shade_terminals = true,
--         shading_factor = 2,
--         start_in_insert = true,
--         insert_mappings = true,
--         persist_size = true,
--         direction = "float",
--         close_on_exit = true,
--         shell = vim.o.shell,
--         float_opts = {
--           border = "curved",
--           winblend = 0,
--           highlights = {
--             border = "Normal",
--             background = "Normal",
--           },
--         },
--       })
--
--       -- Create a lazydocker terminal
--       local Terminal = require("toggleterm.terminal").Terminal
--       local lazydocker = Terminal:new({
--         cmd = "lazydocker",
--         hidden = true,
--         direction = "float",
--         float_opts = {
--           border = "curved",
--         },
--       })
--
--       -- Function to toggle lazydocker
--       function _lazydocker_toggle()
--         lazydocker:toggle()
--       end
--
--       -- Set keymapping to open lazydocker
--       vim.keymap.set("n", "<leader>td", "<cmd>lua _lazydocker_toggle()<CR>", {
--         desc = "Lazydocker",
--         noremap = true,
--         silent = true
--       })
--     end,
--   },
-- }

return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost", -- Load only when a buffer is opened
  config = function()
    require("scrollbar").setup({
      -- handle = {
      --     color = "#888888", -- Customize scrollbar color
      -- },
      marks = {
        Search = { color = "#ffcc00" },
        Error = { color = "#ff5555" },
        Warn = { color = "#ffaa00" },
        Info = { color = "#00aaff" },
        Hint = { color = "#44ff44" },
      },
    })
  end,
}

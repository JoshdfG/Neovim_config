-- lua/plugins/crates.lua
return {
  "Saecki/crates.nvim",
  event = { "BufRead Cargo.toml" }, -- Keep this instead of ft = {"toml"} for specificity
  config = function(_)
    local crates = require("crates")
    crates.setup({
      completion = {
        crates = {
          enabled = true, -- Enable completion for crate versions
        },
      },
      lsp = {
        enabled = true, -- Enable LSP features for Cargo.toml
        actions = true, -- Enable automatic version updates
        completion = true, -- Enable completion for crate names
        hover = true, -- Enable hover information for crates
      },
    })
    -- Add nvim-cmp source for the current buffer
    require("cmp").setup.buffer({
      sources = { { name = "crates" } },
    })
    crates.show() -- Show crate info immediately
    -- Optional: Add keymaps if you have a utils module
    -- require("core.utils").load_mappings("crates")
  end,
}

-- {
-- "Saecki/crates.nvim",
--   event = { "BufRead Cargo.toml" }, -- Load the plugin when a Cargo.toml file is opened
--   opts = {
--     completion = {
--       crates = {
--         enabled = true, -- Enable completion for crate versions
--       },
--     },
--     lsp = {
--       enabled = true, -- Enable LSP features for Cargo.toml
--       actions = true, -- Enable automatic version updates
--       completion = true, -- Enable completion for crate names
--       hover = true, -- Enable hover information for crates
--     },
--   },
-- }

-- works for hover docs --------
return {
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "hrsh7th/cmp-emoji",
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      vim.opt.completeopt = { "menu", "menuone", "preview", "noselect" }
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Using LazyVim default highlight groups for completion menu
      -- No custom highlight overrides here
      local border_opts = {
        border = "rounded",
        -- Using default LazyVim winhighlight
      }
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(border_opts),
          documentation = cmp.config.window.bordered(border_opts),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Kind icons
            local kind_icons = {
              Text = "",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰇽",
              Variable = "󰂡",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "󰅲",
            }

            -- Handle Tailwind color completions
            local function is_tailwind_color(item_text)
              -- Check if it's a Tailwind color class (e.g., bg-red-500, text-blue-300)
              return item_text:match("^[a-z]+-[a-z]+-[0-9]+$")
                or item_text:match("^[a-z]+-[a-z]+$")
                or item_text:match("^#%x%x%x%x%x%x$") -- hex colors
                or item_text:match("^rgb%(.+%)$") -- rgb colors
                or item_text:match("^hsl%(.+%)$") -- hsl colors
            end

            local function get_tailwind_color_value(color_class)
              -- Tailwind color mappings (you can extend this)
              local tailwind_colors = {
                -- Red colors
                ["red-50"] = "#fef2f2",
                ["red-100"] = "#fee2e2",
                ["red-200"] = "#fecaca",
                ["red-300"] = "#fca5a5",
                ["red-400"] = "#f87171",
                ["red-500"] = "#ef4444",
                ["red-600"] = "#dc2626",
                ["red-700"] = "#b91c1c",
                ["red-800"] = "#991b1b",
                ["red-900"] = "#7f1d1d",
                ["red-950"] = "#450a0a",

                -- Blue colors
                ["blue-50"] = "#eff6ff",
                ["blue-100"] = "#dbeafe",
                ["blue-200"] = "#bfdbfe",
                ["blue-300"] = "#93c5fd",
                ["blue-400"] = "#60a5fa",
                ["blue-500"] = "#3b82f6",
                ["blue-600"] = "#2563eb",
                ["blue-700"] = "#1d4ed8",
                ["blue-800"] = "#1e40af",
                ["blue-900"] = "#1e3a8a",
                ["blue-950"] = "#172554",

                -- Green colors
                ["green-50"] = "#f0fdf4",
                ["green-100"] = "#dcfce7",
                ["green-200"] = "#bbf7d0",
                ["green-300"] = "#86efac",
                ["green-400"] = "#4ade80",
                ["green-500"] = "#22c55e",
                ["green-600"] = "#16a34a",
                ["green-700"] = "#15803d",
                ["green-800"] = "#166534",
                ["green-900"] = "#14532d",
                ["green-950"] = "#052e16",

                -- Purple colors
                ["purple-50"] = "#faf5ff",
                ["purple-100"] = "#f3e8ff",
                ["purple-200"] = "#e9d5ff",
                ["purple-300"] = "#d8b4fe",
                ["purple-400"] = "#c084fc",
                ["purple-500"] = "#a855f7",
                ["purple-600"] = "#9333ea",
                ["purple-700"] = "#7c3aed",
                ["purple-800"] = "#6b46c1",
                ["purple-900"] = "#581c87",
                ["purple-950"] = "#3b0764",

                -- Gray colors
                ["gray-50"] = "#f9fafb",
                ["gray-100"] = "#f3f4f6",
                ["gray-200"] = "#e5e7eb",
                ["gray-300"] = "#d1d5db",
                ["gray-400"] = "#9ca3af",
                ["gray-500"] = "#6b7280",
                ["gray-600"] = "#4b5563",
                ["gray-700"] = "#374151",
                ["gray-800"] = "#1f2937",
                ["gray-900"] = "#111827",
                ["gray-950"] = "#030712",

                -- Additional common colors
                ["yellow-50"] = "#fefce8",
                ["yellow-100"] = "#fef3c7",
                ["yellow-200"] = "#fde68a",
                ["yellow-300"] = "#fcd34d",
                ["yellow-400"] = "#fbbf24",
                ["yellow-500"] = "#f59e0b",
                ["yellow-600"] = "#d97706",
                ["yellow-700"] = "#b45309",
                ["yellow-800"] = "#92400e",
                ["yellow-900"] = "#78350f",
                ["yellow-950"] = "#451a03",

                ["indigo-50"] = "#eef2ff",
                ["indigo-100"] = "#e0e7ff",
                ["indigo-200"] = "#c7d2fe",
                ["indigo-300"] = "#a5b4fc",
                ["indigo-400"] = "#818cf8",
                ["indigo-500"] = "#6366f1",
                ["indigo-600"] = "#4f46e5",
                ["indigo-700"] = "#4338ca",
                ["indigo-800"] = "#3730a3",
                ["indigo-900"] = "#312e81",
                ["indigo-950"] = "#1e1b4b",

                ["pink-50"] = "#fdf2f8",
                ["pink-100"] = "#fce7f3",
                ["pink-200"] = "#fbcfe8",
                ["pink-300"] = "#f9a8d4",
                ["pink-400"] = "#f472b6",
                ["pink-500"] = "#ec4899",
                ["pink-600"] = "#db2777",
                ["pink-700"] = "#be185d",
                ["pink-800"] = "#9d174d",
                ["pink-900"] = "#831843",
                ["pink-950"] = "#500724",
              }

              -- Extract color from class (e.g., "bg-red-500" -> "red-500")
              local color_part = color_class:match("[a-z]+-([a-z]+-[0-9]+)$") or color_class:match("[a-z]+-([a-z]+)$")

              return tailwind_colors[color_part]
            end

            local function create_color_square(color_value)
              -- Create a colored square using Unicode block character
              if not color_value then
                return "■"
              end

              -- Create highlight group for this color
              local hl_name = "TailwindColor" .. color_value:gsub("#", ""):gsub("%W", "")
              vim.api.nvim_set_hl(0, hl_name, { fg = color_value, bg = "NONE" })

              return { "■", hl_name }
            end

            -- Check if this is a color-related completion
            if vim_item.kind == "Color" or is_tailwind_color(vim_item.abbr) then
              local color_value = get_tailwind_color_value(vim_item.abbr)

              if color_value then
                -- Replace the color icon with actual color square
                local color_square = create_color_square(color_value)
                vim_item.kind_hl_group = color_square[2]
                vim_item.kind = color_square[1] .. " Color"
              else
                -- Fallback for other colors (hex, rgb, etc.)
                if vim_item.abbr:match("^#%x%x%x%x%x%x$") then
                  local color_square = create_color_square(vim_item.abbr)
                  vim_item.kind_hl_group = color_square[2]
                  vim_item.kind = color_square[1] .. " Color"
                else
                  vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
                end
              end
            else
              -- Regular kind icons for non-color items
              vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
            end

            vim_item.menu = ({
              copilot = "[Copilot]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
              emoji = "[Emoji]",
            })[entry.source.name]

            return vim_item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "copilot", group_index = 2 },
          { name = "nvim_lsp", group_index = 2 },
          { name = "luasnip", group_index = 2 },
          { name = "emoji" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
-- works for hover docs --------
-- return {
--   {
--     "hrsh7th/cmp-nvim-lsp",
--   },
--   {
--     "hrsh7th/cmp-emoji",
--   },
--   {
--     "L3MON4D3/LuaSnip",
--     dependencies = {
--       "saadparwaiz1/cmp_luasnip",
--       "rafamadriz/friendly-snippets",
--     },
--   },
--   {
--     "hrsh7th/nvim-cmp",
--     config = function()
--       vim.opt.completeopt = { "menu", "menuone", "preview", "noselect" }
--
--       local cmp = require("cmp")
--       local luasnip = require("luasnip")
--
--       -- Load friendly-snippets
--       require("luasnip.loaders.from_vscode").lazy_load()
--
--       -- Set transparent background highlights
--       vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
--       vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
--       vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
--       -- vim.api.nvim_set_hl(0, "PmenuSel", { bg = "NONE", bold = true })
--
--       local border_opts = {
--         border = "rounded",
--         winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel",
--       }
--
--       cmp.setup({
--         snippet = {
--           expand = function(args)
--             luasnip.lsp_expand(args.body)
--           end,
--         },
--         window = {
--           completion = cmp.config.window.bordered(border_opts),
--           documentation = cmp.config.window.bordered(border_opts),
--         },
--         formatting = {
--           fields = { "kind", "abbr", "menu" },
--           format = function(entry, vim_item)
--             -- Kind icons
--             local kind_icons = {
--               Text = "",
--               Method = "󰆧",
--               Function = "󰊕",
--               Constructor = "",
--               Field = "󰇽",
--               Variable = "󰂡",
--               Class = "󰠱",
--               Interface = "",
--               Module = "",
--               Property = "󰜢",
--               Unit = "",
--               Value = "󰎠",
--               Enum = "",
--               Keyword = "󰌋",
--               Snippet = "",
--               Color = "󰏘",
--               File = "󰈙",
--               Reference = "",
--               Folder = "󰉋",
--               EnumMember = "",
--               Constant = "󰏿",
--               Struct = "",
--               Event = "",
--               Operator = "󰆕",
--               TypeParameter = "󰅲",
--             }
--             -- This concatonates the icons with the name of the item kind
--             vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
--             vim_item.menu = ({
--               nvim_lsp = "[LSP]",
--               luasnip = "[Snippet]",
--               buffer = "[Buffer]",
--               path = "[Path]",
--               emoji = "[Emoji]",
--             })[entry.source.name]
--             return vim_item
--           end,
--         },
--         mapping = cmp.mapping.preset.insert({
--           ["<C-d>"] = cmp.mapping.scroll_docs(-4),
--           ["<C-f>"] = cmp.mapping.scroll_docs(4),
--           ["<C-Space>"] = cmp.mapping.complete(),
--           ["<C-e>"] = cmp.mapping.abort(),
--           ["<CR>"] = cmp.mapping.confirm({ select = true }),
--           ["<Tab>"] = cmp.mapping(function(fallback)
--             if cmp.visible() then
--               cmp.select_next_item()
--             elseif luasnip.expand_or_jumpable() then
--               luasnip.expand_or_jump()
--             else
--               fallback()
--             end
--           end, { "i", "s" }),
--           ["<S-Tab>"] = cmp.mapping(function(fallback)
--             if cmp.visible() then
--               cmp.select_prev_item()
--             elseif luasnip.jumpable(-1) then
--               luasnip.jump(-1)
--             else
--               fallback()
--             end
--           end, { "i", "s" }),
--         }),
--         sources = cmp.config.sources({
--           { name = "nvim_lsp" },
--           { name = "luasnip" },
--           { name = "emoji" },
--           { name = "buffer" },
--           { name = "path" },
--         }),
--       })
--     end,
--   },
-- }
--
-- return {
--
--   {
--     "hrsh7th/cmp-nvim-lsp",
--   },
--   {
--     "hrsh7th/cmp-emoji", -- Add cmp-emoji
--   },
--   {
--     "L3MON4D3/LuaSnip",
--     dependencies = {
--       "saadparwaiz1/cmp_luasnip",
--       "rafamadriz/friendly-snippets",
--     },
--   },
--   {
--     "hrsh7th/nvim-cmp",
--     config = function()
--       -- Set completeopt to ensure nvim-cmp controls completion
--       vim.opt.completeopt = { "menu", "menuone", "preview", "noselect" }
--
--       local cmp = require("cmp")
--       --end
--       require("luasnip.loaders.from_vscode").lazy_load()
--
--       cmp.setup({
--         snippet = {
--           expand = function(args)
--             require("luasnip").lsp_expand(args.body)
--           end,
--         },
--         window = {
--           completion = cmp.config.window.bordered(),
--           documentation = cmp.config.window.bordered(),
--         },
--         view = {
--           entries = { name = "custom", selection_order = "near_cursor" },
--         },
--         mapping = cmp.mapping.preset.insert({
--           ["<C-d>"] = cmp.mapping.scroll_docs(-4),
--           ["<C-f>"] = cmp.mapping.scroll_docs(4),
--           ["<C-Space>"] = cmp.mapping.complete(),
--           ["<C-e>"] = cmp.mapping.abort(),
--           ["<CR>"] = cmp.mapping.confirm({ select = true }),
--         }),
--         sources = cmp.config.sources({
--           { name = "nvim_lsp" },
--           { name = "luasnip" },
--           { name = "emoji" }, -- Add emoji source
--           { name = "buffer" },
--           { name = "path" },
--         }),
--       })
--     end,
--   },
-- }
--------------------------------------------------------
-- return {
--   {
--     "hrsh7th/cmp-nvim-lsp",
--   },
--   {
--     "L3MON4D3/LuaSnip",
--     dependencies = {
--       "saadparwaiz1/cmp_luasnip",
--       "rafamadriz/friendly-snippets",
--     },
--   },
--   {
--     "hrsh7th/nvim-cmp",
--     config = function()
--       local cmp = require("cmp")
--       require("luasnip.loaders.from_vscode").lazy_load()
--
--       cmp.setup({
--         snippet = {
--           expand = function(args)
--             require("luasnip").lsp_expand(args.body)
--           end,
--         },
--         window = {
--           completion = cmp.config.window.bordered(),
--           documentation = cmp.config.window.bordered(),
--         },
--         mapping = cmp.mapping.preset.insert({
--           ["<C-d>"] = cmp.mapping.scroll_docs(-4),
--           ["<C-f>"] = cmp.mapping.scroll_docs(4),
--           ["<C-Space>"] = cmp.mapping.complete(),
--           ["<C-e>"] = cmp.mapping.abort(),
--           ["<CR>"] = cmp.mapping.confirm({ select = true }),
--         }),
--         sources = cmp.config.sources({
--           { name = "nvim_lsp" },
--           { name = "luasnip" }, -- For luasnip users.
--         }, {
--           { name = "buffer" },
--         }),
--       })
--     end,
--   },
-- }

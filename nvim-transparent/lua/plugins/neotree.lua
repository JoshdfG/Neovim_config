return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    {
      "<leader>ge",
      function()
        require("neo-tree.command").execute({ source = "git_status", toggle = true })
      end,
      desc = "Git Explorer",
    },
    {
      "<leader>be",
      function()
        require("neo-tree.command").execute({ source = "buffers", toggle = true })
      end,
      desc = "Buffer Explorer",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
      desc = "Start Neo-tree with directory",
      once = true,
      callback = function()
        if package.loaded["neo-tree"] then
          return
        else
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end
      end,
    })
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      position = "right",
      width = 40,
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none",
        ["/"] = "fuzzy_finder",
        ["i"] = "filter_as_you_type",
        ["<esc>"] = "clear_filter",
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "Copy Path to Clipboard",
        },
        ["O"] = {
          function(state)
            require("lazy.util").open(state.tree:get_node().path, { system = true })
          end,
          desc = "Open with System Application",
        },
        ["P"] = { "toggle_preview", config = { use_float = false } },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      git_status = {
        symbols = {
          unstaged = "󰄱",
          staged = "󰱒",
        },
      },
    },
    -- This ensures the filter bar appears at the top of NeoTree
    use_popups_for_input = false,
    event_handlers = {
      {
        event = "neo_tree_popup_input_ready",
        -- This handles the popup input window when filtering
        handler = function(args)
          -- Switch to normal mode immediately
          vim.cmd("stopinsert")
          -- Also map ESC in this buffer to exit insert mode
          vim.keymap.set("i", "<esc>", function()
            vim.cmd("stopinsert")
          end, { noremap = true, buffer = args.bufnr })
        end,
      },
      {
        event = "neo_tree_buffer_enter",
        -- Handle ESC key to exit insert mode when in NeoTree buffer
        handler = function()
          vim.keymap.set("i", "<esc>", function()
            vim.cmd("stopinsert")
          end, { noremap = true, buffer = 0 })
        end,
      },
    },
  },
  config = function(_, opts)
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end
    local events = require("neo-tree.events")

    -- Ensure event_handlers is initialized
    opts.event_handlers = opts.event_handlers or {}

    -- Add file operation handlers
    vim.list_extend(opts.event_handlers, {
      { event = events.FILE_MOVED, handler = on_move },
      { event = events.FILE_RENAMED, handler = on_move },
    })

    require("neo-tree").setup(opts)
    -- Set transparent highlights for NeoTree
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { bg = "NONE", fg = "NONE" }) -- Adjust fg to match your theme
    vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
    -- End of transparent config

    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end,
    })
  end,
}
-- Former
-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   cmd = "Neotree",
--   keys = {
--     {
--       "<leader>fe",
--       function()
--         require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
--       end,
--       desc = "Explorer NeoTree (Root Dir)",
--     },
--     {
--       "<leader>fE",
--       function()
--         require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
--       end,
--       desc = "Explorer NeoTree (cwd)",
--     },
--     { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
--     { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
--     {
--       "<leader>ge",
--       function()
--         require("neo-tree.command").execute({ source = "git_status", toggle = true })
--       end,
--       desc = "Git Explorer",
--     },
--     {
--       "<leader>be",
--       function()
--         require("neo-tree.command").execute({ source = "buffers", toggle = true })
--       end,
--       desc = "Buffer Explorer",
--     },
--   },
--   deactivate = function()
--     vim.cmd([[Neotree close]])
--   end,
--   init = function()
--     vim.api.nvim_create_autocmd("BufEnter", {
--       group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
--       desc = "Start Neo-tree with directory",
--       once = true,
--       callback = function()
--         if package.loaded["neo-tree"] then
--           return
--         else
--           local stats = vim.uv.fs_stat(vim.fn.argv(0))
--           if stats and stats.type == "directory" then
--             require("neo-tree")
--           end
--         end
--       end,
--     })
--   end,
--   opts = {
--     sources = { "filesystem", "buffers", "git_status" },
--     open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
--     filesystem = {
--       bind_to_cwd = false,
--       follow_current_file = { enabled = true },
--       use_libuv_file_watcher = true,
--     },
--     window = {
--       position = "right",
--       width = 40,
--       mappings = {
--         ["l"] = "open",
--         ["h"] = "close_node",
--         ["<space>"] = "none",
--         ["/"] = "fuzzy_finder",
--         ["i"] = "filter_as_you_type",
--         ["<esc>"] = function(state)
--           local sources = require("neo-tree.sources")
--           local manager = require("neo-tree.sources.manager")
--           -- Clear filter text
--           if state.filter_text or state.filter then
--             local fsources = sources.get_focus_source()
--             -- Close filter window
--             sources.filesystem.commands.clear_filter(state)
--             -- Make sure we exit insert mode to enable navigation
--             vim.cmd("stopinsert")
--           end
--         end,
--         ["Y"] = {
--           function(state)
--             local node = state.tree:get_node()
--             local path = node:get_id()
--             vim.fn.setreg("+", path, "c")
--           end,
--           desc = "Copy Path to Clipboard",
--         },
--         ["O"] = {
--           function(state)
--             require("lazy.util").open(state.tree:get_node().path, { system = true })
--           end,
--           desc = "Open with System Application",
--         },
--         ["P"] = { "toggle_preview", config = { use_float = false } },
--       },
--     },
--     default_component_configs = {
--       indent = {
--         with_expanders = true,
--         expander_collapsed = "",
--         expander_expanded = "",
--         expander_highlight = "NeoTreeExpander",
--       },
--       git_status = {
--         symbols = {
--           unstaged = "󰄱",
--           staged = "󰱒",
--         },
--       },
--     },
--     -- This ensures the filter bar appears at the top of NeoTree
--     use_popups_for_input = false,
--     enable_normal_mode_for_inputs = true,
--   },
--   config = function(_, opts)
--     local function on_move(data)
--       Snacks.rename.on_rename_file(data.source, data.destination)
--     end
--     local events = require("neo-tree.events")
--     opts.event_handlers = opts.event_handlers or {}
--     vim.list_extend(opts.event_handlers, {
--       { event = events.FILE_MOVED, handler = on_move },
--       { event = events.FILE_RENAMED, handler = on_move },
--     })
--     require("neo-tree").setup(opts)
--     vim.api.nvim_create_autocmd("TermClose", {
--       pattern = "*lazygit",
--       callback = function()
--         if package.loaded["neo-tree.sources.git_status"] then
--           require("neo-tree.sources.git_status").refresh()
--         end
--       end,
--     })
--   end,
-- }
-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   cmd = "Neotree",
--   keys = {
--     {
--       "<leader>fe",
--       function()
--         require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
--       end,
--       desc = "Explorer NeoTree (Root Dir)",
--     },
--     {
--       "<leader>fE",
--       function()
--         require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
--       end,
--       desc = "Explorer NeoTree (cwd)",
--     },
--     { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
--     { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
--     {
--       "<leader>ge",
--       function()
--         require("neo-tree.command").execute({ source = "git_status", toggle = true })
--       end,
--       desc = "Git Explorer",
--     },
--     {
--       "<leader>be",
--       function()
--         require("neo-tree.command").execute({ source = "buffers", toggle = true })
--       end,
--       desc = "Buffer Explorer",
--     },
--   },
--   deactivate = function()
--     vim.cmd([[Neotree close]])
--   end,
--   init = function()
--     vim.api.nvim_create_autocmd("BufEnter", {
--       group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
--       desc = "Start Neo-tree with directory",
--       once = true,
--       callback = function()
--         if package.loaded["neo-tree"] then
--           return
--         else
--           local stats = vim.uv.fs_stat(vim.fn.argv(0))
--           if stats and stats.type == "directory" then
--             require("neo-tree")
--           end
--         end
--       end,
--     })
--   end,
--   opts = {
--     sources = { "filesystem", "buffers", "git_status" },
--     open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
--     filesystem = {
--       bind_to_cwd = false,
--       follow_current_file = { enabled = true },
--       use_libuv_file_watcher = true,
--     },
--     window = {
--       position = "right", -- Add this line to position NeoTree on the right
--       width = 40, -- Optional: you can adjust the width as needed
--       mappings = {
--         ["l"] = "open",
--         ["h"] = "close_node",
--         ["<space>"] = "none",
--         ["Y"] = {
--           function(state)
--             local node = state.tree:get_node()
--             local path = node:get_id()
--             vim.fn.setreg("+", path, "c")
--           end,
--           desc = "Copy Path to Clipboard",
--         },
--         ["O"] = {
--           function(state)
--             require("lazy.util").open(state.tree:get_node().path, { system = true })
--           end,
--           desc = "Open with System Application",
--         },
--         ["P"] = { "toggle_preview", config = { use_float = false } },
--       },
--     },
--     default_component_configs = {
--       indent = {
--         with_expanders = true,
--         expander_collapsed = "",
--         expander_expanded = "",
--         expander_highlight = "NeoTreeExpander",
--       },
--       git_status = {
--         symbols = {
--           unstaged = "󰄱",
--           staged = "󰱒",
--         },
--       },
--     },
--   },
--   config = function(_, opts)
--     local function on_move(data)
--       Snacks.rename.on_rename_file(data.source, data.destination)
--     end
--     local events = require("neo-tree.events")
--     opts.event_handlers = opts.event_handlers or {}
--     vim.list_extend(opts.event_handlers, {
--       { event = events.FILE_MOVED, handler = on_move },
--       { event = events.FILE_RENAMED, handler = on_move },
--     })
--     require("neo-tree").setup(opts)
--     vim.api.nvim_create_autocmd("TermClose", {
--       pattern = "*lazygit",
--       callback = function()
--         if package.loaded["neo-tree.sources.git_status"] then
--           require("neo-tree.sources.git_status").refresh()
--         end
--       end,
--     })
--   end,
-- }

-- GIT AND BUFFER VERSION
-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   cmd = "Neotree",
--   keys = {
--     {
--       "<leader>fe",
--       function()
--         require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
--       end,
--       desc = "Explorer NeoTree (Root Dir)",
--     },
--     {
--       "<leader>fE",
--       function()
--         require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
--       end,
--       desc = "Explorer NeoTree (cwd)",
--     },
--     { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
--     { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
--     {
--       "<leader>ge",
--       function()
--         require("neo-tree.command").execute({ source = "git_status", toggle = true })
--       end,
--       desc = "Git Explorer",
--     },
--     {
--       "<leader>be",
--       function()
--         require("neo-tree.command").execute({ source = "buffers", toggle = true })
--       end,
--       desc = "Buffer Explorer",
--     },
--   },
--   deactivate = function()
--     vim.cmd([[Neotree close]])
--   end,
--   init = function()
--     -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
--     -- because `cwd` is not set up properly.
--     vim.api.nvim_create_autocmd("BufEnter", {
--       group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
--       desc = "Start Neo-tree with directory",
--       once = true,
--       callback = function()
--         if package.loaded["neo-tree"] then
--           return
--         else
--           local stats = vim.uv.fs_stat(vim.fn.argv(0))
--           if stats and stats.type == "directory" then
--             require("neo-tree")
--           end
--         end
--       end,
--     })
--   end,
--   opts = {
--     sources = { "filesystem", "buffers", "git_status" },
--     open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
--     filesystem = {
--       bind_to_cwd = false,
--       follow_current_file = { enabled = true },
--       use_libuv_file_watcher = true,
--       filtered_items = {
--         visible = false,
--         hide_dotfiles = false,
--         hide_gitignored = false,
--       },
--     },
--     window = {
--       position = "right",
--       width = 40,
--       mappings = {
--         ["l"] = "open",
--         ["h"] = "close_node",
--         ["<space>"] = "none",
--         ["/"] = "fuzzy_finder",
--         ["f"] = "filter_on_submit",
--         ["<esc>"] = "clear_filter",
--         ["i"] = "filter_as_you_type",
--         ["Y"] = {
--           function(state)
--             local node = state.tree:get_node()
--             local path = node:get_id()
--             vim.fn.setreg("+", path, "c")
--           end,
--           desc = "Copy Path to Clipboard",
--         },
--         ["O"] = {
--           function(state)
--             require("lazy.util").open(state.tree:get_node().path, { system = true })
--           end,
--           desc = "Open with System Application",
--         },
--         ["P"] = { "toggle_preview", config = { use_float = false } },
--       },
--       hijack_netrw_behavior = "open_current",
--       use_popups_for_input = false,
--     },
--     default_component_configs = {
--       indent = {
--         with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
--         expander_collapsed = "",
--         expander_expanded = "",
--         expander_highlight = "NeoTreeExpander",
--       },
--       git_status = {
--         symbols = {
--           unstaged = "󰄱",
--           staged = "󰱒",
--         },
--       },
--       name = {
--         trailing_slash = true,
--         use_git_status_colors = true,
--         highlight = "NeoTreeFileName",
--       },
--       filter_text = {
--         enabled = true,
--       },
--     },
--     enable_git_status = true,
--     enable_diagnostics = true,
--     sort_case_insensitive = false,
--     use_default_mappings = true,
--     source_selector = {
--       winbar = true,
--       statusline = false,
--       show_scrolled_off_parent_node = false,
--     },
--   },
--   config = function(_, opts)
--     local function on_move(data)
--       Snacks.rename.on_rename_file(data.source, data.destination)
--     end
--     local events = require("neo-tree.events")
--     opts.event_handlers = opts.event_handlers or {}
--     vim.list_extend(opts.event_handlers, {
--       { event = events.FILE_MOVED, handler = on_move },
--       { event = events.FILE_RENAMED, handler = on_move },
--     })
--     require("neo-tree").setup(opts)
--     vim.api.nvim_create_autocmd("TermClose", {
--       pattern = "*lazygit",
--       callback = function()
--         if package.loaded["neo-tree.sources.git_status"] then
--           require("neo-tree.sources.git_status").refresh()
--         end
--       end,
--     })
--   end,
-- }

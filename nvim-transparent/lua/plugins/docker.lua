return {
  -- Docker LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Docker LSP configuration
        dockerls = {
          enabled = true,
          -- Additional settings for dockerls if needed
          settings = {
            docker = {
              -- Enable completion for Dockerfile
              completion = {
                showFiles = true,
              },
            },
          },
        },
        -- Docker Compose LSP
        docker_compose_language_service = {
          enabled = true,
          -- Additional settings if needed
        },
      },
    },
  },

  -- Ensure the necessary LSP servers are installed
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "dockerfile-language-server", -- Docker LSP
        "docker-compose-language-service", -- Docker Compose LSP
      })
    end,
  },

  -- Add Docker-specific snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Custom Docker snippets
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ls.add_snippets("dockerfile", {
        -- Basic Dockerfile template
        s("dockerfile", {
          t({"FROM ", ""}),
          i(1, "image:tag"),
          t({"", "", "WORKDIR /app", "", "COPY . .", "", "RUN "}),
          i(2, "command"),
          t({"", "", "EXPOSE "}),
          i(3, "port"),
          t({"", "", "CMD ["}),
          i(4, "\"command\", \"arg1\", \"arg2\""),
          t({"]", ""}),
        }),

        -- FROM snippet
        s("from", {
          t("FROM "),
          i(1, "image:tag"),
          t({"", ""}),
        }),

        -- WORKDIR snippet
        s("workdir", {
          t("WORKDIR "),
          i(1, "/app"),
          t({"", ""}),
        }),

        -- COPY snippet
        s("copy", {
          t("COPY "),
          i(1, "."),
          t(" "),
          i(2, "."),
          t({"", ""}),
        }),

        -- RUN snippet
        s("run", {
          t("RUN "),
          i(1, "command"),
          t({"", ""}),
        }),

        -- EXPOSE snippet
        s("expose", {
          t("EXPOSE "),
          i(1, "port"),
          t({"", ""}),
        }),

        -- CMD snippet
        s("cmd", {
          t("CMD [\""),
          i(1, "command"),
          t("\"]"),
          t({"", ""}),
        }),

        -- ENV snippet
        s("env", {
          t("ENV "),
          i(1, "KEY"),
          t("="),
          i(2, "value"),
          t({"", ""}),
        }),
      })

      -- Docker Compose snippets
      ls.add_snippets("yaml", {
        -- Basic docker-compose.yml template
        s("docker-compose", {
          t({"version: '", ""}),
          i(1, "3"),
          t({"'", "", "services:", "  "}),
          i(2, "service_name"),
          t({":", "    image: "}),
          i(3, "image:tag"),
          t({"", "    container_name: "}),
          i(4, "container_name"),
          t({"", "    ports:", "      - '"}),
          i(5, "host_port:container_port"),
          t({"'", "    volumes:", "      - "}),
          i(6, "./host_path:/container_path"),
          t({"", "    environment:", "      - "}),
          i(7, "KEY=value"),
          t({"", ""}),
        }),
      })
    end,
  },

  -- Treesitter configuration to ensure Docker syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "dockerfile",
          "yaml", -- For docker-compose.yml files
        })
      end
    end,
  },

  -- Docker file type detection
  {
    "LazyVim/LazyVim",
    opts = {
      -- Ensure Docker file detection
      autocmds = {
        docker_filetype = {
          {
            "BufRead,BufNewFile",
            "Dockerfile*,dockerfile*",
            "setfiletype dockerfile",
          },
          {
            "BufRead,BufNewFile",
            "docker-compose*.yml,docker-compose*.yaml",
            function()
              vim.bo.filetype = "yaml.docker-compose"
            end,
          },
        },
      },
    },
  },

  -- Optional: AI assistance for Docker using neoai if available
  {
    "Bryley/neoai.nvim",
    optional = true,
    opts = function(_, opts)
      opts.prompts = opts.prompts or {}
      -- Add Docker-specific prompts
      table.insert(opts.prompts, {
        name = "DockerfileCreate",
        prompt = "Create a Dockerfile for a %s application with the following requirements: %s",
        mapping = "<leader>aD",
      })
      table.insert(opts.prompts, {
        name = "DockerComposeCreate",
        prompt = "Create a docker-compose.yml file for a %s setup with the following services: %s",
        mapping = "<leader>aC",
      })
    end,
  },
}


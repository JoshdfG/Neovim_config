-- lua/plugins/lsp/arduino.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      arduino_language_server = {
        cmd = {
          "arduino-language-server",
          "-cli-config",
          vim.fn.expand("~/.arduino15/arduino-cli.yaml"),
          "-fqbn",
          "arduino:avr:uno",
          "-clangd",
          "clangd",
        },
      },
    },
  },
}

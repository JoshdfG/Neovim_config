# Neovim Configurations.

## What's Neovim

Neovim is a text editor that is based on Vim, but with a focus on improving usability and extensibility. It aims to be a modern and powerful alternative to Vim, with a more flexible plugin architecture and better support for graphical user interfaces (GUIs). [Read More](https://neovim.io/).

## How to use this Configuration

- You must have successfully installed Neovim
- You can also install a neovim setup e.g Lazyvim

After successfully installation check if you have the nvim folder in your config folder

```bash
cd ~/.config/nvim/
```

If it doesn't exist create a nvim directory

```bash
mkdir ~/.config/nvim
```

- Download the nvim folder from this repo and replace the content of your nvim folder with it.
- Go to your terminal and type the `nvim` command to open NEOVIM.

## What's next

- Press `Space c + m ` to open up Mason and install the following packages

## Packages

- `black`
- `clangd`
- `codelldb`
- `debugpy`
- `delve`
- `docker-compose-language-server`
- `dockerfile-language-server`
- `efm`
- `emmet-ls`
- `eslint-lsp`
- `eslint_d`
- `gofumpt`
- `goimports`
- `golangci-lint`
- `gopls`
- `hadolint`
- `html-lsp`
- `isort`
- `js-debug-adapter`
- `lua-language-server`
- `markdown-toc`
- `markdownlint`
- `markdownlint-cli2`
- `marksman`
- `pgformatter`
- `postgrestools`
- `prettier`
- `prisma-language-server`
- `pylint`
- `pyright`
- `ruff`
- `rust-analyzer`
- `shellcheck`
- `shfmt`
- `solhint`
- `solidity-ls`
- `sql-formatter`
- `sqlfluff`
- `stylua`
- `tailwindcss-language-server`
- `typescript-language-server`
- `vscode-solidity-server`
- `vtsls`

For solidity compilers kindly install the language server globally `npm install -g @nomicfoundation/solidity-language-server`

The other 2 folders `alacritty` and `tmux` are just terminals configurations you can make use of them if you use the same terminal.

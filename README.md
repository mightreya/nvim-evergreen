# Neovim Evergreen

A modern, feature-rich, and efficient Neovim configuration for developers, with LSP, Treesitter, autocompletion, and more. Enhance your coding experience across various languages and platforms.

## Prerequisites

- Neovim (v0.5.0 or newer)
- Git
- Node.js (for some LSP servers)

## Installation

1. Backup your existing Neovim configuration if necessary:

```sh
mv ~/.config/nvim ~/.config/nvim.backup
```

2. Clone this repository into your Neovim config directory:

```sh
git clone https://github.com/yourusername/neovim-config.git ~/.config/nvim
```

3. Install the required Node.js global packages for LSP servers:

```sh
npm install -g pyright sourcekit omnisharp gopls typescript typescript-language-server vscode-html-languageserver-bin vscode-css-languageserver-bin tailwindcss-language-server vscode-json-languageserver
```

4. Install isort, black, and other formatting tools for Python:
```sh
pip install isort black
```

5. Install eslint for JavaScript formatting:
```sh
npm install -g eslint
```

6. Open Neovim and run the following command to install the plugins:
```vim
:PackerInstall
```

7. Restart Neovim and enjoy your new configuration!

## Features

- LSP support for various languages (Python, Swift, C#, Golang, TypeScript, HTML, JS, React, LitElement, and more)
- Autocompletion using nvim-cmp
- Code snippets with LuaSnip
- Auto-formatting with Neoformat
- Surround management with vim-surround
- Commenting with nvim-comment
- Indentation guides with indent-blankline
- File and content search with Telescope and fzf integration
- Git integration using Gitsigns
- Buffer management with nvim-bufferline
- Colorizer for hex codes, RGB, etc.
- Syntax highlighting using Treesitter
- Auto-closing HTML/XML tags with nvim-ts-autotag
- Linters and real-time error checking with ALE
- Symbols outline for file overview
- EditorConfig support
- Vimwiki for note-taking
- LSP function signature help
- Gruvbox color scheme

### Nerd Font (optional)

This configuration works best with a Nerd Font. We recommend using the 'FiraCode Nerd Font'. You can download it from the [Nerd Fonts repository](https://github.com/ryanoasis/nerd-fonts).

1. Download the font from the [latest release](https://github.com/ryanoasis/nerd-fonts/releases) or by following the instructions in the repository.
2. Install the font on your system by following the instructions for your specific operating system.
3. Set your terminal emulator to use the installed Nerd Font.

## Customization

Feel free to customize the configuration according to your preferences by editing the `init.lua` file in the `~/.config/nvim/` directory.

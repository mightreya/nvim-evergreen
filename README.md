# Neovim Evergreen

This repository holds a modern, feature-rich, and efficient Neovim configuration for developers. With powerful tools such as LSP, Treesitter, autocompletion, and more, it enhances your coding experience across various languages and platforms.

## Prerequisites

Ensure you have the following installed on your system:

- Neovim (v0.5.0 or newer)
- Git
- Node.js (required for some LSP servers)

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

5. Install eslint and eslint_d for JavaScript formatting:

```sh
npm install -g eslint eslint_d
```

6. Open Neovim and run the following command to install the plugins:

```vim
:PackerInstall
```

7. Restart Neovim and enjoy your new configuration!

## Features

Our Neovim configuration comes packed with a range of features to boost your productivity:

- Language Server Protocol (LSP) support for various languages including Python, Swift, C#, Golang, TypeScript, HTML, JS, React, LitElement, and more.
- Autocompletion powered by nvim-cmp.
- Code snippets provided by LuaSnip.
- Auto-formatting via Neoformat.
- Efficient surround management with vim-surround.
- Easy code commenting using nvim-comment.
- Indentation guides offered by indent-blankline.
- File and content search capabilities through Telescope and fzf integration.
- Git integration using Gitsigns.
- Buffer management with nvim-bufferline.
- Hex code, RGB, and other color codes visualized by nvim-colorizer.lua.
- Syntax highlighting using Treesitter.
- Auto-closing HTML/XML tags with nvim-ts-autotag.
- Linters and real-time error checking via ALE.
- File overview through symbols-outline.nvim.
- Support for EditorConfig.
- Note-taking with Vimwiki.
- LSP function signature help.
- Stunning Gruvbox color scheme.
- GitHub Copilot integration for AI-powered code suggestions.

## Nerd Font (optional)

For an optimized experience, we recommend using a Nerd Font, such as 'FiraCode Nerd Font'. Download it from the [Nerd Fonts repository](https://github.com/ryanoasis/nerd-fonts).

## Customization

Feel free to edit the `init.lua` file in the `~/.config/nvim/` directory to adjust the configuration to your personal preferences.

Here's a shortened version of the "How it Works" section:

## How it Works

Your Neovim configuration is governed by the `init.lua` file, packed with plugins that enhance your coding environment. These include features like LSPs, autocompletion, code snippets, auto-formatting, Git integration, syntax highlighting, linting and error checking, and more, even incorporating GitHub Copilot, your AI pair programmer.

The `init.lua` file in the repository provides detailed configuration settings and mappings for all these features. For an in-depth understanding, please refer to it. Enjoy your enriched coding experience!

## About the Author

[Konstantin Alexandrov](https://mightreya.com) is the founder of Mightreya AB. His current work revolves around Taûg, an AI-powered technology that seeks to transform personal nutrition tracking using depth map technologies. Anticipated for widespread release soon, Taûg promises a new era of simplicity and precision in monitoring calorie and macronutrient intake.

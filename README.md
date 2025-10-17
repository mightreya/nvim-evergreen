# Neovim Evergreen

Modern Neovim configuration with LSP, AI assistants, and efficient workflows.

## Prerequisites

- Neovim 0.10+
- Git
- Node.js (for LSP servers)
- [Claude CLI](https://claude.com/cli)
- [Gemini CLI](https://github.com/marcinjahn/gemini-cli) (optional)

## Installation

```sh
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this repo
git clone https://github.com/mightreya/nvim-evergreen.git ~/.config/nvim

# Open Neovim - plugins auto-install via lazy.nvim
nvim
```

## Features

### AI Integration
- **Claude Code** - Native terminal integration with context-aware coding assistance
- **Gemini CLI** - Alternative AI assistant support

### Core
- LSP via Mason and nvim-lspconfig
- Autocompletion with nvim-cmp
- Treesitter syntax highlighting
- Telescope fuzzy finder
- Git integration (gitsigns, fugitive)

### Editor
- Auto-pairs and surround
- Comment toggling
- Indent guides
- Colorizer for color codes
- Multiple cursors
- WhichKey for keybinding help

### Language Support
- Python, JavaScript/TypeScript, Go, Rust, Lua
- HTML/CSS/Tailwind
- SuperCollider

## Key Bindings

### Claude Code
- `<leader>ac` - Toggle Claude terminal
- `<leader>af` - Focus Claude terminal
- `<leader>ab` - Add current buffer to Claude
- `<leader>as` - Send visual selection to Claude
- `<leader>aa` - Accept diff
- `<leader>ad` - Deny diff

### General
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Browse buffers
- `<leader>gg` - Toggle Gemini

## Configuration Structure

```
~/.config/nvim/
├── init.lua              # Entry point
└── lua/
    └── plugins/
        ├── claude-code.lua
        ├── lsp.lua
        ├── completion.lua
        ├── treesitter.lua
        ├── telescope.lua
        ├── git.lua
        ├── editor.lua
        ├── ui.lua
        └── ...
```

## Customization

Edit files in `lua/plugins/` to customize plugin configurations.

## Nerd Fonts

For optimal icon display, use a Nerd Font like [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts).

## Author

[Konstantin Alexandrov](https://mightreya.com) - Founder of Mightreya AB

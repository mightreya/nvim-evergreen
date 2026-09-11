# Neovim Evergreen

Modern Neovim configuration with LSP, AI assistants, and efficient workflows.

## Prerequisites

- Neovim 0.12+
- Git
- Node.js (for LSP servers)
- [uv](https://docs.astral.sh/uv/) and Ruff for Python tooling
- tree-sitter-cli 0.26.1+ and a C compiler (for Tree-sitter parsers)
- [Claude CLI](https://claude.com/cli)
- [Gemini CLI](https://github.com/marcinjahn/gemini-cli) (optional)
- [Codex CLI](https://developers.openai.com/codex/cli/) and `jq` (for Codex diff previews)

## Installation

```sh
[ ! -d ~/.config/nvim ] || mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s); git clone https://github.com/mightreya/nvim-evergreen.git ~/.config/nvim && nvim
```

## Features

### AI Integration
- **Claude Code** - Native terminal integration with context-aware coding assistance
- **Gemini CLI** - Alternative AI assistant support
- **Codex** - Persistent native terminal, file/selection context, and code-preview diffs

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

The leader is comma. Claude Code is the primary assistant under `,a`; Codex uses
the matching `,c` namespace where the plugins support the same action.

### AI assistants

| Action | Claude Code | Codex |
| --- | --- | --- |
| Toggle terminal | `,ac` | `,cc` |
| Focus or hide | `,af` | `,cf` |
| Resume a session | `,aR` | `,cR` |
| Continue latest session | `,aC` | `,cC` |
| Add current buffer | `,ab` | `,cb` |
| Add visual selection | `,as` | `,cs` |
| Ask with context | — | `,ca` |
| Edit visual selection | — | `,ce` |
| Accept diff | `,aa` | In Codex terminal |
| Deny diff | `,ad` | In Codex terminal |
| Add directory tree | `,at` | `,ct` |
| Review changes | `,ar` | `,cr` |
| Select model | `,am` | In Codex terminal |
| Stop process | — | `,cx` |
| Show status | `,aS` | `,cS` |
| Close edit previews | — | `,cq` |

For Codex, run `codex login`, restart Neovim, and press `,cc`. Optional native
edit previews can be enabled per machine with `:CodePreviewInstallCodexCliHooks`;
restart Codex after installing the hooks. Neovim starts Codex with the sandboxed
`--approve-for-me` mode. Esc remains available to Codex; Ctrl-/ hides its panel.

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

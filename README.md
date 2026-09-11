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

### Codex

The leader is comma. Codex uses `,c` to preserve the existing `,o` outline and
`,of` open-directory shortcuts, alongside Claude's `,a` bindings.

- `,cc` - Toggle the right-hand 50% Codex terminal
- `,cf` - Focus Codex, or hide it when already focused
- `,cb` - Add the current file reference without submitting
- `,cs` (visual) - Add the exact selection, then type your instruction in Codex
- `,ca` (normal/visual) - Compose a question with file/selection context
- `,ce` (visual) - Compose an edit request
- `,cR` / `,cC` - Resume a session / continue the latest session
- `,ct` - Add selected explorer paths
- `,cr` - Start a Codex code review (stop the current session first)
- `,cx` - Stop the Codex process
- `,cS` - Show Codex status
- `,cq` - Close preview windows after rejecting an edit

Inside the terminal, use Alt-j or Ctrl-\\ followed by Ctrl-n to enter Normal
mode, then ordinary Ctrl-w navigation. Esc is passed through to Codex.
Ctrl-/ (also Ctrl-_) hides the panel without stopping the session.

Authenticate with `codex login`; over headless SSH use `codex login --device-auth`.
Run `:checkhealth codex` and `:CodePreviewStatus` to diagnose the integration.

#### Diff previews

[code-preview.nvim](https://github.com/Cannon07/code-preview.nvim) opens native
side-by-side previews for supported Codex edits. **Accept or reject in the Codex
terminal.** The plugin has no Lua accept/reject API. Acceptance closes the preview;
after rejection, use `,cq` if it remains open. Apply-patch edits and common shell
writes are previewed, but the hook is not a gate covering every possible
filesystem change.

Install hooks with `:CodePreviewInstallCodexCliHooks` in a project's root, then
restart Codex. This merges entries into `.codex/hooks.json`. For all projects,
run the command with Neovim's working directory set to your home directory;
it then writes `~/.codex/hooks.json`. Hook commands reference this machine's
plugin installation, so install them separately on each machine. Approve the
hook trust prompt if Codex presents one. Only Codex hooks are needed; keep the
existing Claude integration's own diff handling.

Neovim-launched Codex uses `--approve-for-me`. It can edit the workspace and
run routine commands without stopping, while a separate reviewer handles eligible
requests to cross the sandbox boundary. The reviewer may reject a request and
Codex may still need your input. This does not enable full access. Diff previews
remain useful for inspection, but they are not an approval gate in this mode.
Your ordinary CLI configuration is unchanged. Save buffers before asking Codex
to edit them; the existing `checktime` autocmd reloads saved buffers on focus or
buffer changes.

#### Set up Codex on another machine

1. Install Neovim **0.12+**, `jq`, and the Codex CLI. On macOS:

   ```sh
   brew install neovim jq tree-sitter-cli
   brew install --cask codex
   uv tool install ruff
   ```

   On Linux, install Neovim 0.12+, `jq`, tree-sitter-cli 0.26.1+, a C compiler,
   uv, and Ruff using your system's package manager or upstream releases.
   Install a native Codex release, or use `npm install -g @openai/codex`. npm
   distributes the native binary; Node is only needed for that
   installation/launcher method.

2. Clone this configuration, open Neovim, and run `:Lazy restore` to install
   the versions pinned in `lazy-lock.json`. Restart Neovim.
3. Run `codex login` in a shell, or `codex login --device-auth` over SSH.
4. Install global preview hooks from Neovim:

   ```vim
   :cd ~
   :CodePreviewInstallCodexCliHooks
   :cd -
   ```

   With a custom `CODEX_HOME`, use its parent instead of `~` only if the
   directory is named `.codex`; otherwise use project-local hook installation.
   The installer merges existing hooks. These generated absolute paths and
   authentication files are local machine state; do not commit them.
5. Run `:checkhealth codex` and `:CodePreviewStatus`, then press `,cc`.
   If hooks were installed while Codex was running, stop it with `,cx` first.
   Approve Codex's hook trust prompt when presented.

#### Verify the integration

After installing the plugins, run this from the repository root:

```sh
nvim --headless -i NONE '+luafile tests/config.lua'
nvim --headless -u NONE -i NONE -l tests/codex.lua
nvim --headless -i NONE '+luafile tests/treesitter.lua'
```

The configuration test verifies startup, plugin load behavior, keymaps, automatic
Codex review mode, and formatter scope. The Codex smoke test uses temporary files
and a local echo process, so it requires no authentication or model calls. It
checks terminal startup/hide/reopen, project root detection, width/styling,
terminal and selection keys, hook installation,
edit/new-file previews, and cleanup. It does not exercise model generation or
the CLI's interactive approval/trust prompts. For a live check, open a scratch
Git repository with `,cc`, request a small edit, and verify both acceptance
and rejection through the Codex terminal. The Tree-sitter test parses a sample
for every configured language and reproduces the Markdown fenced-code path that
previously raised a scheduled `LanguageTree` callback error.

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

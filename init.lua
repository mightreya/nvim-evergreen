-- 1. Packer setup
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost init.lua PackerCompile'

require('packer').startup(function()
  use 'gruvbox-community/gruvbox' -- Gruvbox colour theme
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig' -- LSP support
  use 'hrsh7th/nvim-cmp' -- Autocompletion
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippet engine
  use 'sbdchd/neoformat' -- Auto-formatting
  use 'tpope/vim-surround' -- Surroundings
  use 'terrortylor/nvim-comment' -- Comment in / out
  use 'lukas-reineke/indent-blankline.nvim' -- Indentation guides
  use 'kyazdani42/nvim-web-devicons' -- Icons for plugins
  use 'nvim-lua/plenary.nvim' -- A Lua library containing utility functions and classes, used as a dependency by other plugins
  use 'nvim-telescope/telescope.nvim' -- Quick search by file name or content
  use 'nvim-telescope/telescope-fzf-native.nvim' -- FZF integration for Telescope
  use 'lewis6991/gitsigns.nvim' -- Git support
  use 'norcalli/nvim-colorizer.lua' -- Colorize hex codes, RGB, etc.
  use 'nvim-treesitter/nvim-treesitter' -- Tree-sitter for syntax highlighting
  use 'windwp/nvim-ts-autotag' -- Auto close HTML/XML tags
  use 'lervag/vimtex' -- LaTeX support
  use 'simrat39/symbols-outline.nvim' -- File overview (methods, classes, etc.)
  use 'editorconfig/editorconfig-vim' -- EditorConfig support
  use 'vimwiki/vimwiki' -- Notes
  use 'ray-x/lsp_signature.nvim' -- Function signature help
  use 'github/copilot.vim' -- GitHub Copilot integration
  use 'dense-analysis/ale' -- Asynchronous Lint Engine (ALE) for linting and fixing code in real-time
end)

-- General settings
vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true
vim.opt.number = true -- Line numbers
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Default indent 4
vim.opt.tabstop = 4 -- Default tab width 4
vim.opt.smartindent = true -- Auto-indent new lines
vim.opt.hlsearch = true -- Highlight search results
vim.cmd('autocmd InsertLeave * :set nopaste') -- Disable paste mode on insert leave
vim.cmd('autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o') -- Remove comments continuation
vim.cmd('autocmd BufRead,BufNewFile * setlocal textwidth=0') -- Disable automatic line break

-- LSP settings
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
end

-- Configure LSP servers
local servers = {
  'pyright', 'sourcekit', 'omnisharp', 'gopls', 'tsserver', 'html', 'cssls', 'tailwindcss', 'jsonls'
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Enable stubs for Python
nvim_lsp['pyright'].setup {
  settings = {
    python = {
      analysis = {
        extraPaths = { vim.fn.expand("~/.stubs") },
      },
    },
  },
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
}

-- Enable TypeScript LSP for JavaScript files
nvim_lsp['tsserver'].setup {
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    on_attach(client, bufnr)
  end
}

-- nvim-cmp (autocompletion)
local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- LuaSnip (snippets)
local ls = require'luasnip'
ls.config.set_config {
  history = true,
  updateevents = 'TextChanged,TextChangedI',
}
require('luasnip/loaders/from_vscode').load()

-- neoformat (auto-formatting)
vim.cmd('autocmd BufWritePre * Neoformat')

vim.g.neoformat_enabled_python = {'isort', 'black'}
vim.g.neoformat_enabled_javascript = {'eslint'}

-- vim-surround
vim.g.surround_no_insert_mappings = 1

-- nvim-comment
require('nvim_comment').setup()

-- indent-blankline
require('indent_blankline').setup {
  show_current_context = true,
  filetype_exclude = { 'help', 'terminal', 'dashboard', 'packer', 'lspinfo', 'TelescopePrompt', 'TelescopeResults', 'startify', 'NvimTree', 'vista', 'qf', 'vimwiki' },
  buftype_exclude = { 'terminal', 'nofile' },
  space_char_blankline = ' ',
  show_trailing_blankline_indent = false,
  show_first_indent_level = false,
}

-- Telescope
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "node_modules" },
  },
  extensions = {
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
  },
}
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<C-p>', function()
  builtin.find_files({
    layout_strategy = 'bottom_pane',
    layout_config = {
      width = 1.0,
    },
    selection_caret = "> ",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    scroll_strategy = "cycle",
    color_devicons = true,
    set_env = { ['COLORTERM'] = 'truecolor' },
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
 
  })
end, { noremap = true })

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Gitsigns
require('gitsigns').setup()

-- Buffers
vim.api.nvim_set_keymap('n', 'gp', ':bp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gn', ':bn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gl', ':ls<CR>:b<Space>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gd', ':bp<bar>bd#<CR>', { noremap = true, silent = true })


-- Status line
vim.cmd([[
  set laststatus=2
  set statusline=
  set statusline+=%-10.3n
  set statusline+=%f
  set statusline+=%h%m%r%w
  set statusline+=\ [%{strlen(&ft)?&ft:'none'}]
  set statusline+=%=
  set statusline+=0x%-8B
  set statusline+=%-14(%l,%c%V%)
  set statusline+=%<%P
]])
vim.opt.fillchars = { stl = ' ', stlnc = ' ' }

-- Disable search highlight on pressing space
vim.api.nvim_set_keymap('n', '<Space>', ':noh<CR>', { noremap = true, silent = true })

-- Colorizer
require('colorizer').setup()

-- Colour scheme
vim.o.background = 'dark' -- or 'light' for the light version
vim.cmd('colorscheme gruvbox')

-- Nvim-treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "bash", "c", "cpp", "c_sharp", "css", "go", "html", "javascript",
    "json", "lua", "python", "rust", "swift", "typescript", "yaml"
  },
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}

-- Python linters
vim.g.ale_linters = {
  python = {'flake8'},
}
vim.g.ale_fixers = {
  python = {'autopep8'},
}
vim.g.ale_fix_on_save = 1
vim.g.ale_lint_on_text_changed = 'never'
vim.g.ale_lint_on_insert_leave = 0

-- Symbols-outline
vim.api.nvim_set_keymap('n', '<Leader>o', ':SymbolsOutline<CR>', { noremap = true, silent = true })

-- LSP signature
require('lsp_signature').setup()

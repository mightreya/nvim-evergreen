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
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'jose-elias-alvarez/null-ls.nvim' -- Null-ls for extra LSP features
    use 'ray-x/lsp_signature.nvim' -- Function signature help
    use 'hrsh7th/nvim-cmp' -- Autocompletion
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
    use 'nvim-telescope/telescope-project.nvim' -- Project extension for Telescope
    use 'nvim-telescope/telescope-ui-select.nvim' -- UI Select extension for Telescope
    use 'lewis6991/gitsigns.nvim' -- Git support
    use 'norcalli/nvim-colorizer.lua' -- Colorize hex codes, RGB, etc.
    use 'nvim-treesitter/nvim-treesitter' -- Tree-sitter for syntax highlighting
    use 'windwp/nvim-ts-autotag' -- Auto close HTML/XML tags
    use 'lervag/vimtex' -- LaTeX support
    use 'simrat39/symbols-outline.nvim' -- File overview (methods, classes, etc.)
    use 'editorconfig/editorconfig-vim' -- EditorConfig support
    use 'lervag/wiki.vim' -- Notes
    use 'lervag/wiki-ft.vim' -- Wiki syntax highlighting
    use 'dense-analysis/ale' -- Asynchronous Lint Engine (ALE) for linting and fixing code in real-time
    use 'zbirenbaum/copilot.lua'  -- GitHub Copilot integration
    use 'zbirenbaum/copilot-cmp' -- Copilot integration with nvim-cmp
    use 'tidalcycles/vim-tidal' -- TidalCycles plugin
    use 'davidgranstrom/scnvim' -- SuperCollider frontend
    
    -- Required plugins for Avante
    use 'stevearc/dressing.nvim'
    use 'MunifTanjim/nui.nvim'
    use 'MeanderingProgrammer/render-markdown.nvim'
    
    -- Optional dependencies (already included above: nvim-cmp, nvim-web-devicons, copilot.lua)
    use 'HakonHarnes/img-clip.nvim'
    
    -- Avante.nvim with build process
    use {
        'yetone/avante.nvim',
        branch = 'main',
        run = 'make',
    }
end)

-- General settings
vim.g.mapleader = ","
vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true
vim.opt.number = true -- Line numbers
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Default indent 4
vim.opt.tabstop = 4 -- Default tab width 4
vim.opt.smartindent = true -- Auto-indent new lines
vim.opt.hlsearch = true -- Highlight search results

vim.o.showcmd = false

vim.cmd('autocmd InsertLeave * :set nopaste') -- Disable paste mode on insert leave
vim.cmd('autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o') -- Remove comments continuation
vim.cmd('autocmd BufRead,BufNewFile * setlocal textwidth=0') -- Disable automatic line break

-- Set 2 spaces indentation for specific file types
vim.cmd([[
augroup IndentationOverrides
autocmd!
autocmd FileType javascript,javascriptreact,typescript,typescriptreact,rell,json setlocal shiftwidth=2 tabstop=2
augroup END
]])

-- Sync buffers with the saved files on disk
vim.cmd('autocmd FocusGained,BufEnter * :checktime')

-- LSP settings
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ld', '<Cmd>lua vim.diagnostic.open_float()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ai', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lf', '<Cmd>lua vim.lsp.buf.format()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

    -- Add a custom keybinding to show the signature help window on demand
    vim.api.nvim_set_keymap('n', '<leader>sh', '<cmd>lua require("lsp_signature").signature()<CR>', { noremap = true, silent = true })
end

-- Configure LSP servers
local servers = {
    'pyright', 'sourcekit', 'omnisharp', 'gopls', 'ts_ls', 'html', 'cssls', 'tailwindcss', 'jsonls'
}

-- Null-ls setup
local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.code_actions.gitsigns,
    },
    on_attach = function(client)
        if client.server_capabilities.document_formatting then
            vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
        end
    end,
})

for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        }
    }
end

local util = require 'lspconfig.util'

-- Configure Poetry and stubs for Python
require('lspconfig').pyright.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  before_init = function(_, config)
    local py_root = util.find_git_ancestor(config.root_dir) or config.root_dir
    -- Try to find and use poetry environment
    local poetry_env = vim.fn.trim(vim.fn.system('cd "' .. py_root .. '" && poetry env info -p 2>/dev/null'))
    if vim.v.shell_error == 0 and vim.fn.isdirectory(poetry_env) == 1 then
      config.settings.python.pythonPath = poetry_env .. '/bin/python'
    else
      -- Fallback: Check for .venv in project root
      local venv = py_root .. '/.venv'
      if vim.fn.isdirectory(venv) == 1 then
        config.settings.python.pythonPath = venv .. '/bin/python'
      end
    end
  end,
  settings = {
    python = {
      analysis = {
        extraPaths = { vim.fn.expand("~/.stubs") },
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
}

-- GitHub Copilot
require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})

-- Copilot completion
require("copilot_cmp").setup()

-- LuaSnip (snippets)
local ls = require'luasnip'
local s = ls.s
local t = ls.t

ls.config.set_config {
    history = true,
    updateevents = 'TextChanged,TextChangedI',
}

ls.add_snippets("python", {
    s("br", {
        t({"import ipdb; ipdb.set_trace()"}),
    })
}, {
    key = "python",
})

-- nvim-cmp (autocompletion)
local cmp = require'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            elseif require('luasnip').expand_or_jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
            else
                fallback()
            end
        end,
    },
    sources = {
        { name = 'luasnip', option = { use_show_condition = false } },
        { name = "copilot" },
        { name = 'nvim_lsp' },
    },
}

-- vim-surround
vim.g.surround_no_insert_mappings = 1

-- nvim-comment
require('nvim_comment').setup()

require("ibl").setup {
    indent = {
        char = "│",
    },
    exclude = {
        filetypes = { "help", "terminal", "dashboard", "packer", "lspinfo", "TelescopePrompt", "TelescopeResults", "startify", "NvimTree", "vista", "qf", "vimwiki" },
        buftypes = { "terminal", "nofile" }
    },
    scope = {
        enabled = true
    }
}

-- Telescope
require('telescope').setup {
    defaults = {
        path_display = {"absolute"},
        file_ignore_patterns = { "node_modules" },
        file_sorter = require('telescope.sorters').get_fuzzy_file
    },
    extensions = {
        fzf = {
            override_generic_sorter = false,
            override_file_sorter = false,
        },
        project = {
            base_dirs = {
                '~/Development',
                '~/wiki',
            },
        },
        ['ui-select'] = {
            require('telescope.themes').get_dropdown {
                -- add opts here
            }
        }
    },
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('project')
require('telescope').load_extension('ui-select')

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
vim.keymap.set('n', '<leader>fp', function()
  require('telescope').extensions.project.project{}
end, { noremap = true, silent = true })

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
        "json", "lua", "python", "rust", "swift", "typescript", "yaml", "glsl"
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
    python = {'flake8', 'pylint'},
}
vim.g.ale_fixers = {
    python = {'isort', 'autopep8', 'pycln', 'ruff'},
}
vim.g.ale_fix_on_save = 1
vim.g.ale_lint_on_text_changed = 'never'
vim.g.ale_lint_on_insert_leave = 0
vim.g.ale_completion_autoimport = 1


-- Reducing linter errors
vim.g.ale_python_flake8_options = '--max-line-length=120'
vim.g.ale_python_pylint_options = '--disable=C0111,C0301,W0603 --max-line-length=120'

-- Mappings
vim.api.nvim_set_keymap('n', '<leader>of', ':!open %:h<CR>', { noremap = true, silent = true })

-- Make it global
_G.new_file = function(filetype, prefix, extension)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local filename  = string.format("%s_%s%s", prefix, timestamp, extension)
  vim.cmd("enew")
  vim.cmd("setfiletype " .. filetype)
  vim.cmd("file " .. filename)
end

-- Then call _G.new_file in your keymaps
vim.api.nvim_set_keymap('n', '<leader>np',
  ":lua _G.new_file('python', 'python_file', '.py')<CR>",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap('n', '<leader>ns',
  ":lua _G.new_file('swift', 'swift_file', '.swift')<CR>",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap('n', '<leader>nm',
  ":lua _G.new_file('markdown', 'markdown_file', '.md')<CR>",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap('n', '<leader>nc',
  ":lua _G.new_file('supercollider', 'supercollider_file', '.scd')<CR>",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap('n', '<leader>jf', ':Neoformat json<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pf', ':%!python3 -c "import sys, ast, pprint; pprint.pprint(ast.literal_eval(sys.stdin.read()))"<CR>', { noremap = true, silent = true })

-- Symbols-outline
vim.api.nvim_set_keymap('n', '<Leader>o', ':SymbolsOutline<CR>', { noremap = true, silent = true })

-- LSP signature
require('lsp_signature').setup({
    bind = false, -- Disable automatic binding
})

-- Neoformat
-- vim.cmd('autocmd BufWritePre * Neoformat')

_G.try_format = function()
    local succeeded, result = pcall(vim.cmd, 'Neoformat')
    if not succeeded then
        print('Formatter not defined for this filetype, saving without formatting.')
    end
end

vim.cmd('autocmd BufWritePre * lua _G.try_format()')

vim.cmd([[
  augroup ShaderHighlighting
    autocmd!
    autocmd BufRead,BufNewFile *.frag,*.vert,*.glsl set filetype=glsl
  augroup END
]])

vim.g.neoformat_javascript_prettier = {
    exe = "./node_modules/.bin/prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true
}
vim.g.neoformat_typescript_prettier = {
    exe = "./node_modules/.bin/prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true
}

vim.g.neoformat_json_prettier = {
  exe = '/opt/homebrew/bin/prettier',
  args = {'.'},
  stdin = true
}

vim.g.neoformat_json_jq = {
  exe = '/opt/homebrew/bin/jq',
  args = {'.'},
  stdin = true
}

vim.g.neoformat_enabled_python = {'isort', 'black', 'autopep8'}
vim.g.neoformat_autopep8_args = {'--max-line-length', '120'}
vim.g.neoformat_black_args = {'--line-length', '120'}

vim.g.neoformat_enabled_javascript = {'eslint_d'}
vim.g.neoformat_enabled_javascriptreact = {'eslint_d'}

vim.g.neoformat_enabled_typescript = {'eslint_d'}
vim.g.neoformat_enabled_typescriptreact = {'eslint_d'}

vim.g.neoformat_enabled_json = {'prettier', 'jq'}

vim.api.nvim_set_keymap('v', '=', ':Neoformat<CR>', {noremap = true})

-- Tidal
-- vim.g.tidal_boot = "~/.config/vim-tidal/boot.tidal"
vim.g.tidal_sc_enable = 1
vim.g.tidal_sc_boot = "~/.config/vim-tidal/startup.scd"


-- SCNvim
local scnvim = require 'scnvim'
local map = scnvim.map
local map_expr = scnvim.map_expr

scnvim.setup({
  keymaps = {
    ['<M-e>'] = map('editor.send_line', {'i', 'n'}),
    ['<C-e>'] = {
      map('editor.send_block', {'i', 'n'}),
      map('editor.send_selection', 'x'),
    },
    ['<CR>'] = map('postwin.toggle'),
    ['<M-CR>'] = map('postwin.toggle', 'i'),
    ['<M-L>'] = map('postwin.clear', {'n', 'i'}),
    ['<C-k>'] = map('signature.show', {'n', 'i'}),
    ['<F12>'] = map('sclang.hard_stop', {'n', 'x', 'i'}),
    ['<leader>st'] = map('sclang.start'),
    ['<leader>sk'] = map('sclang.recompile'),
    ['<F1>'] = map_expr('s.boot'),
    ['<F2>'] = map_expr('s.meter'),
  },
  editor = {
    highlight = {
      color = 'IncSearch',
    },
  },
  postwin = {
    float = {
      enabled = true,
    },
  },
})

-- wiki.vim
vim.g.wiki_root = '~/wiki'
vim.g.wiki_filetypes = { 'md' }

-- Initialize Avante
require("avante").setup({
  provider = "gemini",
  gemini = {
    endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
    model = "gemini-2.0-flash-thinking-exp",
    temperature = 0.7,
    max_tokens = 4096,
  },
  behaviour = {
    auto_suggestions = false,
  },
})

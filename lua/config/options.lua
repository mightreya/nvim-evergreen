-- General settings
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- UI settings
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.showcmd = false
vim.opt.laststatus = 2
vim.opt.fillchars = { stl = ' ', stlnc = ' ' }

-- Clipboard
vim.opt.clipboard = 'unnamedplus'

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- Search
vim.opt.hlsearch = true

-- Split behavior
vim.opt.splitright = true

-- Color scheme
vim.o.background = 'dark'

-- Status line
vim.cmd([[
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

-- Plugin-specific settings
vim.g.surround_no_insert_mappings = 1
vim.g.wiki_root = '~/wiki'
vim.g.wiki_filetypes = { 'md' }

-- Tidal
vim.g.tidal_sc_enable = 1
vim.g.tidal_sc_boot = "~/.config/vim-tidal/startup.scd"

-- Neoformat configuration (for non-Python files)
vim.g.neoformat_javascript_prettier = {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true
}
vim.g.neoformat_typescript_prettier = {
    exe = "prettier", 
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true
}

vim.g.neoformat_json_prettier = {
  exe = 'prettier',
  args = {'.'},
  stdin = true
}

vim.g.neoformat_json_jq = {
  exe = 'jq',
  args = {'.'},
  stdin = true
}

vim.g.neoformat_enabled_javascript = {'eslint_d', 'prettier'}
vim.g.neoformat_enabled_javascriptreact = {'eslint_d', 'prettier'}
vim.g.neoformat_enabled_typescript = {'eslint_d', 'prettier'}
vim.g.neoformat_enabled_typescriptreact = {'eslint_d', 'prettier'}
vim.g.neoformat_enabled_json = {'prettier', 'jq'}
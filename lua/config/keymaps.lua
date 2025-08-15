local map = vim.keymap.set

-- Disable search highlight on pressing space
map('n', '<Space>', ':noh<CR>', { noremap = true, silent = true })

-- Buffer navigation
map('n', 'gp', ':bp<CR>', { noremap = true, silent = true })
map('n', 'gn', ':bn<CR>', { noremap = true, silent = true })
map('n', 'gl', ':ls<CR>:b<Space>', { noremap = true, silent = true })
map('n', 'gd', ':bp<bar>bd#<CR>', { noremap = true, silent = true })

-- Open file's directory
map('n', '<leader>of', ':!open %:h<CR>', { noremap = true, silent = true })

-- Yank current buffer paths
map('n', '<leader>yr', ':let @+ = expand("%")<CR>', { noremap = true, silent = true, desc = 'Yank relative path' })
map('n', '<leader>ya', ':let @+ = expand("%:p")<CR>', { noremap = true, silent = true, desc = 'Yank absolute path' })

-- New file creation with timestamp in .docs folder
_G.new_file = function(filetype, prefix, extension)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local docs_dir = ".docs"
  
  -- Create .docs directory if it doesn't exist
  if vim.fn.isdirectory(docs_dir) == 0 then
    vim.fn.mkdir(docs_dir, "p")
  end
  
  local filename = string.format("%s/%s_%s%s", docs_dir, prefix, timestamp, extension)
  vim.cmd("enew")
  vim.cmd("setfiletype " .. filetype)
  vim.cmd("file " .. filename)
end

map('n', '<leader>np', ":lua _G.new_file('python', 'snippet', '.py')<CR>", { noremap = true, silent = true })
map('n', '<leader>ns', ":lua _G.new_file('swift', 'snippet', '.swift')<CR>", { noremap = true, silent = true })
map('n', '<leader>nm', ":lua _G.new_file('markdown', 'note', '.md')<CR>", { noremap = true, silent = true })
map('n', '<leader>nc', ":lua _G.new_file('supercollider', 'snippet', '.scd')<CR>", { noremap = true, silent = true })

-- Formatting shortcuts
map('n', '<leader>jf', ':Neoformat json<CR>', { noremap = true, silent = true })
map('n', '<leader>pf', ':%!python3 -c "import sys, ast, pprint; pprint.pprint(ast.literal_eval(sys.stdin.read()))"<CR>', { noremap = true, silent = true })
map('v', '=', ':Neoformat<CR>', {noremap = true})

-- Symbols outline
map('n', '<Leader>o', ':SymbolsOutline<CR>', { noremap = true, silent = true })

-- LSP signature help
map('n', '<leader>sh', '<cmd>lua require("lsp_signature").signature()<CR>', { noremap = true, silent = true })

-- Terminal escape
map('t', '<M-j>', '<C-\\><C-n>', { noremap = true, silent = true, desc = 'Exit terminal mode' })

-- Gemini CLI
map('n', '<leader>ag', function()
  local shell = vim.fn.has('mac') == 1 and 'zsh' or 'bash'
  vim.cmd('vsplit term://' .. shell .. ' -c gemini')
end, { noremap = true, silent = true, desc = 'Open Gemini CLI' })

-- Wiki navigation hotkeys
map('n', '<leader>ww', ':e ~/wiki/index.md<CR>', { noremap = true, silent = true, desc = 'Open wiki index' })
map('n', '<leader>wh', ':e ~/wiki/hm/index.md<CR>', { noremap = true, silent = true, desc = 'Open HM wiki' })
map('n', '<leader>wt', ':e ~/wiki/taug/index.md<CR>', { noremap = true, silent = true, desc = 'Open Taug wiki' })
map('n', '<leader>wm', ':e ~/wiki/might/index.md<CR>', { noremap = true, silent = true, desc = 'Open Might wiki' })
map('n', '<leader>wu', ':e ~/wiki/music/index.md<CR>', { noremap = true, silent = true, desc = 'Open Music wiki' })
map('n', '<leader>wn', ':e ~/wiki/notes/index.md<CR>', { noremap = true, silent = true, desc = 'Open Notes wiki' })
map('n', '<leader>wo', ':e ~/wiki/ozarika/index.md<CR>', { noremap = true, silent = true, desc = 'Open Ozarika wiki' })
map('n', '<leader>ws', ':e ~/wiki/sc/index.md<CR>', { noremap = true, silent = true, desc = 'Open SC wiki' })
map('n', '<leader>wp', ':e ~/wiki/spectra/index.md<CR>', { noremap = true, silent = true, desc = 'Open Spectra wiki' })
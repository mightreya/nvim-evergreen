local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Disable paste mode on insert leave
autocmd('InsertLeave', {
  pattern = '*',
  command = 'set nopaste'
})

-- Remove comments continuation
autocmd('FileType', {
  pattern = '*',
  command = 'setlocal formatoptions-=c formatoptions-=r formatoptions-=o'
})

-- Disable automatic line break
autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*',
  command = 'setlocal textwidth=0'
})

-- Set 2 spaces indentation for specific file types
augroup('IndentationOverrides', { clear = true })
autocmd('FileType', {
  group = 'IndentationOverrides',
  pattern = 'javascript,javascriptreact,typescript,typescriptreact,rell,json',
  command = 'setlocal shiftwidth=2 tabstop=2'
})

-- Sync buffers with the saved files on disk
autocmd({'FocusGained', 'BufEnter'}, {
  pattern = '*',
  command = 'checktime'
})

-- Shader file highlighting
augroup('ShaderHighlighting', { clear = true })
autocmd({'BufRead', 'BufNewFile'}, {
  group = 'ShaderHighlighting',
  pattern = '*.frag,*.vert,*.glsl',
  command = 'set filetype=glsl'
})

-- Python pickle file viewer
autocmd("BufReadCmd", {
  pattern = "*.pkl",
  callback = function()
    local file = vim.fn.expand("<afile>:p")
    local cmd = string.format('python3 -c "import pickle, pprint; pprint.pprint(pickle.load(open(%s, \'rb\')))"', vim.fn.shellescape(file))
    local output = vim.fn.systemlist(cmd)
    
    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
    vim.bo.filetype = "python"
    vim.bo.readonly = true
    vim.bo.modifiable = false
  end,
})

-- Parquet to CSV conversion
autocmd("BufReadCmd", {
  pattern = "*.parquet",
  callback = function()
    local file = vim.fn.expand("<afile>")
    local cmd = "parquet-tools cat -f csv " .. vim.fn.shellescape(file)
    local output = vim.fn.systemlist(cmd)
    
    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
    vim.bo.filetype = "csv"
  end,
})

-- Neoformat helper function
_G.try_format = function()
    local succeeded, result = pcall(vim.cmd, 'Neoformat')
    if not succeeded then
        print('Formatter not defined for this filetype, saving without formatting.')
    end
end

-- Format non-Python files with Neoformat on save
augroup("NonPythonFormatting", { clear = true })
autocmd("BufWritePre", {
  group = "NonPythonFormatting",
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= 'python' then
      _G.try_format()
    end
  end,
})
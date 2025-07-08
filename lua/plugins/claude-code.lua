return {
  {
    "coder/claudecode.nvim",
    config = function()
      require('claudecode').setup()
      
      -- Claude Code keybindings
      local map = vim.keymap.set
      map('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { noremap = true, silent = true, desc = 'Toggle Claude Code' })
      map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { noremap = true, silent = true, desc = 'Focus Claude Code' })
      map('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { noremap = true, silent = true, desc = 'Resume Claude Code' })
      map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { noremap = true, silent = true, desc = 'Continue Claude Code' })
      map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { noremap = true, silent = true, desc = 'Add current buffer to Claude' })
      map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { noremap = true, silent = true, desc = 'Send selection to Claude' })
      map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { noremap = true, silent = true, desc = 'Accept Claude diff' })
      map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { noremap = true, silent = true, desc = 'Deny Claude diff' })
    end
  },
}
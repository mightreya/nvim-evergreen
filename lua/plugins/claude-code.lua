return {
  {
    "coder/claudecode.nvim",
    config = function()
      require('claudecode').setup()
      
      -- Configure Claude Code buffers
      vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "TermOpen"}, {
        pattern = "*",
        callback = function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          -- Match Claude terminal buffers (e.g., term://.../.claude/...)
          if buf_name:match("%.claude/") or buf_name:match("/claude%[") then
            -- Enable relative line numbers for quick navigation (5j, 10k, etc.)
            vim.wo.number = true
            vim.wo.relativenumber = true
            -- Set window width to 50% of screen
            local screen_width = vim.o.columns
            vim.api.nvim_win_set_width(0, math.floor(screen_width * 0.5))
            -- Disable sign column for more space
            vim.wo.signcolumn = "no"
            -- Disable wrap for long lines
            vim.wo.wrap = false
          end
        end
      })
      
      -- Fix buffer naming collision in diff.lua
      local diff_module = require('claudecode.diff')
      local original_create_diff_view = diff_module._create_diff_view_from_window
      diff_module._create_diff_view_from_window = function(target_window, old_file_path, new_buffer, tab_name, is_new_file)
        if is_new_file then
          -- Override buffer naming to avoid collisions
          local original_set_name = vim.api.nvim_buf_set_name
          vim.api.nvim_buf_set_name = function(buf, name)
            if name:match(" %(NEW FILE%)$") then
              local unique_name = name
              local counter = 1
              while vim.fn.bufexists(unique_name) == 1 do
                unique_name = name:gsub(" %(NEW FILE%)$", " (NEW FILE " .. counter .. ")")
                counter = counter + 1
              end
              return original_set_name(buf, unique_name)
            end
            return original_set_name(buf, name)
          end
          
          local result = original_create_diff_view(target_window, old_file_path, new_buffer, tab_name, is_new_file)
          
          -- Restore original function
          vim.api.nvim_buf_set_name = original_set_name
          return result
        end
        return original_create_diff_view(target_window, old_file_path, new_buffer, tab_name, is_new_file)
      end
      
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
return {
  {
    "coder/claudecode.nvim",
    config = function()
      require('claudecode').setup()
      
      -- Claude Code keybindings
      local map = vim.keymap.set
      map('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { noremap = true, silent = true, desc = 'Toggle Claude Code' })
      map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { noremap = true, silent = true, desc = 'Focus Claude Code' })
      map('n', '<leader>aR', '<cmd>ClaudeCode --resume<cr>', { noremap = true, silent = true, desc = 'Resume Claude Code' })
      map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { noremap = true, silent = true, desc = 'Continue Claude Code' })
      map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { noremap = true, silent = true, desc = 'Add current buffer to Claude' })
      map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { noremap = true, silent = true, desc = 'Send selection to Claude' })
      map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { noremap = true, silent = true, desc = 'Accept Claude diff' })
      map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { noremap = true, silent = true, desc = 'Deny Claude diff' })
      
      -- Code review workflow: send modified diff as review and then deny
      map('n', '<leader>ar', function()
        local current_buf = vim.api.nvim_get_current_buf()
        local tab_name = vim.b[current_buf].claudecode_diff_tab_name
        
        if not tab_name then
          vim.notify("No active diff found in current buffer", vim.log.levels.WARN)
          return
        end
        
        -- Check if buffer was modified
        local is_modified = vim.api.nvim_buf_get_option(current_buf, "modified")
        
        if is_modified then
          -- Get the modified content as review
          local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
          local content = "Code review for your proposed change for " .. tab_name .. ":\n\n" .. 
                         "This is your suggested diff that I modified with comments.\n\n" ..
                         table.concat(lines, '\n')
          
          -- TODO: When implementing our own plugin, we should send content directly
          -- to Claude terminal instead of this temp file workaround. ClaudeCodeSend
          -- requires real file paths for at-mentions, so we use temp file approach.
          local temp_file = vim.fn.tempname() .. "_review.txt"
          vim.fn.writefile(vim.split(content, '\n'), temp_file)
          
          -- Add the temp file to Claude
          vim.cmd('ClaudeCodeAdd ' .. temp_file)
          
          -- Auto-deny after sending review (optional)
          vim.defer_fn(function()
            vim.cmd('ClaudeCodeDiffDeny')
          end, 100)  -- Small delay to ensure review is sent first
          
          vim.notify("Review sent to Claude and diff denied.", vim.log.levels.INFO)
        else
          vim.notify("No modifications found to send as review", vim.log.levels.WARN)
        end
      end, { noremap = true, silent = true, desc = 'Send diff review to Claude' })
      
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
            -- Enable wrap for long lines
            vim.wo.wrap = true
          else
            -- Reset to user's defaults for non-Claude buffers
            vim.wo.number = vim.o.number
            vim.wo.relativenumber = vim.o.relativenumber
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
      
      -- Fix E37 error when buffer has unsaved changes
      local original_setup_blocking_diff = diff_module._setup_blocking_diff
      diff_module._setup_blocking_diff = function(params, resolution_callback)
        -- Check if the file is already open in a modified buffer
        local file_path = params.old_file_path
        if vim.fn.filereadable(file_path) == 1 then
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_name == file_path then
                local modified = vim.api.nvim_buf_get_option(buf, "modified")
                if modified then
                  vim.notify("ClaudeCode: Cannot create diff for '" .. vim.fn.fnamemodify(file_path, ":t") .. 
                             "' because it has unsaved changes. Please save or discard your changes first.", 
                             vim.log.levels.WARN)
                  error({
                    code = -32000,
                    message = "Buffer has unsaved changes",
                    data = "The file '" .. file_path .. "' has unsaved changes. Please save or discard them before creating a diff."
                  })
                end
              end
            end
          end
        end
        
        -- Call original function if no unsaved changes
        return original_setup_blocking_diff(params, resolution_callback)
      end
    end
  },
}

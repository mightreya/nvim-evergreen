return {
  {
    "coder/claudecode.nvim",
    config = function()
      require('claudecode').setup({
        -- Auto-focus terminal after sending content
        focus_after_send = true,
        -- Enhanced diff options
        diff_opts = {
          keep_terminal_focus = true,  -- Stay in terminal when diff opens
          on_new_file_reject = "close_window",  -- Close empty buffers when rejecting
        },
        -- Terminal configuration with Snacks.nvim customization
        terminal = {
          provider = "auto",  -- Uses Snacks if available, falls back to native
          split_side = "right",
          split_width_percentage = 0.5,
          -- Configure Snacks - keep nice styling, fix functional issues
          snacks_win_opts = {
            fixbuf = false,  -- Allow buffer commands to work normally
            width = 0.5,     -- Set 50% width directly in Snacks config
            resize = false,  -- Prevent Snacks from resizing automatically
            -- Window options - override minimal defaults only where needed
            wo = {
              number = true,
              relativenumber = true,
              signcolumn = "yes",
            },
            -- Buffer options (bo) for terminal
            bo = {
              modifiable = true,  -- Keep terminal buffer modifiable
            },
            -- Custom key mappings - disable problematic Snacks keys
            keys = {
              q = false,  -- Don't close on 'q'
              ["<C-c>"] = false,  -- Don't intercept Ctrl-C
            },
          },
        },
      })

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
      map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { noremap = true, silent = true, desc = 'Select Claude model' })
      map('n', '<leader>at', '<cmd>ClaudeCodeTreeAdd .<cr>', { noremap = true, silent = true, desc = 'Add directory tree to Claude' })
      map('n', '<leader>aS', '<cmd>ClaudeCodeStatus<cr>', { noremap = true, silent = true, desc = 'Claude Code status' })
      
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
      
      -- E37 error fix removed - now handled upstream in diff.lua
    end
  },
}

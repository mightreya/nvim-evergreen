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
        -- Terminal configuration
        terminal = {
          provider = "native",
          split_side = "right",
          split_width_percentage = 0.5,
        },
      })

      -- Add background color for Claude terminal
      vim.api.nvim_create_autocmd({"TermOpen", "BufEnter"}, {
        pattern = "term://*claude*",
        callback = function()
          -- Use NormalFloat background (same as floating windows)
          vim.wo.winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat"
        end
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
      
      local diff_module = require('claudecode.diff')

      local function find_terminal_window()
        local terminal_module = require('claudecode.terminal')
        local terminal_bufnr = terminal_module.get_active_terminal_bufnr()
        if terminal_bufnr then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == terminal_bufnr then
              return win
            end
          end
        end
      end

      local function resize_terminal(percentage)
        local term_win = find_terminal_window()
        if term_win then
          local width = math.floor(vim.o.columns * percentage)
          pcall(vim.api.nvim_win_set_width, term_win, width)
        end
      end

      -- Fix buffer naming collision for NEW FILE diffs
      local original_create_diff_view = diff_module._create_diff_view_from_window
      diff_module._create_diff_view_from_window = function(target_window, old_file_path, new_buffer, tab_name, is_new_file, terminal_win_in_new_tab, existing_buffer)
        if is_new_file then
          local original_set_name = vim.api.nvim_buf_set_name
          vim.api.nvim_buf_set_name = function(buffer, name)
            if name:match(" %(NEW FILE%)$") then
              local unique_name = name
              local counter = 1
              while vim.fn.bufexists(unique_name) == 1 do
                unique_name = name:gsub(" %(NEW FILE%)$", " (NEW FILE " .. counter .. ")")
                counter = counter + 1
              end
              return original_set_name(buffer, unique_name)
            end
            return original_set_name(buffer, name)
          end

          local result = original_create_diff_view(target_window, old_file_path, new_buffer, tab_name, is_new_file, terminal_win_in_new_tab, existing_buffer)
          vim.api.nvim_buf_set_name = original_set_name

          -- Shrink terminal after diff windows are created
          vim.schedule(function()
            resize_terminal(0.30)
          end)

          return result
        end

        local result = original_create_diff_view(target_window, old_file_path, new_buffer, tab_name, is_new_file, terminal_win_in_new_tab, existing_buffer)

        -- Shrink terminal after diff windows are created
        vim.schedule(function()
          resize_terminal(0.30)
        end)

        return result
      end

      -- Auto-cleanup diff buffers immediately after accept/reject
      -- The plugin waits for close_tab call that never comes (schema=nil, not exposed via MCP)
      local function cleanup_and_focus_terminal(tab_name)
        local active_diffs = diff_module._get_active_diffs()
        local diff_state = active_diffs[tab_name]

        -- Capture buffer IDs before cleanup
        local new_buffer = diff_state and diff_state.new_buffer
        local original_buffer = diff_state and diff_state.original_buffer
        local is_new_file = diff_state and diff_state.is_new_file

        diff_module.close_diff_by_tab_name(tab_name)

        -- Force delete any remaining buffers
        if new_buffer and vim.api.nvim_buf_is_valid(new_buffer) then
          pcall(vim.api.nvim_buf_delete, new_buffer, { force = true })
        end
        if is_new_file and original_buffer and vim.api.nvim_buf_is_valid(original_buffer) then
          pcall(vim.api.nvim_buf_delete, original_buffer, { force = true })
        end

        -- Expand terminal back to 50% after diff closes
        resize_terminal(0.50)

        -- Restore focus to Claude terminal
        local term_win = find_terminal_window()
        if term_win then
          vim.api.nvim_set_current_win(term_win)
          vim.cmd('startinsert')
        end
      end

      local original_resolve_saved = diff_module._resolve_diff_as_saved
      diff_module._resolve_diff_as_saved = function(tab_name, buffer_id)
        original_resolve_saved(tab_name, buffer_id)
        vim.defer_fn(function()
          cleanup_and_focus_terminal(tab_name)
        end, 100)
      end

      local original_resolve_rejected = diff_module._resolve_diff_as_rejected
      diff_module._resolve_diff_as_rejected = function(tab_name)
        original_resolve_rejected(tab_name)
        vim.defer_fn(function()
          cleanup_and_focus_terminal(tab_name)
        end, 100)
      end
    end
  },
}

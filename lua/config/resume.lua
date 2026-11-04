-- Resumes a tmux pane's own Claude conversation after tmux-resurrect restores the pane.
-- tmux-resurrect starts Neovim with NVIM_CLAUDE_CONTINUE=1, and the Claude Code SessionStart hook
-- claude-pane-record keeps one file per pane (named session:window.pane) holding its conversation id.
local M = {}

M.record_directory = vim.fn.expand("~/.local/state/claude-pane")

local function is_running(session_id)
  vim.fn.system({ "pgrep", "-f", "resume " .. session_id })
  return vim.v.shell_error == 0
end

local function resume()
  if not vim.env.TMUX_PANE then
    return
  end
  local pane = vim.trim(vim.fn.system({ "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE, "#S:#I.#P" }))
  if vim.v.shell_error ~= 0 then
    return
  end
  local session_id = M.session_for_pane(M.record_directory, pane)
  if not session_id or is_running(session_id) then
    return
  end
  -- ClaudeCode toggles, so it must not run when Claude was already opened in this Neovim
  if require("claudecode.terminal").get_active_terminal_bufnr() then
    return
  end
  vim.cmd("ClaudeCode --resume " .. session_id)
end

function M.setup()
  if vim.env.NVIM_CLAUDE_CONTINUE ~= "1" then
    return
  end
  vim.env.NVIM_CLAUDE_CONTINUE = nil
  if vim.v.vim_did_enter == 1 then
    M.resume_later()
  else
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = M.resume_later })
  end
end

-- The conversation id saved for a pane, or nil when there is none or it is not a valid id
function M.session_for_pane(record_directory, pane)
  local record = record_directory .. "/" .. pane
  if vim.fn.filereadable(record) == 0 then
    return nil
  end
  local session_id = vim.trim(vim.fn.readfile(record)[1] or "")
  if not session_id:match("^[%w-]+$") then
    return nil
  end
  return session_id
end

-- A per-process random delay spreads the restored sessions over 20 seconds instead of starting them all at once
function M.resume_later()
  math.randomseed(vim.uv.hrtime() + vim.fn.getpid())
  vim.defer_fn(resume, math.random(0, 20000))
end

return M

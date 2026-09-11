-- Run from the repository root after Lazy has installed the plugins.
local repository = vim.fn.getcwd()
local plugin_directory = vim.fn.stdpath("data") .. "/lazy/"
local project = vim.fn.tempname()

local function verify()
  assert(vim.fn.has("nvim-0.12") == 1, "Neovim 0.12+ is required")
  vim.opt.rtp:prepend(plugin_directory .. "codex.nvim")
  vim.opt.rtp:prepend(plugin_directory .. "code-preview.nvim")
  vim.g.mapleader = ","
  vim.o.columns = 160
  vim.o.lines = 50
  vim.fn.mkdir(project .. "/.git", "p")
  assert(vim.uv.fs_symlink(vim.fn.exepath("cat"), project .. "/codex-smoke"))

  local specifications = dofile(repository .. "/lua/plugins/codex.lua")
  local options = vim.deepcopy(specifications[2].opts)
  assert(specifications[2].lazy == false, "Selection mappings must load at startup")
  assert(vim.deep_equal(options.cmd, { "codex", "--approve-for-me" }))
  -- A local echo process exercises the terminal without an account or model call.
  options.cmd = { project .. "/codex-smoke" }
  require("code-preview").setup(specifications[1].opts)
  specifications[2].config(nil, options)
  dofile(repository .. "/lua/config/autocmds.lua")

  vim.fn.writefile({ "before" }, project .. "/example.txt")
  vim.cmd.cd(project)
  vim.cmd.edit(project .. "/example.txt")
  local hooks = require("code-preview.backends.codex")
  hooks.install()
  assert(hooks.is_installed(), "Fixture hooks were not installed")

  local codex = require("codex")
  local terminal = require("codex.terminal")
  assert(codex.open(), "Terminal did not open")
  assert(vim.wait(3000, terminal.is_running, 50), "Terminal did not start")
  local initial = terminal.status()
  assert(initial.visible and initial.cwd == vim.uv.fs_realpath(project))
  local width = vim.api.nvim_win_get_width(initial.winid)
  assert(math.abs(width - math.floor(vim.o.columns * 0.5)) <= 2)
  assert(vim.wo[initial.winid].relativenumber)
  assert(vim.wo[initial.winid].winhighlight:find("NormalFloat"))
  assert(vim.fn.maparg("<Esc>", "t") == "")
  assert(vim.fn.maparg("<M-j>", "t") ~= "")
  assert(vim.fn.maparg(",ca", "x") ~= "")
  assert(vim.fn.maparg(",ce", "x") ~= "")
  codex.close()
  assert(terminal.is_running() and not terminal.is_visible())
  codex.open()
  assert(terminal.status().jobid == initial.jobid)
  assert(terminal.is_visible())
  codex.close()

  local payload = {
    tool_name = "apply_patch",
    cwd = project,
    tool_input = {
      command = "*** Begin Patch\n*** Update File: example.txt\n@@\n-before\n+after\n*** End Patch",
    },
  }
  local diff = require("code-preview.diff")
  require("code-preview.pre_tool").handle(payload, "codex")
  assert(vim.wait(2000, diff.is_open, 50), "Edit preview did not open")
  assert(vim.fn.readfile(project .. "/example.txt")[1] == "before")
  require("code-preview.post_tool").handle(payload, "codex")
  assert(vim.wait(2000, function() return not diff.is_open() end, 50))

  payload.tool_input.command = "*** Begin Patch\n*** Add File: new.txt\n+new content\n*** End Patch"
  require("code-preview.pre_tool").handle(payload, "codex")
  assert(vim.wait(2000, diff.is_open, 50), "New file preview did not open")
  assert(vim.fn.filereadable(project .. "/new.txt") == 0)
  vim.cmd.CodePreviewCloseDiff()
  assert(not diff.is_open(), "Manual preview cleanup failed")
  assert(vim.fn.filereadable(project .. "/new.txt") == 0)
end

local succeeded, failure = xpcall(verify, debug.traceback)
if package.loaded["codex.terminal"] then
  require("codex.terminal")._reset()
end
if package.loaded["code-preview.diff"] then
  require("code-preview.diff").close_diff_and_clear()
end
vim.cmd.cd(repository)
vim.fn.delete(project, "rf")
if succeeded then
  vim.notify("PASS: Codex terminal lifecycle, root, layout, keys, hook setup, edit/new-file previews and cleanup")
  vim.cmd("qa!")
else
  vim.notify(tostring(failure), vim.log.levels.ERROR)
  vim.cmd("cquit")
end

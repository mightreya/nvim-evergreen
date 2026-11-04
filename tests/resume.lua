-- Run: nvim --headless --clean -l tests/resume.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local resume = require("config.resume")

local record_directory = vim.fn.tempname()
vim.fn.mkdir(record_directory, "p")
vim.fn.writefile({ "6fbe6d55-aa76-4888-ac1b-423966fa4f95" }, record_directory .. "/strikta:0.0")
vim.fn.writefile({ "6fbe6d55; rm -rf ~" }, record_directory .. "/strikta:1.0")
vim.fn.writefile({}, record_directory .. "/health:0.0")

assert(resume.session_for_pane(record_directory, "strikta:0.0") == "6fbe6d55-aa76-4888-ac1b-423966fa4f95")
assert(resume.session_for_pane(record_directory, "strikta:1.0") == nil, "an id with shell characters must be refused")
assert(resume.session_for_pane(record_directory, "health:0.0") == nil, "an empty record has no conversation")
assert(resume.session_for_pane(record_directory, "tether:0.0") == nil, "a pane without a record has no conversation")

local scheduled_count = 0
resume.resume_later = function()
  scheduled_count = scheduled_count + 1
end

vim.env.NVIM_CLAUDE_CONTINUE = nil
resume.setup()
assert(scheduled_count == 0, "Neovim started normally must not resume anything")

vim.env.NVIM_CLAUDE_CONTINUE = "1"
resume.setup()
assert(scheduled_count == 1, "a Neovim restored by tmux-resurrect must schedule one resume")
assert(vim.env.NVIM_CLAUDE_CONTINUE == nil, "the flag must not reach Claude's environment")

vim.fn.delete(record_directory, "rf")
print("PASS: resume")

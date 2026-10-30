-- Run: nvim --headless --clean -l tests/claude_resume.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local claude_resume = require("config.claude_resume")

local record_directory = vim.fn.tempname()
vim.fn.mkdir(record_directory, "p")
vim.fn.writefile({ "6fbe6d55-aa76-4888-ac1b-423966fa4f95" }, record_directory .. "/strikta:0.0")
vim.fn.writefile({ "6fbe6d55; rm -rf ~" }, record_directory .. "/strikta:1.0")
vim.fn.writefile({}, record_directory .. "/health:0.0")

assert(claude_resume.session_for_pane(record_directory, "strikta:0.0") == "6fbe6d55-aa76-4888-ac1b-423966fa4f95")
assert(claude_resume.session_for_pane(record_directory, "strikta:1.0") == nil, "an id with shell characters must be refused")
assert(claude_resume.session_for_pane(record_directory, "health:0.0") == nil, "an empty record has no conversation")
assert(claude_resume.session_for_pane(record_directory, "tether:0.0") == nil, "a pane without a record has no conversation")

local vim_enter_count = #vim.api.nvim_get_autocmds({ event = "VimEnter" })
vim.env.NVIM_CLAUDE_CONTINUE = nil
claude_resume.setup()
assert(#vim.api.nvim_get_autocmds({ event = "VimEnter" }) == vim_enter_count, "Neovim started normally must not resume anything")

vim.env.NVIM_CLAUDE_CONTINUE = "1"
claude_resume.setup()
assert(vim.env.NVIM_CLAUDE_CONTINUE == nil, "the flag must not reach Claude's environment")

vim.fn.delete(record_directory, "rf")
print("PASS: claude_resume")

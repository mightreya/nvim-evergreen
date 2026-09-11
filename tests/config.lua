local function verify()
  local plugins = require("lazy.core.config").plugins
  assert(plugins["nvim-treesitter"]._.loaded, "Tree-sitter did not load")
  assert(plugins["nvim-colorizer.lua"]._.loaded, "Colorizer did not load")
  assert(plugins["snacks.nvim"]._.loaded, "Snacks did not load")
  assert(plugins["codex.nvim"]._.loaded, "Codex did not load")
  assert(plugins["code-preview.nvim"]._.loaded, "Code preview did not load")
  assert(not plugins["octo.nvim"]._.loaded, "Octo should load only when requested")
  assert(vim.fn.exists(":Octo") == 2, "Octo lazy-load command is missing")
  assert(vim.fn.exists(":Codex") == 2, "Codex command is missing")
  assert(vim.fn.exists(":CodePreviewInstallCodexCliHooks") == 2)
  assert(vim.fn.maparg(",cc", "n"):find("Codex"))
  assert(vim.fn.maparg(",ac", "n"):find("ClaudeCode"))
  assert(vim.fn.maparg(",of", "n"):find("open"))
  assert(vim.fn.maparg(",o", "n"):find("SymbolsOutline"))
  assert(vim.o.autoread)

  local specifications = dofile(vim.fn.getcwd() .. "/lua/plugins/codex.lua")
  assert(vim.deep_equal(specifications[2].opts.cmd, { "codex", "--approve-for-me" }))

  local current_buffer = vim.api.nvim_get_current_buf()
  local special_buffer = vim.api.nvim_create_buf(false, true)
  vim.bo[special_buffer].buftype = "nofile"
  vim.bo[special_buffer].modifiable = false
  vim.api.nvim_set_current_buf(special_buffer)
  vim.api.nvim_exec_autocmds("BufWritePre", { buffer = special_buffer })
  assert(not plugins.neoformat._.loaded, "Neoformat loaded for a nonmodifiable special buffer")
  vim.api.nvim_set_current_buf(current_buffer)
  vim.api.nvim_buf_delete(special_buffer, { force = true })
end

vim.defer_fn(function()
  local succeeded, failure = xpcall(verify, debug.traceback)
  if succeeded then
    vim.notify("PASS: full-config startup, plugin loading, commands, keymaps and formatter scope")
    vim.cmd("qa!")
  else
    vim.notify(tostring(failure), vim.log.levels.ERROR)
    vim.cmd("cquit")
  end
end, 500)

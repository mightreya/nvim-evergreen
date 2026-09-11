local samples = {
  bash = { filetype = "sh", source = "echo ok" },
  c = { filetype = "c", source = "int main(void) { return 0; }" },
  cpp = { filetype = "cpp", source = "int main() { return 0; }" },
  c_sharp = { filetype = "cs", source = "class Example {}" },
  css = { filetype = "css", source = "body { color: red; }" },
  glsl = { filetype = "glsl", source = "void main() {}" },
  go = { filetype = "go", source = "package main" },
  html = { filetype = "html", source = "<main>ok</main>" },
  javascript = { filetype = "javascript", source = "const answer = 42;" },
  json = { filetype = "json", source = '{"answer": 42}' },
  lua = { filetype = "lua", source = "local answer = 42" },
  python = { filetype = "python", source = "answer = 42" },
  rust = { filetype = "rust", source = "fn main() {}" },
  swift = { filetype = "swift", source = "let answer = 42" },
  typescript = { filetype = "typescript", source = "const answer: number = 42;" },
  wgsl = { filetype = "wgsl", source = "fn main() {}" },
  yaml = { filetype = "yaml", source = "answer: 42" },
}

local function parse(language, sample)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { sample.source })
  vim.bo[buffer].filetype = sample.filetype
  local parser = vim.treesitter.get_parser(buffer, language)
  assert(#parser:parse() > 0, language .. " parser returned no syntax tree")
  vim.api.nvim_buf_delete(buffer, { force = true })
end

local function verify()
  assert(vim.fn.has("nvim-0.12") == 1, "Neovim 0.12+ is required")
  assert(require("lazy.core.config").plugins["nvim-treesitter"]._.loaded)

  for language, sample in pairs(samples) do
    parse(language, sample)
  end

  local markdown = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(markdown, 0, -1, false, {
    "# Embedded parsers",
    "",
    "```lua",
    "local answer = 42",
    "```",
    "",
    "```python",
    "answer = 42",
    "```",
  })
  vim.bo[markdown].filetype = "markdown"
  vim.api.nvim_set_current_buf(markdown)
  vim.v.errmsg = ""
  vim.treesitter.start(markdown, "markdown")
  local parser = vim.treesitter.get_parser(markdown, "markdown")
  assert(#parser:parse() > 0, "Markdown parser returned no syntax tree")
  vim.api.nvim_buf_set_lines(markdown, 3, 4, false, { "local answer = 43" })
  vim.wait(250)
  assert(#parser:parse() > 0, "Markdown parser failed after a fenced-code edit")
  assert(not vim.v.errmsg:match("attempt to call method 'range'"), vim.v.errmsg)
  vim.api.nvim_buf_delete(markdown, { force = true })
end

local succeeded, failure = xpcall(verify, debug.traceback)
if succeeded then
  vim.notify("PASS: configured Tree-sitter parsers and Markdown injections")
  vim.cmd("qa!")
else
  vim.notify(tostring(failure), vim.log.levels.ERROR)
  vim.cmd("cquit")
end

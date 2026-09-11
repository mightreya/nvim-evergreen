return {
  {
    "Cannon07/code-preview.nvim",
    opts = {
      diff = { layout = "vsplit" },
      keys = { close_all = "<leader>cq" },
    },
  },
  {
    "nwiizo/codex.nvim",
    lazy = false,
    dependencies = { "Cannon07/code-preview.nvim" },
    keys = {
      { "<leader>cc", "<cmd>Codex<cr>", desc = "Toggle Codex" },
      { "<leader>cf", "<cmd>CodexFocus<cr>", desc = "Focus or hide Codex" },
      { "<leader>cR", "<cmd>CodexResume<cr>", desc = "Resume Codex" },
      { "<leader>cC", "<cmd>CodexContinue<cr>", desc = "Continue Codex" },
      { "<leader>cb", "<cmd>CodexAdd<cr>", desc = "Add current buffer to Codex" },
      { "<leader>cs", ":<C-U>CodexAddVisual<cr>", mode = "x", desc = "Add selection to Codex" },
      { "<leader>ca", "<cmd>CodexAsk<cr>", desc = "Ask Codex with file context" },
      { "<leader>ct", "<cmd>CodexTreeAdd<cr>", desc = "Add explorer paths to Codex" },
      { "<leader>cr", "<cmd>CodexReview<cr>", desc = "Review changes with Codex" },
      { "<leader>cx", "<cmd>CodexStop<cr>", desc = "Stop Codex" },
      { "<leader>cS", "<cmd>CodexStatus<cr>", desc = "Codex status" },
    },
    opts = {
      backend = "terminal",
      cmd = { "codex", "--approve-for-me" },
      cwd = "root",
      focus_after_send = true,
      selection = {
        keymaps = { ask = "<leader>ca", edit = "<leader>ce" },
      },
      terminal = {
        layout = "split",
        split_side = "right",
        split_width_percentage = 0.5,
        window_navigation = false,
        normal_mode_keys = { "<M-j>" },
        hide_keys = { "<C-/>", "<C-_>" },
      },
    },
    config = function(_, options)
      require("codex").setup(options)

      vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
        group = vim.api.nvim_create_augroup("CodexTerminalAppearance", { clear = true }),
        pattern = "term://*codex*",
        callback = function()
          vim.wo.winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat"
        end,
      })
    end,
  },
}

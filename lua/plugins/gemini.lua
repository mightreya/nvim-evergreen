return {
  {
    "marcinjahn/gemini-cli.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "folke/snacks.nvim"
    },
    lazy = false,
    keys = {
      { "<leader>gg", "<cmd>Gemini toggle<cr>", desc = "Toggle Gemini CLI" },
      { "<leader>ga", "<cmd>Gemini add_file<cr>", desc = "Add current file to Gemini" },
      { "<leader>gq", function() vim.ui.input({prompt = "Ask Gemini: "}, function(input) if input then vim.cmd("Gemini ask " .. input) end end) end, desc = "Ask Gemini a question" },
      { "<leader>gh", "<cmd>Gemini health<cr>", desc = "Gemini health check" },
      { "<leader>gm", "<cmd>Gemini<cr>", desc = "Gemini menu" },
    },
    config = function()
      require("gemini_cli").setup({
        -- Path to gemini CLI command
        gemini_cmd = "gemini",
        -- Command line arguments
        args = {},
        -- Auto-reload buffers on external changes
        auto_reload = true,
        -- Terminal window configuration
        terminal = {
          position = "right",
          width = 0.5,
          winbar = true,
        },
        -- Telescope picker configuration
        picker = {
          prompt_title = "Gemini CLI Commands",
          layout_config = {
            width = 0.8,
            height = 0.6,
          },
        },
      })
    end
  }
}
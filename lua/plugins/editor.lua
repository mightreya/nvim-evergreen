return {
  -- Formatting for non-Python files
  {
    "sbdchd/neoformat",
    cmd = "Neoformat",
  },

  -- Surroundings
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  -- Comment in/out
  {
    "terrortylor/nvim-comment",
    config = function()
      require('nvim_comment').setup()
    end
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup {
        indent = {
          char = "│",
        },
        exclude = {
          filetypes = { "help", "terminal", "dashboard", "packer", "lspinfo", "TelescopePrompt", "TelescopeResults", "startify", "NvimTree", "vista", "qf", "vimwiki" },
          buftypes = { "terminal", "nofile" }
        },
        scope = {
          enabled = true
        }
      }
    end
  },

  -- Colorize hex codes
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require('colorizer').setup()
    end
  },

  -- File overview
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    config = function()
      require("symbols-outline").setup()
    end
  },

  -- EditorConfig support
  {
    "editorconfig/editorconfig-vim",
  },
}
local languages = {
  "bash",
  "c",
  "cpp",
  "c_sharp",
  "css",
  "glsl",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "swift",
  "typescript",
  "wgsl",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      require("nvim-treesitter").install(languages):wait(300000)
    end,
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-ts-autotag").setup()

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      vim.filetype.add({
        extension = {
          wgsl = "wgsl",
        },
      })
    end,
  },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "bash", "c", "cpp", "c_sharp", "css", "go", "html", "javascript",
          "json", "lua", "python", "rust", "swift", "typescript", "yaml", "glsl"
        },
        highlight = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
      }
    end
  },
}
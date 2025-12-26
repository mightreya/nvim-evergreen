return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.wgsl = {
        install_info = {
          url = "https://github.com/szebniok/tree-sitter-wgsl",
          files = {"src/parser.c", "src/scanner.c"},
          branch = "main",
        },
        filetype = "wgsl",
      }

      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "bash", "c", "cpp", "c_sharp", "css", "go", "html", "javascript",
          "json", "lua", "python", "rust", "swift", "typescript", "yaml", "glsl", "wgsl"
        },
        highlight = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
      }

      vim.filetype.add({
        extension = {
          wgsl = "wgsl",
        },
      })
    end
  },
}
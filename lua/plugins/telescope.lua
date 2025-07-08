return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      telescope.setup {
        defaults = {
          path_display = {"absolute"},
          file_ignore_patterns = { "node_modules" },
          file_sorter = require('telescope.sorters').get_fuzzy_file
        },
        extensions = {
          fzf = {
            override_generic_sorter = false,
            override_file_sorter = false,
          },
          project = {
            base_dirs = {
              '~/wiki',
            },
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {}
          }
        },
      }

      -- Load extensions
      telescope.load_extension('fzf')
      telescope.load_extension('project')
      telescope.load_extension('ui-select')

      -- Keymaps
      vim.keymap.set('n', '<C-p>', function()
        builtin.find_files({
          layout_strategy = 'bottom_pane',
          layout_config = {
            width = 1.0,
          },
          selection_caret = "> ",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          scroll_strategy = "cycle",
          color_devicons = true,
          set_env = { ['COLORTERM'] = 'truecolor' },
          file_sorter = require('telescope.sorters').get_fzy_sorter,
          file_previewer = require('telescope.previewers').vim_buffer_cat.new,
          grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
          qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        })
      end, { noremap = true })

      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>fp', function()
        require('telescope').extensions.project.project{}
      end, { noremap = true, silent = true })
    end
  },

  -- FZF native for better performance
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
}
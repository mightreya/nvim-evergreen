return {
  -- LaTeX support
  {
    "lervag/vimtex",
    ft = "tex",
  },

  -- Wiki/Notes
  {
    "lervag/wiki.vim",
    dependencies = {
      "lervag/wiki-ft.vim",
    },
    ft = "markdown",
  },

  -- TidalCycles
  {
    "tidalcycles/vim-tidal",
    ft = "tidal",
  },
}
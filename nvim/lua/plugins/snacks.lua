return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      side = "right",
      -- your other explorer options
    },
    picker = {
      sources = {
        explorer = false, -- disable the explorer picker
      },
    },
  },
}

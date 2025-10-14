return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      layout = {
        preset = "sidebar",
        position = "right",
        preview = false,
      },
    },
    picker = {
      sources = {
        explorer = {
          layout = { layout = { position = "right" }, preset = "sidebar", preview = false },
        },
      },
    },
  },
}

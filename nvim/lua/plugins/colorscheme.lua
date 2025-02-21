return {
  -- Add Gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim to load Gruvbox with transparency
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- Enable transparency in Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      transparent_mode = true,
    },
  },
}

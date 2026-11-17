return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      contrast = "hard",
      transparent_mode = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "gruvbox"
      opts.options.section_separators = ""
      opts.options.component_separators = ""
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
███╗   ███╗ █████╗ ██╗  ██╗██╗
████╗ ████║██╔══██╗██║  ██║██║
██╔████╔██║███████║███████║██║
██║╚██╔╝██║██╔══██║██╔══██║╚═╝
██║ ╚═╝ ██║██║  ██║██║  ██║██╗
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝
]],
        },
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            layout = { preset = "sidebar", preview = false, layout = { position = "right" } },
          },
          files = { hidden = true, ignored = true },
          grep = { hidden = true, ignored = true },
        },
      },
    },
  },
}

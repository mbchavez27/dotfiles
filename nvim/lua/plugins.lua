return require("lazy").setup({
  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Neo-tree file explorer
{
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",  -- <-- REQUIRED
  },
  lazy = false,
  config = function()
    vim.schedule(function()
      require("neo-tree").setup({
        close_if_last_window = false,
        window = { position = "right", width = 35 },
        filesystem = {
          follow_current_file = true,
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = true,
        },
      })
    end)
  end,
  keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle File Explorer" } },
},


  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Null-ls for formatters/linters
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
})

return {
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
    end,
    ft = { "python", "quarto", "markdown" },
    keys = {
      { "<leader>mi", ":MoltenInit ", desc = "Molten Init", ft = { "python", "quarto", "markdown" } },
      { "<leader>mv", ":MoltenEvaluateVisual<CR>", mode = "v", desc = "Molten Evaluate Visual" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Molten Re-eval Cell", ft = { "python", "quarto", "markdown" } },
      { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten Show Output", ft = { "python", "quarto", "markdown" } },
      { "<leader>mh", ":MoltenHide<CR>", desc = "Molten Hide Output", ft = { "python", "quarto", "markdown" } },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      custom_language_formatting = {
        python = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
      },
    },
    ft = { "python", "quarto", "markdown" },
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {},
  },
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "quarto" },
        },
      },
    },
  },
}

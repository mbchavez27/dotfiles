return {
  -- LSP support for TypeScript / JavaScript
  {
    "neovim/nvim-lspconfig",
    dependencies = { "jose-elias-alvarez/typescript.nvim" },
    opts = {
      servers = {
        ts_ls = {
          settings = {
            typescript = {
              format = { semicolons = "insert" },
            },
            javascript = {
              format = { semicolons = "insert" },
            },
          },
        },
      },
      setup = {
        ts_ls = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
      },
    },
  },

  -- Formatters and Linters
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        javascript = { "prettier" },
        tsx = { "prettier" },
        jsx = { "prettier" },
      },
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
}

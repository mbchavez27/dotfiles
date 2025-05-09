return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { -- Mason handles tools and formatters
        "clang-format", -- Formatter for C
        "prettier", -- Formatter for JS/TS/HTML/CSS
        "gofumpt", -- Formatter for Go
        "goimports", -- Formatter for Go
        "stylua", -- Formatter for Lua
      },
    },
    config = function()
      require("mason").setup()

      -- LSP servers should be configured via mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = { -- These are actual LSP servers
          "clangd", -- C/C++
          "typescript-language-server", -- Change from "tsserver"
          "html", -- HTML
          "cssls", -- CSS
          "gopls", -- Go
        },
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    init = function()
      -- Install the conform formatter on VeryLazy
      LazyVim.on_very_lazy(function()
        LazyVim.format.register({
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            require("conform").format({ bufnr = buf })
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    opts = function()
      local plugin = require("lazy.core.config").plugins["conform.nvim"]
      if plugin.config then
        LazyVim.error({
          "Don't set `plugin.config` for `conform.nvim`.",
          "This will break **LazyVim** formatting.",
          "Please refer to the docs at https://www.lazyvim.org/plugins/formatting",
        }, { title = "LazyVim" })
      end

      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          c = { "clang-format" },
          html = { "prettier" },
          css = { "prettier" },
          go = { "gofmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
        formatters = {
          injected = { options = { ignore_errors = true } },
        },
      }
      return opts
    end,
    config = function(_, opts)
      require("conform").setup(opts)
    end,
  },
}

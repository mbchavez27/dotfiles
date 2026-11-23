-- nvim's dedicated Python host (see install/common.sh setup_nvim_python) carries the
-- jupytext CLI. Append (not prepend) so project pythons still win on PATH.
local nvim_py_bin = vim.fn.stdpath("data") .. "/python/bin"
if vim.fn.isdirectory(nvim_py_bin) == 1 and not vim.env.PATH:find(nvim_py_bin, 1, true) then
  vim.env.PATH = vim.env.PATH .. ":" .. nvim_py_bin
end

local notebook_fts = { "python", "quarto", "markdown" }

local function is_ipynb(buf)
  return vim.api.nvim_buf_get_name(buf or 0):match("%.ipynb$") ~= nil
end

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
      vim.g.molten_virt_lines_off_by_1 = true -- outputs land below the ``` fence

      local group = vim.api.nvim_create_augroup("molten_ipynb", { clear = true })
      -- Kernel start stays manual (<leader>mi); once it runs, pull in the outputs
      -- already saved in the notebook so plots/results show inline.
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MoltenInitPost",
        callback = function()
          if is_ipynb() then
            pcall(vim.cmd, "MoltenImportOutput")
          end
        end,
      })
      -- Write outputs back into the .ipynb on save (only when a kernel is attached).
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.ipynb",
        callback = function()
          -- MoltenStatusLineInit only exists once the remote plugin has loaded.
          local ok, inited = pcall(function()
            return require("molten.status").initialized() == "Molten"
          end)
          if ok and inited then
            pcall(vim.cmd, "MoltenExportOutput!")
          end
        end,
      })
    end,
    ft = notebook_fts,
    keys = {
      { "<leader>mi", ":MoltenInit ", desc = "Molten Init", ft = notebook_fts },
      { "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v", desc = "Molten Evaluate Visual" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Molten Re-eval Cell", ft = notebook_fts },
      { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten Show Output", ft = notebook_fts },
      { "<leader>mh", ":MoltenHideOutput<CR>", desc = "Molten Hide Output", ft = notebook_fts },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    -- Must not be lazy: it hooks BufReadCmd *.ipynb, which fires before any filetype.
    lazy = false,
    opts = {
      custom_language_formatting = {
        python = {
          -- jupytext's "quarto" style needs the Quarto CLI (~300 MB); plain markdown
          -- gives the same ```python cells, and quarto ft keeps runner/Molten/LSP.
          extension = "md",
          style = "markdown",
          force_ft = "quarto",
        },
      },
    },
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {
      codeRunner = { enabled = true, default_method = "molten" },
    },
    keys = {
      { "<leader>mc", function() require("quarto.runner").run_cell() end, desc = "Run Cell", ft = "quarto" },
      { "<leader>ma", function() require("quarto.runner").run_above() end, desc = "Run Cell + Above", ft = "quarto" },
      { "<leader>mA", function() require("quarto.runner").run_all() end, desc = "Run All Cells", ft = "quarto" },
    },
  },
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      backend = "kitty", -- Ghostty speaks the kitty graphics protocol
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

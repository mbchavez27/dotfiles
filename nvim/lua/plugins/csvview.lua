return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  keys = {
    {
      "<leader>sv",
      function()
        if vim.fn.executable("vd") == 0 then
          vim.notify("VisiData not found: uv tool install visidata", vim.log.levels.WARN)
          return
        end
        Snacks.terminal({ "vd", vim.fn.expand("%:p") }, { win = { position = "float" } })
      end,
      desc = "VisiData (current file)",
    },
  },
  opts = {
    parser = { comments = { "#", "//" } },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
    view = {
      min_column_width = 5,
      spacing = 2,
      display_mode = "highlight",
      header_lnum = true,
      sticky_header = {
        enabled = true,
        separator = "─",
      },
    },
  },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
  config = function(_, opts)
    require("csvview").setup(opts)
    -- aligned columns by default; :CsvViewToggle shows the raw text
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("csvview_auto", { clear = true }),
      pattern = { "csv", "tsv" },
      callback = function(ev)
        require("csvview").enable(ev.buf)
      end,
    })
    if vim.tbl_contains({ "csv", "tsv" }, vim.bo.filetype) then
      require("csvview").enable(0)
    end
  end,
}

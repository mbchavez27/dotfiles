local autocmd = vim.api.nvim_create_autocmd

-- Trailing spaces are meaningful in Markdown (hard line breaks).
local keep_trailing_ws = { markdown = true, quarto = true }

autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("strip_trailing_ws", { clear = true }),
  callback = function(ev)
    if keep_trailing_ws[vim.bo[ev.buf].filetype] then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})


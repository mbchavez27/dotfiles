-- LazyVim already provides <C-s>, <C-hjkl>, <leader>cf (format) and <leader>gg (lazygit).
local map = vim.keymap.set

map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

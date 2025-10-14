local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Tabs / Buffers (VSCode: Ctrl+Tab / Ctrl+Shift+Tab)
map("n", "<C-Tab>", ":bnext<CR>", opts)
map("n", "<C-S-Tab>", ":bprevious<CR>", opts)

-- Split navigation (VSCode: Ctrl+\ / Ctrl+1/2/3)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- VSCode copy/paste
map("v", "<C-c>", '"+y', opts)
map("n", "<C-v>", '"+p', opts)

-- File explorer toggle (like VSCode side bar)
map("n", "<C-n>", ":NvimTreeToggle<CR>", opts)

-- Save
map("n", "<C-s>", ":w<CR>", opts)
map("i", "<C-s>", "<Esc>:w<CR>a", opts)

-- Format (VSCode formatOnSave)
map("n", "<leader>f", ":lua vim.lsp.buf.format()<CR>", opts)

-- LazyGit (open in floating window)
map("n", "<leader>g", ":LazyGit<CR>", opts)

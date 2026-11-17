-- Only overrides of LazyVim defaults live here.
vim.o.scrolloff = 8
vim.o.wrap = true
vim.o.foldenable = false

-- Dedicated Python host for remote plugins (Molten). Created by install/common.sh.
local nvim_python = vim.fn.stdpath("data") .. "/python/bin/python"
if vim.fn.executable(nvim_python) == 1 then
  vim.g.python3_host_prog = nvim_python
end

-- Unused remote-plugin hosts (silences :checkhealth warnings).
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

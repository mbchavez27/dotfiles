-- Language tweaks on top of the LazyVim extras in lazyvim.json.

-- Mason packages we deliberately do not download:
--   clangd   → use the Apple clangd at /usr/bin/clangd (Xcode CLT)
--   codelldb → C/C++/Rust debugger, ~120 MB. Delete it from this list to opt in.
local skip_mason = { clangd = true, codelldb = true }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = { mason = false },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(name)
        return not skip_mason[name]
      end, opts.ensure_installed or {})
    end,
  },
}

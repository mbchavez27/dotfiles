-- lua/plugins/mason.lua
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "typescript-language-server",
      "prettier",
      "eslint-lsp",
    },
  },
}

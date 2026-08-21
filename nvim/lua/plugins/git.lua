return {
  "kdheepak/lazygit.nvim",
  cmd = "LazyGit",
  config = function()
    require("lazygit").setup({
      float = { border = "rounded" },
    })
  end,
}

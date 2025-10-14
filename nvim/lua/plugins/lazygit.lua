return {
  "kdheepak/lazygit.nvim",
  cmd = "LazyGit", -- only load when :LazyGit is called
  config = function()
    -- Optional: floating window settings
    require("lazygit").setup({
      -- optional configuration
      float = { border = "rounded" },
    })
  end,
}

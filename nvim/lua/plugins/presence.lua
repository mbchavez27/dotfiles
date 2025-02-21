return {
  "andweeb/presence.nvim",
  config = function()
    require("presence").setup({
      -- Customize the settings here
      auto_update = true,
      neovim_image_text = "The One True Text Editor",
      main_image = "file", -- "neovim", "file", or "logo"
      enable_line_number = false,
    })
  end,
}

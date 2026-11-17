-- Activity tracking carried over from VS Code.
return {
  -- Discord Rich Presence. ":Cord update" fetches the prebuilt server binary.
  {
    "vyfor/cord.nvim",
    event = "VeryLazy",
    build = ":Cord update",
    opts = {
      editor = { tooltip = "Neovim" },
    },
  },
}

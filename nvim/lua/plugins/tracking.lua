-- Activity tracking carried over from VS Code.
return {
  -- WakaTime: first launch asks for the API key (wakatime.com/settings/api-key)
  -- and downloads wakatime-cli into ~/.wakatime/.
  { "wakatime/vim-wakatime", event = "VeryLazy" },

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

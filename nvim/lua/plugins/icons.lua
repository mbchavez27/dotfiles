return {
  -- Core devicons plugin (provides file icons for many plugins)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {
      override_by_extension = {
        ["js"] = { icon = "", color = "#f1e05a", name = "JavaScript" },
        ["ts"] = { icon = "", color = "#3178c6", name = "TypeScript" },
        ["jsx"] = { icon = "", color = "#61dafb", name = "ReactJS" },
        ["tsx"] = { icon = "", color = "#61dafb", name = "ReactTS" },
        ["json"] = { icon = "", color = "#cbcb41", name = "JSON" },
        ["html"] = { icon = "", color = "#e44d26", name = "HTML" },
        ["css"] = { icon = "", color = "#563d7c", name = "CSS" },
        ["py"] = { icon = "", color = "#3572A5", name = "Python" },
        ["java"] = { icon = "", color = "#b07219", name = "Java" },
        ["c"] = { icon = "", color = "#555555", name = "C" },
        ["cpp"] = { icon = "", color = "#f34b7d", name = "C++" },
        ["h"] = { icon = "", color = "#a074c4", name = "Header" },
        ["rs"] = { icon = "", color = "#dea584", name = "Rust" },
        ["go"] = { icon = "", color = "#00ADD8", name = "Go" },
        ["sh"] = { icon = "", color = "#89e051", name = "Shell" },
        ["lua"] = { icon = "", color = "#51a0cf", name = "Lua" },
        ["md"] = { icon = "", color = "#519aba", name = "Markdown" },
        ["yml"] = { icon = "", color = "#6d8086", name = "YAML" },
        ["toml"] = { icon = "", color = "#6d8086", name = "TOML" },
        ["lock"] = { icon = "", color = "#bbbbbb", name = "Lock" },
      },
    },
  },

  -- Optional: A plugin that mimics the *VSCode Icons theme*
  {
    "onsails/lspkind.nvim",
    event = "VeryLazy",
    config = function()
      require("lspkind").init({
        mode = "symbol_text",
        preset = "codicons", -- use VSCode codicons
        symbol_map = {
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰊕",
          Constructor = "",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "",
        },
      })
    end,
  },
}

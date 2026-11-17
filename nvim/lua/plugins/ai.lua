-- Terminal AI agents in a split via sidekick.nvim (LazyVim extra: ai.sidekick).
-- Keymaps come from the extra: <leader>aa toggle, <leader>as select CLI,
-- <leader>at send this, <leader>af send file, <leader>av send selection, <leader>ap prompts.
return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false }, -- next-edit suggestions need a Copilot subscription
      cli = {
        tools = {
          agy = { cmd = { "agy" } },
        },
      },
    },
    keys = {
      {
        "<leader>aD",
        function()
          require("sidekick.cli").send({ msg = "{diagnostics}" })
        end,
        desc = "Send Diagnostics",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Claude Code",
      },
      {
        "<leader>ao",
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end,
        desc = "opencode",
      },
    },
  },
}

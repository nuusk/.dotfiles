return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        anthropic = {
          api_key = vim.env.ANTHROPIC_KEY,
          model = "claude-sonnet-4-20250514",
        },
      },
      default_adapter = "anthropic",
    })
  end,
}

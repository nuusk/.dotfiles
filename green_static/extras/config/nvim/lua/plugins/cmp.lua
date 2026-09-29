return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
      preset = "default", -- or "enter" / "super-tab"
      ["<CR>"] = { "fallback" }, -- disable Enter acceptance
      ["<Tab>"] = { "select_and_accept", "fallback" },
    })
  end,
}

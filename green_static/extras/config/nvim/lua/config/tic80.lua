vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  callback = function()
    vim.fn.jobstart({ "make", "run" }, { detach = true })
  end,
})

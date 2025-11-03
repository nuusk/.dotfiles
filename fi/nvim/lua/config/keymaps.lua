-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>uh", function()
  local enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not enabled)
  print("Inlay hints " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle Inlay Hints" })

vim.keymap.set("n", "<leader>ff", function()
  local path = vim.fn.expand("%:p")
  print(path)
  vim.fn.setreg("+", path)
end, { desc = "Print current file path" })

-- TIC 80 start --
-- Run / Reload from anywhere in the project
vim.keymap.set("n", "<leader>tr", function()
  vim.fn.jobstart({ "make", "run" }, { detach = true })
end, { desc = "TIC-80: run cart" })

vim.keymap.set("n", "<leader>ts", function()
  vim.fn.jobstart({ "make", "save" }, { detach = true })
end, { desc = "TIC-80: save cart" })

vim.keymap.set("n", "<leader>tk", function()
  vim.fn.jobstart({ "make", "kill" }, { detach = true })
end, { desc = "TIC-80: kill running carts" })

-- TIC 80 end --

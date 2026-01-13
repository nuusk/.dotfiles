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

vim.keymap.set("n", "<leader>op", function()
  vim.cmd("enew")
  vim.cmd("put +")
  vim.cmd("normal! gg")
end, { desc = "Open new buffer with system clipboard contents" })

vim.keymap.set("n", "<leader>go", function()
  local line = vim.fn.line(".")
  local file = vim.fn.expand("%:.")

  local blame = vim
    .system({ "git", "blame", "-L", ("%d,%d"):format(line, line), "--porcelain", file }, { text = true })
    :wait()
  if blame.code ~= 0 then
    vim.notify("git blame failed:\n" .. (blame.stderr or ""), vim.log.levels.ERROR)
    return
  end

  vim.notify("git blame returned: " .. blame.stdout)

  local sha = (blame.stdout or ""):match("^(%w+)")
  if not sha or sha == "0000000000000000000000000000000000000000" then
    vim.notify("Could not get commit SHA for this line", vim.log.levels.ERROR)
    return
  end

  vim.notify("file: " .. file)

  local res = vim
    .system({ "gh", "browse", file, "--commit=" .. sha }, {
      text = true,
    })
    :wait()

  if res.code ~= 0 then
    vim.notify("gh failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
  end
end, { desc = "Open PR that introduced this line (Firefox)" })

vim.api.nvim_create_user_command("W", "w", { desc = "Save current file" })
vim.api.nvim_create_user_command("Wq", "wq", { desc = "Save and quit current file" })
vim.api.nvim_create_user_command("Q", "q", { desc = "Quit current file" })
vim.api.nvim_create_user_command("Qa", "qa", { desc = "Quit all files" })

-- Copy absolute path
vim.api.nvim_create_user_command("CopyAbsolutePath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Absolute path copied:\n" .. path, vim.log.levels.INFO, { title = "Copy Path" })
end, { desc = "Copy absolute path of current file" })

-- Copy relative path
vim.api.nvim_create_user_command("CopyRelativePath", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify("Relative path copied:\n" .. path, vim.log.levels.INFO, { title = "Copy Path" })
end, { desc = "Copy relative path of current file" })

vim.api.nvim_create_user_command("NodeCurrentFile", function()
  local file_path = vim.fn.expand("%")
  vim.cmd("terminal node " .. vim.fn.fnameescape(file_path))
end, { desc = "Run current file on node" })

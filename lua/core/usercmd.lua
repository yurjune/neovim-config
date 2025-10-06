vim.api.nvim_create_user_command("W", "w", { desc = "Save current file" })
vim.api.nvim_create_user_command("Wq", "wq", { desc = "Save and quit current file" })
vim.api.nvim_create_user_command("WQ", "wq", { desc = "Save and quit current file" })

vim.api.nvim_create_user_command("Q", "q", { desc = "Quit current file" })
vim.api.nvim_create_user_command("Qa", "qa", { desc = "Quit all files" })
vim.api.nvim_create_user_command("QA", "qa", { desc = "Quit all files" })

vim.api.nvim_create_user_command("R", function()
  vim.cmd("restart")
end, { desc = "Restart Neovim" })

vim.api.nvim_create_user_command("NodeCurrentFile", function()
  local file_path = vim.fn.expand("%")
  vim.cmd("terminal node " .. vim.fn.fnameescape(file_path))
end, { desc = "Run current file on node" })

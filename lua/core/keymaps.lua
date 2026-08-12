vim.keymap.set("t", "<M-v>", [[<C-\><C-n>"+pi]]) -- for paste bug in sidekick terminal by <D-v> paste

vim.keymap.set("n", "<M-s>", "<cmd>w<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<M-a>", "ggVG", { desc = "Select all lines" })

vim.keymap.set("n", "<C-q>", "<C-6>", { desc = "Switch to last accessed buffer" })
vim.keymap.set("n", "<C-6>", "<Nop>")

vim.keymap.set("n", "<leader>rq", ":cexpr [] | cclose<CR>", { desc = "Reset and close quick-fix" })
vim.keymap.set("t", "<C-]>", [[<C-\><C-n>]], { noremap = true, desc = "change to normal mode" })

vim.keymap.set("n", "gh", function()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(windows) do
    local config = vim.api.nvim_win_get_config(win)
    -- Check if the window is a floating window, since normal windows won't have a relative property
    if config.relative ~= "" then
      vim.api.nvim_set_current_win(win)
    end
  end
end, { desc = "Focus on floating window" })

vim.keymap.set("n", "'", "`", { noremap = true, desc = "Jump to exact mark position" })

vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copy Relative Path" })
end, { desc = "Copy relative path of current file" })

vim.keymap.set("n", "<leader>cP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copy Absolute Path" })
end, { desc = "Copy absolute path of current file" })

local scrollbind_enabled = vim.wo.scrollbind
vim.keymap.set("n", "<leader>sb", function()
  scrollbind_enabled = not scrollbind_enabled

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)

    if vim.bo[buf].buftype == "" then
      vim.wo[win].scrollbind = scrollbind_enabled
    end
  end

  vim.notify(string.format("Scrollbind %s", scrollbind_enabled and "ENABLED" or "DISABLED"), vim.log.levels.INFO)
end, { desc = "Toggle synchronized scrolling acros all split windows" })

vim.keymap.set("n", "<leader>nn", function()
  vim.cmd("nohlsearch") -- aka noh
end, { desc = "Clear search highlight" })

vim.keymap.set("n", "<leader>ut", function()
  vim.cmd.packadd("nvim.undotree")
  vim.cmd.Undotree()
end, { desc = "Toggle undo tree" })

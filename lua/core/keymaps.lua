vim.keymap.set("n", "<M-s>", "<cmd>w<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<M-a>", "ggVG", { desc = "Select all lines" })

vim.keymap.set("n", "<C-q>", "<C-6>", { desc = "Switch to last accessed buffer" })
vim.keymap.set("n", "<C-6>", "<Nop>")

vim.keymap.set("n", "<leader>rq", ":cexpr [] | cclose<CR>", { desc = "Reset and close quick-fix" })
vim.keymap.set("t", "<C-]>", [[<C-\><C-n>]], { noremap = true, desc = "change to normal mode" })

vim.keymap.set("n", "<leader>[[", "<cmd>qa!<CR>", { desc = "Exit neovim by force" })

vim.keymap.set("n", "gh", function()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(windows) do
    local config = vim.api.nvim_win_get_config(win)
    -- Check if the window is a floating window, since normal windows won't have a relative property
    if config.relative ~= "" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end, { desc = "Focus on floating window" })

vim.keymap.set("n", "'", "`", { noremap = true, desc = "Go to last cursor position" })

-- Copy current file paths
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

local function notify_scrollbind(scope, enabled)
  vim.notify(string.format("%s scrollbind %s", scope, enabled and "ENABLED" or "DISABLED"), vim.log.levels.INFO)
end

-- Toggle synchronized scrolling across all split windows.
local scrollbind_enabled = vim.wo.scrollbind
vim.keymap.set("n", "<leader>sb", function()
  scrollbind_enabled = not scrollbind_enabled

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)

    if vim.bo[buf].buftype == "" then
      vim.wo[win].scrollbind = scrollbind_enabled
    end
  end

  notify_scrollbind("All windows", scrollbind_enabled)
end, { desc = "Toggle synchronized scrolling" })

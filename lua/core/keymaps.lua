vim.g.mapleader = " " -- bind spacebar to leader key

vim.keymap.set("n", "<leader>rq", ":cexpr [] | cclose<CR>", { desc = "Reset and close quick-fix" })
-- vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, desc = "change to normal mode" })

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

vim.keymap.set("n", "<leader>mc", function()
  vim.cmd("delmarks!")
  vim.notify("a-z marks in current buffer cleared", vim.log.levels.INFO)
end, { desc = "Clear a-z marks in current buffer" })

vim.keymap.set("n", "<leader>mC", function()
  vim.cmd("delmarks A-Z")
  vim.notify("A-Z marks cleared", vim.log.levels.INFO)
end, { desc = "Clear A-Z marks" })

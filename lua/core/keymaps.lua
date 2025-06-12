vim.g.mapleader = " " -- bind spacebar to leader key

-- Clipboard keymaps
vim.keymap.set("n", "<D-c>", '"+y')
vim.keymap.set("v", "<D-c>", '"+y')
vim.keymap.set("n", "<D-v>", '"+p')
vim.keymap.set("i", "<D-v>", "<c-r>+")
vim.keymap.set("c", "<D-v>", "<c-r>+")
vim.keymap.set("t", "<D-v>", [[<C-\><C-n>"+pi]])

-- Keymaps using command
vim.keymap.set("n", "<D-s>", "<cmd>w<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<M-s>", "<cmd>w<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<D-q>", "<cmd>q<CR>", { desc = "Quit current file" })
vim.keymap.set("n", "<M-q>", "<cmd>q<CR>", { desc = "Quit current file" })
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all lines" })
vim.keymap.set("n", "<M-a>", "ggVG", { desc = "Select all lines" })

vim.keymap.set("n", "<C-q>", "<C-6>", { desc = "Switch to last accessed buffer" })
vim.keymap.set("n", "<C-6>", "<Nop>")

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

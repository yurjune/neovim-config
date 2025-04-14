vim.g.mapleader = " " -- bind spacebar to leader key

-- keymaps
local keymap = vim.keymap

keymap.set("n", "<leader>ram", function()
  vim.cmd("delmarks a-zA-Z0-9")
  vim.notify("All marks have been cleared", vim.log.levels.INFO, {
    title = "Alert",
  })
end, {
  desc = "Clear all marks",
})

keymap.set("n", "<leader>rab", ":%bd|e#<CR>", {
  desc = "Clear buffers except current buffer",
})

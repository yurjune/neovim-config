-- A plugin for seamless pane navigation
vim.pack.add({ "https://github.com/mrjones2014/smart-splits.nvim" })

vim.cmd.packadd("smart-splits.nvim")

local ss = require("smart-splits")

ss.setup({
  cursor_follows_swapped_bufs = true,
  at_edge = "wrap", -- 'wrap', 'stop', 'split'
  multiplexer_integration = nil, -- If nil, it will use the default multiplexer integration
})

vim.keymap.set({ "n", "t" }, "<M-h>", ss.move_cursor_left)
vim.keymap.set({ "n", "t" }, "<M-j>", ss.move_cursor_down)
vim.keymap.set({ "n", "t" }, "<M-k>", ss.move_cursor_up)
vim.keymap.set({ "n", "t" }, "<M-l>", ss.move_cursor_right)

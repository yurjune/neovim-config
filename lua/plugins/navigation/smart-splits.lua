-- A plugin for seamless pane navigation
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    local ss = require("smart-splits")

    ss.setup({
      move = {
        at_edge = "wrap", -- 'wrap', 'stop', 'split'
      },
      swap = {
        move_cursor = true,
      },
    })

    vim.keymap.set({ "n", "t" }, "<M-h>", ss.move_cursor_left)
    vim.keymap.set({ "n", "t" }, "<M-j>", ss.move_cursor_down)
    vim.keymap.set({ "n", "t" }, "<M-k>", ss.move_cursor_up)
    vim.keymap.set({ "n", "t" }, "<M-l>", ss.move_cursor_right)
  end,
}

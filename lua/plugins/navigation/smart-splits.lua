return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    local ss = require("smart-splits")

    ss.setup({
      cursor_follows_swapped_bufs = true,
      at_edge = "wrap", -- 'wrap', 'stop', 'split'
      multiplexer_integration = nil, -- If nil, it will use the default multiplexer integration
    })

    vim.keymap.set("n", "<D-h>", ss.move_cursor_left)
    vim.keymap.set("n", "<D-j>", ss.move_cursor_down)
    vim.keymap.set("n", "<D-k>", ss.move_cursor_up)
    vim.keymap.set("n", "<D-l>", ss.move_cursor_right)

    vim.keymap.set("n", "<M-h>", ss.move_cursor_left)
    vim.keymap.set("n", "<M-j>", ss.move_cursor_down)
    vim.keymap.set("n", "<M-k>", ss.move_cursor_up)
    vim.keymap.set("n", "<M-l>", ss.move_cursor_right)
  end,
}

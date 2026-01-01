-- Database Client for NeoVim
-- Connection: "~/.local/state/nvim/dbee/persistence.json"

vim.pack.add({
  "https://github.com/kndndrj/nvim-dbee",
  "https://github.com/MunifTanjim/nui.nvim",
})
vim.cmd.packadd("nvim-dbee")
vim.cmd.packadd("nui.nvim")

require("dbee").install()

require("dbee").setup({
  drawer = {
    mappings = {
      -- manually refresh drawer
      { key = "r", mode = "n", action = "refresh" },
      { key = "<Tab>", mode = "n", action = "toggle" },

      -- actions perform different stuff depending on the node:
      -- action_1 opens a note or executes a helper
      { key = "o", mode = "n", action = "action_1" },
      { key = "<CR>", mode = "n", action = "action_1" },
      -- action_2 renames a note or sets the connection as active manually
      { key = "cw", mode = "n", action = "action_2" },
      -- action_3 deletes a note or connection (removes connection from the file if you configured it like so)
      { key = "dd", mode = "n", action = "action_3" },

      -- mappings for menu popups:
      { key = "o", mode = "n", action = "menu_confirm" },
      { key = "<CR>", mode = "n", action = "menu_confirm" },
      { key = "y", mode = "n", action = "menu_yank" },
      { key = "<Esc>", mode = "n", action = "menu_close" },
      { key = "q", mode = "n", action = "menu_close" },
    },
  },
})

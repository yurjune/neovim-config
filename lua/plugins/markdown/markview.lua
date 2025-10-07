return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  enabled = true,
  config = function(_, opts)
    local markview = require("markview")
    markview.setup(opts)

    vim.keymap.set("n", "<leader>mt", "<cmd>Markview toggle<cr>", { desc = "Toggle markdown preview" })
  end,
}

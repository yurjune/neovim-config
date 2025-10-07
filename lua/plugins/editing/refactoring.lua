return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  config = function()
    local rf = require("refactoring")

    vim.keymap.set({ "n", "x" }, "<leader>rr", function()
      require("telescope").extensions.refactoring.refactors()
    end, { desc = "Refactoring" })

    -- For Debuggings
    vim.keymap.set("n", "<leader>pf", rf.debug.printf, { desc = "Insert printf debug statement" })
    vim.keymap.set({ "n", "x" }, "<leader>pv", rf.debug.print_var, { desc = "Print variable under cursor" })

    vim.keymap.set("n", "<leader>pc", rf.debug.cleanup, { desc = "Clear logs for debug" })
  end,
}

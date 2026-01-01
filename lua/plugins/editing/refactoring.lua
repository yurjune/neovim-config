vim.pack.add({
  "https://github.com/ThePrimeagen/refactoring.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
})
vim.cmd.packadd("refactoring.nvim")
vim.cmd.packadd("plenary.nvim")
vim.cmd.packadd("nvim-treesitter")

local rf = require("refactoring")

vim.keymap.set({ "n", "x" }, "<leader>rr", function()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("telescope.nvim is not available", vim.log.levels.WARN)
    return
  end
  telescope.extensions.refactoring.refactors()
end, { desc = "Refactoring" })

-- For Debuggings
vim.keymap.set("n", "<leader>pf", rf.debug.printf, { desc = "Insert printf debug statement" })
vim.keymap.set({ "n", "x" }, "<leader>pv", rf.debug.print_var, { desc = "Print variable under cursor" })

vim.keymap.set("n", "<leader>pc", rf.debug.cleanup, { desc = "Clear logs for debug" })

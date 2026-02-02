-- A plugin that expands current window
return {
  "szw/vim-maximizer",
  event = "VeryLazy",
  config = function()
    vim.keymap.set("n", "<leader>wm", "<cmd>MaximizerToggle!<CR>", { desc = "Maximize window fully" })
  end,
}

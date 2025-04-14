-- A plugin to focus on current window
return {
  "szw/vim-maximizer",
  keys = {
    { "<leader>mw", "<cmd>MaximizerToggle<CR>", desc = "Maximize current window" },
  },
}

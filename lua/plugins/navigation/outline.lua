return {
  "hedyhli/outline.nvim",
  config = function()
    vim.keymap.set("n", "<leader>oo", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

    require("outline").setup({})
  end,
}

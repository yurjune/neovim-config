-- A plugin to manage Git conflicts in Neovim
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("git-conflict").setup({
      default_mappings = true,
      -- default_mappings = {
      --   ours = "o",
      --   theirs = "t",
      --   none = "0",
      --   both = "b",
      --   next = "n",
      --   prev = "p",
      -- },
      default_highlights = true,
      disable_diagnostics = false,
      debug = false,
      list_opener = "copen",
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    })

    vim.keymap.set("n", "<leader>gc", "<cmd>GitConflictListQf<CR>", { desc = "Git conflicts list" })
  end,
}

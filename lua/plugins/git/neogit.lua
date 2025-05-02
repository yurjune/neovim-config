return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "nvim-telescope/telescope.nvim", -- optional
  },
  config = function()
    local neogit = require("neogit")
    local keymap = vim.keymap

    neogit.setup({
      disable_commit_confirmation = true,
      disable_insert_on_commit = false,
      integrations = {
        diffview = true,
        telescope = true,
      },
    })

    keymap.set("n", "<leader>ng", "<cmd>Neogit<CR>", { desc = "Neogit" })
  end,
}

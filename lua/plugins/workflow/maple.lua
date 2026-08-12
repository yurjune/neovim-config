-- A plugin for quick memo
return {
  "forest-nvim/maple.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>mm", "<cmd>MapleToggle<CR>", desc = "Toggle Maple Notes" },
  },
  config = function()
    require("maple").setup({
      -- Appearance
      width = 0.6,
      height = 0.6,
      border = "rounded", -- Border style ('none', 'single', 'double', 'rounded', etc.)
      title = "NOTES",
      title_pos = "center",
      winblend = 0, -- Window transparency (0-100)

      -- Storage
      storage_path = vim.fn.stdpath("data") .. "/maple",

      -- Notes management
      notes_mode = "project", -- "global" or "project"
      use_project_specific_notes = true, -- Store notes by project
    })
  end,
}

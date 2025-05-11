-- A plugin for managing buffers and tabs
-- alternatives: incline.nvim
return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  after = "catppuccin",
  config = function()
    local bufferline = require("bufferline")

    bufferline.setup({
      options = {
        mode = "tabs", -- "tabs" | "buffers"
        separator_style = "thin", -- "slant" | "slope" | "thick" | "thin"
        max_name_length = 30,
      },
      highlights = require("catppuccin.groups.integrations.bufferline").get(),
    })

    vim.keymap.set("n", "<leader>bc", "<cmd>%bd|e#|bd#<CR>", { desc = "Clear buffers except current buffer" })
    vim.keymap.set("n", "<leader>bp", "<cmd>bp<CR>", { desc = "Go prev buffer" })
    vim.keymap.set("n", "<leader>bn", "<cmd>bn<CR>", { desc = "Go next buffer" })

    vim.keymap.set("n", "<leader>bd", function()
      bufferline.close_with_pick()
    end, { desc = "Pick a buffer to close" })

    for i = 1, 9 do
      vim.keymap.set("n", "<leader>b" .. i, function()
        bufferline.go_to(i, true)
      end, { desc = "Go to buffer " .. i })
    end
  end,
}

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
        diagnostics = "nvim_lsp",
        -- indcate error status on bufferline
        diagnostics_indicator = function(count)
          return "" .. count
        end,
      },
      highlights = require("catppuccin.groups.integrations.bufferline").get(),
    })

    vim.keymap.set("n", "<leader>bc", function()
      local current_buf = vim.api.nvim_get_current_buf()
      local buffers = vim.api.nvim_list_bufs()

      for _, buf in ipairs(buffers) do
        if buf ~= current_buf and vim.api.nvim_buf_get_option(buf, "filetype") ~= "NvimTree" then
          vim.api.nvim_buf_delete(buf, { force = false })
        end
      end
      vim.notify("Cleared all buffers.", vim.log.levels.INFO)
    end, { desc = "Clear buffers except current buffer and nvim-tree" })

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

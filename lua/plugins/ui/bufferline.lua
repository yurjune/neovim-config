-- A plugin for managing buffers and tabs
-- alternatives: incline.nvim
return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  after = "catppuccin",
  config = function()
    local bufferline = require("bufferline")
    local cat_palette = require("catppuccin.palettes").get_palette()
    local highlights = require("catppuccin.groups.integrations.bufferline").get()()
    highlights.buffer_selected = {
      fg = cat_palette.text,
      bold = true,
      italic = true,
    }

    bufferline.setup({
      options = {
        mode = "buffers", -- "tabs" | "buffers"
        separator_style = "thin", -- "slant" | "slope" | "thick" | "thin"
        sort_by = "insert_at_end",
        max_name_length = 30,
        diagnostics = "nvim_lsp",
        diagnostics_update_on_event = true,
        -- indcate error status on bufferline
        diagnostics_indicator = function(count)
          return "" .. count
        end,
      },
      highlights = highlights,
    })

    vim.keymap.set("n", "<D-S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to prev buffer" })
    vim.keymap.set("n", "<D-S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer" })
    vim.keymap.set("n", "<M-S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to prev buffer" })
    vim.keymap.set("n", "<M-S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer" })

    local function close_buffer()
      local current_buf = vim.api.nvim_get_current_buf()
      vim.cmd("bnext")
      vim.api.nvim_buf_delete(current_buf, { force = false })
    end
    vim.keymap.set("n", "<D-w>", close_buffer, { desc = "Delete current buffer and move to next buffer" })
    vim.keymap.set("n", "<M-w>", close_buffer, { desc = "Delete current buffer and move to next buffer" })

    local function close_all_buffers()
      bufferline.close_others()
      vim.notify("Cleared all buffers.", vim.log.levels.INFO)
    end
    vim.keymap.set("n", "<D-W>", close_all_buffers, { desc = "Clear buffers except current buffer and nvim-tree" })
    vim.keymap.set("n", "<M-W>", close_all_buffers, { desc = "Clear buffers except current buffer and nvim-tree" })

    vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer backward" })
    vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer forward" })

    vim.keymap.set("n", "<leader>bd", function()
      bufferline.close_with_pick()
    end, { desc = "Pick a buffer to close" })

    vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Buffer Pin/Unpin" })

    for i = 1, 9 do
      vim.keymap.set("n", "<C-" .. i .. ">", function()
        bufferline.go_to(i, true)
      end, { desc = "Go to buffer " .. i })
    end
  end,
}

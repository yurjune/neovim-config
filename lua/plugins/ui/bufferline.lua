-- A plugin for managing buffers and tabs
return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  after = "catppuccin",
  config = function()
    local bufferline = require("bufferline")
    local groups = require("bufferline.groups")

    -- NOTE: catppuccin dependency
    local highlights
    local ok, catppuccin = pcall(require, "catppuccin.special.bufferline")
    if ok then
      highlights = catppuccin.get_theme()()

      local colors = require("catppuccin.palettes").get_palette()
      highlights.buffer_selected = {
        fg = colors.text,
        bold = true,
        italic = true,
      }
    end

    bufferline.setup({
      options = {
        separator_style = "thin", -- "slant" | "slope" | "thick" | "thin"
        sort_by = "insert_at_end",
        max_name_length = 30,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = tostring, -- indcate error status on bufferline
      },
      highlights = highlights,
    })

    vim.keymap.set("n", "<M-H>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to prev buffer" })
    vim.keymap.set("n", "<M-L>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer" })

    local function close_buffer()
      local current_buf = vim.api.nvim_get_current_buf()
      if groups._is_pinned({ id = current_buf }) then
        vim.notify("Unpin the buffer before closing it.", vim.log.levels.WARN, { title = "bufferline.nvim" })
        return
      end

      vim.cmd("bnext")
      vim.api.nvim_buf_delete(current_buf, { force = false })
    end
    vim.keymap.set("n", "<M-w>", close_buffer, { desc = "Delete current buffer and move to next buffer" })

    local function close_all_buffers()
      local current_buf = vim.api.nvim_get_current_buf()
      local to_close = {}

      -- Keep both pinned buffers and the current buffer
      for _, element in ipairs(bufferline.get_elements().elements) do
        if element.id ~= current_buf and not groups._is_pinned(element) then
          table.insert(to_close, element.id)
        end
      end

      for _, bufnr in ipairs(to_close) do
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end

      vim.notify("Cleared all buffers.", vim.log.levels.INFO, { title = "bufferline.nvim" })
    end
    vim.keymap.set("n", "<M-W>", close_all_buffers, { desc = "Clear buffers except current and pinned buffers" })

    vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer backward" })
    vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer forward" })

    vim.keymap.set("n", "<leader>bd", function()
      bufferline.close_with_pick()
    end, { desc = "Pick a buffer to close" })

    vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Buffer Pin/Unpin" })
  end,
}

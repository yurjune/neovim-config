-- A plugin for creating and formatting tables.
local function format_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf, "markdown")
  if not parser then
    return
  end
  local root = parser:parse()[1]:root()
  local positions = {}

  local function collect(node)
    if node:type() == "pipe_table" then
      local row, col = node:start()
      positions[#positions + 1] = { row, col }
      return
    end

    for child in node:iter_children() do
      collect(child)
    end
  end

  collect(root)

  local utils = require("table-nvim.utils")
  local MdTable = require("table-nvim.md_table")

  for i = #positions, 1, -1 do
    local pos = positions[i]
    local node = vim.treesitter.get_node({ bufnr = buf, pos = pos })
    local table_root = utils.get_tbl_root(node)
    if table_root then
      local md_table = MdTable:new(table_root)
      local formatted = md_table:generate_rows()
      local current = vim.api.nvim_buf_get_lines(buf, md_table.start, md_table.end_, true)
      if not vim.deep_equal(current, formatted) then
        vim.api.nvim_buf_set_lines(buf, md_table.start, md_table.end_, true, formatted)
      end
    end
  end
end

local function clear_cell()
  local cell = vim.treesitter.get_node()
  while cell and cell:type() ~= "pipe_table_cell" do
    cell = cell:parent()
  end
  if not cell then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local text = vim.treesitter.get_node_text(cell, buf)
  if not text:find("%S") then
    return
  end

  local start_row, start_col, end_row, end_col = cell:range()
  local spaces = string.rep(" ", vim.fn.strwidth(text))
  vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, { spaces })
end

return {
  "SCJangra/table-nvim",
  ft = "markdown",
  config = function(_, opts)
    require("table-nvim").setup(opts)

    local function set_table_keymaps(buf)
      vim.keymap.set("n", "<leader>mf", format_buffer, {
        buffer = buf,
        desc = "Format tables in buffer",
      })
      vim.keymap.set("n", "<leader>md", clear_cell, {
        buffer = buf,
        desc = "Clear table cell",
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(event)
        set_table_keymaps(event.buf)
      end,
    })

    set_table_keymaps(vim.api.nvim_get_current_buf())
  end,
  opts = {
    padd_column_separators = true, -- Insert a space around column separators.
    mappings = {
      next = "<Tab>",
      prev = "<S-Tab>",

      move_row_up = "<leader>tk",
      move_row_down = "<leader>tj",
      insert_row_up = "<leader>tK",
      insert_row_down = "<leader>tJ",

      move_column_left = "<leader>th",
      move_column_right = "<leader>tl",
      insert_column_left = "<leader>tH",
      insert_column_right = "<leader>tL",

      insert_table = "<leader>tt",
      insert_table_alt = "<leader>tT",
      delete_column = "<leader>td",
    },
  },
}

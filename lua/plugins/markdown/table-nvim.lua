-- A plugin for creating and formatting tables.
return {
  "SCJangra/table-nvim",
  ft = "markdown",
  opts = {
    padd_column_separators = true, -- Insert a space around column separators.
    mappings = { -- next and prev work in Normal and Insert mode. All other mappings work in Normal mode.
      next = "<Nop>", -- Go to next cell.
      prev = "<Nop>", -- Go to previous cell.

      move_row_up = "<leader>tk", -- Move the current row up.
      move_row_down = "<leader>tj", -- Move the current row down.
      insert_row_up = "<leader>tK", -- Insert a row above the current row.
      insert_row_down = "<leader>tJ", -- Insert a row below the current row.

      move_column_left = "<leader>th", -- Move the current column to the left.
      move_column_right = "<leader>tl", -- Move the current column to the right.
      insert_column_left = "<leader>tH", -- Insert a column to the left of current column.
      insert_column_right = "<leader>tL", -- Insert a column to the right of current column.

      insert_table = "<leader>tt", -- Insert a new table.
      insert_table_alt = "<leader>tT", -- Insert a new table that is not surrounded by pipes.
      delete_column = "<leader>td", -- Delete the column under cursor.
    },
  },
}

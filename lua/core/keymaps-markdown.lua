-- Keymaps for bold, italic, strikethrough, and inline code in markdown files
-- This keymaps depends on custom mini.surround mapping: "Zsa" for add, "Zsd" for delete
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = ev.buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("v", "<leader>mb", function()
      vim.cmd("normal 2Zsa*")
    end, { desc = "Make bold current selection" })

    map("v", "<leader>ms", function()
      vim.cmd("normal 2Zsa~")
    end, { desc = "Make strikethrough current selection" })

    map("v", "<leader>mi", function()
      vim.cmd("normal Zsa*")
    end, { desc = "Make italic current selection" })

    map("v", "<leader>mc", function()
      vim.cmd("normal Zsa`")
    end, { desc = "Make inline codeblock current selection" })

    -- Bold the current word under the cursor
    -- If already bold, unbold the word under the cursor
    -- If you're in a multiline bold, it will unbold it only if you're on the first line
    map("n", "<leader>mb", function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_buffer = vim.api.nvim_get_current_buf()
      local start_row = cursor_pos[1] - 1
      local col = cursor_pos[2]
      -- Get the current line
      local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
      -- Check if the cursor is on an asterisk
      if line:sub(col + 1, col + 1):match("%*") then
        vim.notify("Cursor is on an asterisk, run inside the bold text", vim.log.levels.WARN, {
          title = "Markdown Keymaps",
        })
        return
      end

      -- Search for '**' to the left of the cursor position
      local left_text = line:sub(1, col)
      local marker_start = left_text:reverse():find("%*%*")
      if marker_start then
        marker_start = col - marker_start
      end
      -- Search for '**' to the right of the cursor position and in following lines
      local right_text = line:sub(col + 1)
      local marker_end = right_text:find("%*%*")
      local end_row = start_row
      while not marker_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
        end_row = end_row + 1
        local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
        if next_line == "" then
          break
        end
        right_text = right_text .. "\n" .. next_line
        marker_end = right_text:find("%*%*")
      end
      if marker_end then
        marker_end = col + marker_end
      end

      -- Remove '**' markers if found, otherwise bold the word
      if marker_start and marker_end then
        -- Extract lines
        local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
        local text = table.concat(text_lines, "\n")
        local new_text = text:sub(1, marker_start - 1)
          .. text:sub(marker_start + 2, marker_end - 1)
          .. text:sub(marker_end + 2)
        local new_lines = vim.split(new_text, "\n")
        -- Set new lines in buffer
        vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
      else
        -- Bold the word at the cursor position if no bold markers are found
        local before = line:sub(1, col)
        local after = line:sub(col + 1)
        local inside_surround = before:match("%*%*[^%*]*$") and after:match("^[^%*]*%*%*")
        if inside_surround then
          vim.cmd("normal Zsd*.")
        else
          vim.cmd("normal viw")
          vim.cmd("normal 2Zsa*")
        end
      end
    end, { desc = "Toggle bold markers" })

    map("n", "<leader>ms", function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_buffer = vim.api.nvim_get_current_buf()
      local start_row = cursor_pos[1] - 1
      local col = cursor_pos[2]
      local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
      if line:sub(col + 1, col + 1):match("~") then
        vim.notify("Cursor is on a tilde, run inside the strikethrough text", vim.log.levels.WARN, {
          title = "Markdown Keymaps",
        })
        return
      end

      local left_text = line:sub(1, col)
      local marker_start = left_text:reverse():find("~~")
      if marker_start then
        marker_start = col - marker_start
      end
      local right_text = line:sub(col + 1)
      local marker_end = right_text:find("~~")
      local end_row = start_row
      while not marker_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
        end_row = end_row + 1
        local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
        if next_line == "" then
          break
        end
        right_text = right_text .. "\n" .. next_line
        marker_end = right_text:find("~~")
      end
      if marker_end then
        marker_end = col + marker_end
      end

      if marker_start and marker_end then
        local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
        local text = table.concat(text_lines, "\n")
        local new_text = text:sub(1, marker_start - 1)
          .. text:sub(marker_start + 2, marker_end - 1)
          .. text:sub(marker_end + 2)
        local new_lines = vim.split(new_text, "\n")
        vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
      else
        local before = line:sub(1, col)
        local after = line:sub(col + 1)
        local inside_surround = before:match("~~[^~]*$") and after:match("^[^~]*~~")
        if inside_surround then
          vim.cmd("normal Zsd~.")
        else
          vim.cmd("normal viw")
          vim.cmd("normal 2Zsa~")
        end
      end
    end, { desc = "Toggle strikethrough markers" })

    map("n", "<leader>mi", function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_buffer = vim.api.nvim_get_current_buf()
      local start_row = cursor_pos[1] - 1
      local col = cursor_pos[2]
      local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
      if line:sub(col + 1, col + 1):match("%*") then
        vim.notify("Cursor is on an asterisk, run inside the italic text", vim.log.levels.WARN, {
          title = "Markdown Keymaps",
        })
        return
      end

      local left_text = line:sub(1, col)
      local markup_start = left_text:reverse():find("%*")
      if markup_start then
        markup_start = col - markup_start + 1
      end
      local right_text = line:sub(col + 1)
      local markup_end = right_text:find("%*")
      local end_row = start_row
      while not markup_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
        end_row = end_row + 1
        local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
        if next_line == "" then
          break
        end
        right_text = right_text .. "\n" .. next_line
        markup_end = right_text:find("%*")
      end

      if markup_end then
        markup_end = col + markup_end
      end
      if markup_start and markup_end then
        local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
        local text = table.concat(text_lines, "\n")
        local new_text = text:sub(1, markup_start - 1)
          .. text:sub(markup_start + 1, markup_end - 1)
          .. text:sub(markup_end + 1)
        local new_lines = vim.split(new_text, "\n")
        vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
      else
        local before = line:sub(1, col)
        local after = line:sub(col + 1)
        local inside_surround = before:match("%*[^%*]*$") and after:match("^[^%*]*%*")
        if inside_surround then
          vim.cmd("normal Zsd*")
        else
          vim.cmd("normal viw")
          vim.cmd("normal Zsa*")
        end
      end
    end, { desc = "Toggle italic markers" })

    map("n", "<leader>mc", function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_buffer = vim.api.nvim_get_current_buf()
      local start_row = cursor_pos[1] - 1
      local col = cursor_pos[2]
      local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
      if line:sub(col + 1, col + 1):match("`") then
        vim.notify("Cursor is on a backtick, run inside the code block text", vim.log.levels.WARN, {
          title = "Markdown Keymaps",
        })
        return
      end

      local left_text = line:sub(1, col)
      local marker_start = left_text:reverse():find("`")
      if marker_start then
        marker_start = col - marker_start + 1
      end
      local right_text = line:sub(col + 1)
      local marker_end = right_text:find("`")
      local end_row = start_row
      while not marker_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
        end_row = end_row + 1
        local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
        if next_line == "" then
          break
        end
        right_text = right_text .. "\n" .. next_line
        marker_end = right_text:find("`")
      end

      if marker_end then
        marker_end = col + marker_end
      end
      if marker_start and marker_end then
        local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
        local text = table.concat(text_lines, "\n")
        local new_text = text:sub(1, marker_start - 1)
          .. text:sub(marker_start + 1, marker_end - 1)
          .. text:sub(marker_end + 1)
        local new_lines = vim.split(new_text, "\n")
        vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
      else
        local before = line:sub(1, col)
        local after = line:sub(col + 1)
        local inside_surround = before:match("`[^`]*$") and after:match("^[^`]*`")
        if inside_surround then
          vim.cmd("normal Zsd`")
        else
          vim.cmd("normal viw")
          vim.cmd("normal Zsa`")
        end
      end
    end, { desc = "Toggle inline code block markers" })
  end,
})

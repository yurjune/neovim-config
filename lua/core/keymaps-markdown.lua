vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  desc = "Heading generate keymaps",
  callback = function(ev)
    local function set_heading(level)
      local line = vim.api.nvim_get_current_line()
      local heading_end = line:match("^#+%s+()")

      if level == 0 then
        if heading_end then
          vim.api.nvim_set_current_line(line:sub(heading_end))
        end
        return
      end

      local bullet_end = line:match("^%s*[-+*]%s+()")
      local content = line:sub(heading_end or bullet_end or 1)
      vim.api.nvim_set_current_line(string.rep("#", level) .. " " .. content)
    end

    local function heading_to_bullet()
      local line = vim.api.nvim_get_current_line()
      local heading_end = line:match("^#+%s+()")
      if heading_end then
        vim.api.nvim_set_current_line("- " .. line:sub(heading_end))
      end
    end

    vim.keymap.set("n", "<leader>hx", function()
      set_heading(0)
    end, {
      buffer = ev.buf,
      desc = "Remove heading",
    })

    vim.keymap.set("n", "<leader>hl", heading_to_bullet, {
      buffer = ev.buf,
      desc = "Convert heading to bullet",
    })

    for level = 1, 4 do
      -- ex) <leader>h3 generates "###"
      vim.keymap.set("n", "<leader>h" .. level, function()
        set_heading(level)
      end, {
        buffer = ev.buf,
        desc = ("Create level %d heading"):format(level),
      })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  desc = "Keymaps for bold, italic, strikethrough, and inline code in Markdown files",
  -- These keymaps depend on nvim-surround's default mappings: "S" for add, "ds" for delete
  callback = function(ev)
    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = ev.buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Find where the text starts after a Markdown list marker or task checkbox.
    local function get_list_content_col(line)
      local content_start = line:match("^%s*[-+*]%s+()")

      if not content_start then
        local number
        number, content_start = line:match("^%s*(%d+)[.)]%s+()")
        if number and #number > 9 then
          content_start = nil
        end
      end

      if not content_start then
        return nil
      end

      local task_content_start = line:sub(content_start):match("^%[[ xX]%]%s+()")
      if task_content_start then
        content_start = content_start + task_content_start - 1
      end

      return content_start - 1
    end

    local function add_surround(char, count)
      -- nvim-surround puts markers on separate lines for a linewise selection.
      -- Change it to a characterwise selection to keep Markdown markers inline.
      if vim.api.nvim_get_mode().mode == "V" then
        local anchor_row = vim.fn.getpos("v")[2]
        local cursor_row = vim.fn.line(".")
        local first_row = math.min(anchor_row, cursor_row)
        local last_row = math.max(anchor_row, cursor_row)

        vim.cmd.normal({ args = { vim.keycode("<Esc>") }, bang = true })
        local first_line = vim.api.nvim_buf_get_lines(0, first_row - 1, first_row, false)[1]
        local first_col = math.max(vim.fn.match(first_line, [[\S]]), 0)
        if first_row == last_row then
          first_col = get_list_content_col(first_line) or first_col
        end
        vim.api.nvim_win_set_cursor(0, { first_row, first_col })
        vim.cmd("normal! v")

        local last_line = vim.api.nvim_buf_get_lines(0, last_row - 1, last_row, false)[1]
        local last_col = math.max(vim.fn.match(last_line, [[\S\s*$]]), 0)
        vim.api.nvim_win_set_cursor(0, { last_row, last_col })
      end

      count = count or 1
      vim.cmd(("normal %dS%s"):format(count, char))
      vim.cmd(("normal! %dl"):format(count))
    end

    map("v", "<leader>mb", function()
      add_surround("*", 2)
    end, { desc = "Make bold current selection" })

    map("v", "<leader>ms", function()
      add_surround("~", 2)
    end, { desc = "Make strikethrough current selection" })

    map("v", "<leader>mi", function()
      add_surround("*")
    end, { desc = "Make italic current selection" })

    map("v", "<leader>mc", function()
      add_surround("`")
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
          vim.cmd("normal ds*.")
        else
          vim.cmd("normal viw")
          add_surround("*", 2)
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
          vim.cmd("normal ds~.")
        else
          vim.cmd("normal viw")
          add_surround("~", 2)
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
          vim.cmd("normal ds*")
        else
          vim.cmd("normal viw")
          add_surround("*")
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
          vim.cmd("normal ds`")
        else
          vim.cmd("normal viw")
          add_surround("`")
        end
      end
    end, { desc = "Toggle inline code block markers" })
  end,
})

-- These keymaps depend on nvim-surround's default visual mapping "S" for add
local M = {}

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

local function bold_keys(buf, first_row, last_row)
  local lines = vim.api.nvim_buf_get_lines(buf, first_row - 1, last_row, false)

  for index, line in ipairs(lines) do
    local prefix = line:match("^%s*[-+*]%s+") or line:match("^%s*%d+[.)]%s+") or line:match("^%s*")
    local content = line:sub(#prefix + 1)
    local key, separator, value = content:match("^([^:]-[^%s:])(%s*:%s*)(%S.*)$")
    if key and not key:match("^%*%*.*%*%*$") then
      lines[index] = prefix .. "**" .. key .. "**" .. separator .. value
    end
  end

  vim.api.nvim_buf_set_lines(buf, first_row - 1, last_row, false, lines)
end

-- Remove the markers surrounding the cursor, or add them to the word under it.
-- Inside a multiline emphasis it only unwraps when the cursor is on the first line.
local function toggle_marker(style)
  local char, count = style.char, style.count
  local marker = char:rep(count)

  local buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  local line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]

  if line:sub(col + 1, col + 1) == char then
    local message = ("Cursor is on %s, run inside the %s text"):format(style.char_name, style.name)
    vim.notify(message, vim.log.levels.WARN, { title = "Markdown Keymaps" })
    return
  end

  vim.treesitter.get_parser(buf, "markdown"):parse({ start_row, start_row + 1 })
  local node = vim.treesitter.get_node({ bufnr = buf, ignore_injections = false })
  while node do
    if node:type() == style.node then
      local row, first, last_row, last = node:range()
      if row == start_row and line:sub(first + 1, first + count) == marker then
        local text = vim.api.nvim_buf_get_text(buf, row, first, last_row, last, {})
        if char == "`" then
          marker = text[1]:match("^`+")
          count = #marker
        end
        if text[#text]:sub(-count) == marker then
          text[#text] = text[#text]:sub(1, -count - 1)
          text[1] = text[1]:sub(count + 1)
          vim.api.nvim_buf_set_text(buf, row, first, last_row, last, text)
          return
        end
      end
    end
    node = node:parent()
  end

  vim.cmd("normal viw")
  add_surround(char, count)
end

local STYLES = {
  { key = "b", node = "strong_emphasis", char = "*", count = 2, name = "bold", char_name = "an asterisk" },
  { key = "i", node = "emphasis", char = "*", count = 1, name = "italic", char_name = "an asterisk" },
  { key = "s", node = "strikethrough", char = "~", count = 2, name = "strikethrough", char_name = "a tilde" },
  { key = "c", node = "code_span", char = "`", count = 1, name = "inline code", char_name = "a backtick" },
}

function M.setup(buf)
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = buf
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  for _, style in ipairs(STYLES) do
    map("v", "<leader>m" .. style.key, function()
      add_surround(style.char, style.count)
    end, { desc = ("Make %s current selection"):format(style.name) })

    map("n", "<leader>m" .. style.key, function()
      toggle_marker(style)
    end, { desc = ("Toggle %s markers"):format(style.name) })
  end

  map("n", "<leader>mk", function()
    local row = vim.fn.line(".")
    bold_keys(buf, row, row)
  end, { desc = "Bold key on current line" })

  map("v", "<leader>mk", function()
    -- Apply to every line touched by the visual selection.
    local first_row = math.min(vim.fn.getpos("v")[2], vim.fn.line("."))
    local last_row = math.max(vim.fn.getpos("v")[2], vim.fn.line("."))
    vim.cmd.normal({ args = { vim.keycode("<Esc>") }, bang = true })
    bold_keys(buf, first_row, last_row)
  end, { desc = "Bold keys in selected key-value lines" })
end

return M

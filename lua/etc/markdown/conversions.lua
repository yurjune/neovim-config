local M = {}

local function convert_link()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local parser = vim.bo[buf].filetype == "markdown" and vim.treesitter.get_parser(buf, "markdown")
  if not parser then
    return
  end

  parser:parse({ row, row + 1 })
  local link = vim.treesitter.get_node({ bufnr = buf, ignore_injections = false })
  while link and link:type() ~= "inline_link" do
    link = link:parent()
  end

  if link then
    local start_row, start_col, end_row, end_col = link:range()
    local label = link:named_child(0)
    if start_row == end_row and col < end_col and label and label:type() == "link_text" then
      local _, label_end = label:end_()
      local line = vim.api.nvim_get_current_line()
      local destination = vim.trim(line:sub(label_end + 3, end_col - 1))
      if destination == "" then
        destination = "<>"
      end
      local reference = line:sub(start_col + 1, label_end + 1)
      local definition = reference .. ": " .. destination

      vim.api.nvim_buf_set_text(buf, row, label_end + 1, row, end_col, {})
      vim.fn.setreg("+", { "", definition }, "V")
      vim.notify(definition, vim.log.levels.INFO, { title = "Copy Markdown Link Definition" })
      return
    end
  end

  vim.notify("Place the cursor inside a single-line Markdown link", vim.log.levels.WARN)
end

function M.setup(buf)
  vim.keymap.set("n", "<leader>ml", convert_link, {
    buffer = buf,
    desc = "Convert Markdown link and copy its reference definition",
  })
end

return M

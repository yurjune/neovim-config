local mode = require("ui.mode")

local function update_cursor_line_number()
  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local mappings = {}

    for mapping in vim.wo[win].winhighlight:gmatch("[^,]+") do
      if not mapping:match("^CursorLineNr:") then
        table.insert(mappings, mapping)
      end
    end

    if win == current_win then
      table.insert(mappings, "CursorLineNr:" .. mode.get().highlight)
    end

    vim.wo[win].winhighlight = table.concat(mappings, ",")
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Visual", {
      bg = vim.g.colors_transparent.cursorline,
    })
    vim.api.nvim_set_hl(0, "CursorLine", {
      bg = "NONE",
    })
    vim.api.nvim_set_hl(0, "CursorLineNr", {
      fg = vim.g.colors.rose_beige,
    })
    vim.api.nvim_set_hl(0, "Folded", {
      bg = vim.g.colors_transparent.cursorline,
    })
  end,
})

vim.api.nvim_create_autocmd({ "ModeChanged", "WinEnter", "BufEnter" }, {
  callback = update_cursor_line_number,
})

update_cursor_line_number()

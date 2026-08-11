local mode = require("ui.mode")

vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.statusline = "%{%v:lua.get_statusline()%}"

local function setup_highlights()
  vim.api.nvim_set_hl(0, "StatusLineNC", {
    link = "Normal", -- hide inactivated window's statusline
  })
  vim.api.nvim_set_hl(0, "StatusLineLocation", {
    fg = vim.g.colors.white,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "StatusLineProgress", {
    fg = vim.g.colors.gold,
    bold = true,
  })
end

local function highlight(text, group)
  return "%#" .. group .. "#" .. text .. "%*"
end

local function get_mode()
  local mode_info = mode.get()
  local label = "-- " .. mode_info.label .. " --"

  return highlight(label, mode_info.highlight)
end

local function get_location()
  return string.format("%3d:%-2d", vim.fn.line("."), vim.fn.charcol("."))
end

local function get_progress()
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")

  if current_line == 1 then
    return "Top"
  elseif current_line == total_lines then
    return "Bot"
  end

  return string.format("%2d%%%%", math.floor(current_line / total_lines * 100))
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_highlights,
})

setup_highlights()

_G.get_statusline = function()
  local actual_win = tonumber(vim.g.actual_curwin)

  if actual_win and vim.api.nvim_get_current_win() ~= actual_win then
    return ""
  end

  return " "
    .. get_mode()
    .. "%="
    .. highlight(get_location(), "StatusLineLocation")
    .. " "
    .. highlight(get_progress(), "StatusLineProgress")
    .. " "
end

local severity = vim.diagnostic.severity
local sidebar_ft = require("ui.sidebar").filetype

local diagnostics = {
  { level = severity.ERROR, label = "E", highlight = "WinBarDiagnosticError" },
  { level = severity.WARN, label = "W", highlight = "WinBarDiagnosticWarn" },
  { level = severity.INFO, label = "I", highlight = "WinBarDiagnosticInfo" },
  { level = severity.HINT, label = "H", highlight = "WinBarDiagnosticHint" },
}

local modes = {
  n = { label = "NORMAL", highlight = "WinBarModeNormal", color = "#89b4fa" },
  i = { label = "INSERT", highlight = "WinBarModeInsert", color = "#a6e3a1" },
  c = { label = "COMMAND", highlight = "WinBarModeCommand", color = "#fab387" },
  t = { label = "TERMINAL", highlight = "WinBarModeTerminal", color = "#94e2d5" },
  v = { label = "VISUAL", highlight = "WinBarModeVisual", color = "#cba6f7" },
  b = { label = "V_BLOCK", highlight = "WinBarModeVisualBlock", color = "#f5c2e7" },
  r = { label = "REPLACE", highlight = "WinBarModeReplace", color = "#f38ba8" },
  s = { label = "SELECT", highlight = "WinBarModeSelect", color = "#b4befe" },
  ["?"] = { label = "?", highlight = "WinBarModeUnknown", color = "#7f849c" },
}

local function setup_highlights()
  vim.api.nvim_set_hl(0, "WinBar", {
    fg = vim.g.colors.white,
    bold = true,
    underline = false,
    undercurl = false,
  })
  vim.api.nvim_set_hl(0, "WinBarNC", {
    fg = "#7f849c",
    bold = true,
    underline = false,
    undercurl = false,
  })

  for _, mode in pairs(modes) do
    vim.api.nvim_set_hl(0, mode.highlight, {
      fg = mode.color,
      bold = true,
    })
  end

  vim.api.nvim_set_hl(0, "WinBarLocation", {
    fg = vim.g.colors.white,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "WinBarProgress", {
    fg = vim.g.colors.gold,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "WinBarModified", {
    fg = vim.g.colors.gold,
    bold = true,
  })

  for _, diagnostic in ipairs({ "Error", "Warn", "Info", "Hint" }) do
    local diagnostic_hl = vim.api.nvim_get_hl(0, {
      name = "Diagnostic" .. diagnostic,
      link = false,
    })

    vim.api.nvim_set_hl(0, "WinBarDiagnostic" .. diagnostic, {
      fg = diagnostic_hl.fg,
      bold = true,
      underline = false,
      undercurl = false,
    })
  end
end

local function highlight(text, group)
  return "%#" .. group .. "#" .. text .. "%*"
end

local function get_location()
  return string.format("%3d:%-2d", vim.fn.line("."), vim.fn.charcol("."))
end

local function get_mode()
  local mode = vim.fn.mode()

  if mode == "\22" then -- Ctrl-V: blockwise Visual
    mode = "b"
  elseif mode == "\19" then -- Ctrl-S: blockwise Select
    mode = "s"
  else
    mode = mode:lower()
  end

  local mode_info = modes[mode] or modes["?"]

  return highlight(mode_info.label, mode_info.highlight)
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

local function is_focused()
  local actual_curwin = tonumber(vim.g.actual_curwin)

  return actual_curwin == nil or actual_curwin == vim.api.nvim_get_current_win()
end

local function get_diagnostics()
  local counts = vim.diagnostic.count(0)
  local parts = {}
  local filename_highlight

  for _, diagnostic in ipairs(diagnostics) do
    local count = counts[diagnostic.level]

    if count and count > 0 then
      filename_highlight = filename_highlight or diagnostic.highlight
      table.insert(parts, " " .. highlight(diagnostic.label .. ":" .. count, diagnostic.highlight))
    end
  end

  return table.concat(parts), filename_highlight
end

local function get_filename(focused, diagnostic_highlight)
  local filename = vim.fn.expand("%:t")

  if not focused then
    return highlight(filename, "WinBarInactiveFilename")
  elseif diagnostic_highlight then
    return highlight(filename, diagnostic_highlight)
  end

  return filename
end

local function get_modified()
  return vim.bo.modified and (" " .. highlight("[+]", "WinBarModified")) or ""
end

local function get_left(focused)
  local diagnostic_parts, filename_highlight = get_diagnostics()

  return get_filename(focused, filename_highlight) .. diagnostic_parts .. get_modified()
end

local function get_right()
  return get_mode()
    .. " "
    .. highlight(get_location(), "WinBarLocation")
    .. " "
    .. highlight(get_progress(), "WinBarProgress")
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_highlights,
})

setup_highlights()

-- Show the current buffer's filename and diagnostic counts in the window bar.
_G.get_winbar = function()
  if vim.bo.filetype == sidebar_ft then
    return vim.fn.expand("%:t")
  end

  local focused = is_focused()
  local left = get_left(focused)

  if not focused then
    return left
  end

  return left .. "%=" .. get_right()
end

vim.opt.winbar = "%{%v:lua.get_winbar()%}"

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufModifiedSet" }, {
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

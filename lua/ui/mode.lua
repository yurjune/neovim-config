local M = {}

local modes = {
  n = { label = "NORMAL", highlight = "ModeNormal", color = "#89b4fa" },
  i = { label = "INSERT", highlight = "ModeInsert", color = "#a6e3a1" },
  c = { label = "COMMAND", highlight = "ModeCommand", color = "#fab387" },
  t = { label = "TERMINAL", highlight = "ModeTerminal", color = "#94e2d5" },
  v = { label = "VISUAL", highlight = "ModeVisual", color = "#cba6f7" },
  b = { label = "V_BLOCK", highlight = "ModeVisualBlock", color = "#f5c2e7" },
  r = { label = "REPLACE", highlight = "ModeReplace", color = "#f38ba8" },
  s = { label = "SELECT", highlight = "ModeSelect", color = "#b4befe" },
  ["?"] = { label = "?", highlight = "ModeUnknown", color = "#7f849c" },
}

function M.get()
  local current = vim.fn.mode()

  if current == "\22" then -- Ctrl-V: blockwise Visual
    current = "b"
  elseif current == "\19" then -- Ctrl-S: blockwise Select
    current = "s"
  else
    current = current:sub(1, 1):lower()
  end

  return modes[current] or modes["?"]
end

local function setup_highlights()
  for _, mode in pairs(modes) do
    vim.api.nvim_set_hl(0, mode.highlight, {
      fg = mode.color,
      bold = true,
    })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_highlights,
})

setup_highlights()

return M

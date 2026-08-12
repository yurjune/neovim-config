local severity = vim.diagnostic.severity
local diagnostics = {
  { level = severity.ERROR, label = "E", highlight = "WinBarDiagnosticError" },
  { level = severity.WARN, label = "W", highlight = "WinBarDiagnosticWarn" },
  { level = severity.INFO, label = "I", highlight = "WinBarDiagnosticInfo" },
  { level = severity.HINT, label = "H", highlight = "WinBarDiagnosticHint" },
}

local function setup_highlights()
  vim.api.nvim_set_hl(0, "WinBar", {
    fg = vim.g.colors.gold,
    bold = true,
    underline = false,
    undercurl = false,
  })
  vim.api.nvim_set_hl(0, "WinBarNC", {
    fg = vim.g.colors.gold,
    bold = true,
    underline = false,
    undercurl = false,
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

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_highlights,
})

setup_highlights()

-- Show the current buffer's filename and diagnostic counts in the window bar.
_G.get_winbar = function()
  local counts = vim.diagnostic.count(0)
  local filename = vim.fn.expand("%:t")
  local parts

  for _, diagnostic in ipairs(diagnostics) do
    local count = counts[diagnostic.level]
    local hl = diagnostic.highlight
    local label = diagnostic.label

    if count and count > 0 then
      parts = parts or { "%#" .. hl .. "#" .. filename .. "%*" }
      table.insert(parts, " %#" .. hl .. "#" .. label .. ":" .. count .. "%*")
    end
  end

  return table.concat(parts or { filename })
end

vim.opt.winbar = "%{%v:lua.get_winbar()%}"

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

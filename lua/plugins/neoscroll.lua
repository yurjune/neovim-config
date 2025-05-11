-- A plugin for smooth scrolling in Neovim
-- Slow in Iterm2, so recommend using ghostty
return {
  "karb94/neoscroll.nvim",
  opts = {
    mappings = {
      "<C-u>",
      "<C-d>",
      "<C-b>",
      "<C-f>",
      "<C-y>",
      "<C-e>",
      "zt",
      "zz",
      "zb",
    },
    duration_multiplier = 0.1, -- The duration of all animations will be multiplied by this factor
    hide_cursor = true, -- hide cursor while scrolling
    stop_eof = true, -- stop scorlling when the cursor reaches eof
    respect_scrolloff = false,
    cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further.
    easing = "linear",
    performance_mode = false,
    ignored_events = {
      "WinScrolled", -- window scrolled
      "CursorMoved", -- cursor moved
    },
  },
}

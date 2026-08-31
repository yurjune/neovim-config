-- A plugin for automatic bullet list management.

-- Turns the current line into a checkbox item.
-- If it's already a checkbox, does nothing (use <leader>bt to toggle it).
-- If it's a plain bullet (-, *, +), inserts a checkbox after the bullet marker.
-- Otherwise, prepends a new "- [ ] " bullet.
local function create_checkbox()
  local lnum = vim.fn.line(".")
  local line = vim.fn.getline(lnum)
  local markers = vim.g.bullets_checkbox_markers or " .oOX"

  local checkbox_regex = [[\v(^(\s*)([+\-\*] \[([]] .. markers .. [[ xX]?)\])(:?)(\s+))(.*)]]
  if vim.fn.match(line, checkbox_regex) ~= -1 then
    return
  end

  local std_match = vim.fn.matchlist(line, [[\v^(\s*)([+\-\*])(\s+)(.*)]])
  if #std_match > 0 then
    local leading, bullet, spacing, text = std_match[2], std_match[3], std_match[4], std_match[5]
    vim.fn.setline(lnum, leading .. bullet .. spacing .. "[ ] " .. text)
    return
  end

  local plain_match = vim.fn.matchlist(line, [[\v^(\s*)(.*)]])
  local leading, text = plain_match[2], plain_match[3]
  vim.fn.setline(lnum, leading .. "- [ ] " .. text)
end

return {
  "bullets-vim/bullets.vim",
  ft = { "markdown", "text" },
  enabled = true,
  keys = {
    { "<leader>bc", create_checkbox, mode = "n", desc = "create checkbox" },
    { "<leader>bt", "<Plug>(bullets-toggle-checkbox)", mode = "n", desc = "toggle checkbox" },
    { "<leader>br", "<Plug>(bullets-renumber)", mode = { "n", "v" }, desc = "renumber bullets" },
  },
  config = function()
    vim.g.bullets_enabled_file_types = {
      "markdown",
      "text",
    }

    vim.g.bullets_outline_levels = { "num", "abc", "num" }
    vim.g.bullets_enable_roman_list = 0 -- disable Roman numeral parsing: so c. continues as d.
    vim.g.bullets_auto_indent_after_colon = 1 -- if 1: apply indent on next line when bullet line ends with colon(:)
    vim.g.bullets_delete_last_bullet_if_empty = 1 -- remove bullet and indent when line break on empty bullet
    vim.g.bullets_renumber_on_change = 0 -- if 1: renumber ordered list bullet changes
    vim.g.bullets_nested_checkboxes = 0
  end,
}

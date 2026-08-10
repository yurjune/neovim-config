-- Choose a UI layout that fits the current Neovim window size.
-- The layout is selected by the number of available columns.
local layouts = {
  compact = {
    sidebar = { 12, 24, 36, 48, 60, 72 },
    sidekick = 55,
    toggleterm = {
      width = 160,
      height = 45,
    },
  },
  wide = {
    sidebar = { 20, 40, 60, 80, 100, 120 },
    sidekick = 70,
    toggleterm = {
      width = 180,
      height = 45,
    },
  },
}

local columns = vim.o.columns
local name

if columns < 200 then
  name = "compact"
else
  name = "wide"
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LayoutInfo",
  desc = "Show the current columns and layout",
  group = vim.api.nvim_create_augroup("layout-info", { clear = true }),
  callback = function()
    local text = ("vim.o.columns: %d\nlayout: %s"):format(vim.o.columns, name)
    vim.notify(text, vim.log.levels.INFO, { title = "Layout Info" })
  end,
})

vim.api.nvim_create_user_command("LayoutInfo", function()
  vim.api.nvim_exec_autocmds("User", { pattern = "LayoutInfo" })
end, { desc = "Show the current columns and layout" })

return layouts[name]

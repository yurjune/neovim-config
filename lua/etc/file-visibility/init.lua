local M = {}

M.ignore_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/etc/file-visibility/rules.ignore")

local visible_dotfiles = {}

for _, line in ipairs(vim.fn.readfile(M.ignore_file)) do
  local name = vim.trim(line):match("^!(%.[^/]+)/*$")
  if name then
    visible_dotfiles[name] = true
  end
end

function M.is_hidden_file(name)
  return vim.startswith(name, ".") and not visible_dotfiles[name]
end

return M

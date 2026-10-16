local M = {}

M.ignore_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/etc/file-visibility/rules.ignore")

return M

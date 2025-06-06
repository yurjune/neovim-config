vim.g.colors = {
  bg = "#282c34",
  pink = "#ffc2c2",
}

-- check leetcode.nvim arg option
vim.g.leetcode = vim.fn.argv(0, -1) == "leet" and true or false

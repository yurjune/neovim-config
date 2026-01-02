-- A plugin to autoclose and autorename html tag
vim.pack.add({
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/nvim-treesitter/nvim-treesitter",
})
vim.cmd.packadd("nvim-ts-autotag")
vim.cmd.packadd("nvim-treesitter")

require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = true, -- Auto close on trailing </
  },

  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
    ["html"] = {
      enable_close = true,
    },
  },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local themesource = "plugins.themes.catppuccin"

require("lazy").setup({
  { import = "plugins" },
  { import = themesource },
  { import = "plugins.lsp" },
  { import = "plugins.ui" },
  { import = "plugins.workflow" },
  { import = "plugins.git" },
  { import = "plugins.ai" },
  { import = "plugins.navigation" },
  { import = "plugins.editing" },
  { import = "plugins.markdown" },
  { import = "plugins.debug" },
  { import = "plugins.etc" },
}, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  rocks = { -- disable luarocks
    enabled = false,
  },
})

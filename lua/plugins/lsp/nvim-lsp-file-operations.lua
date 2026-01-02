-- A plugin that adds support for file operations using built-in LSP support.
-- nvim-tree does NOT automatically update code references on file or directory update, unless this plugin is used
vim.pack.add({
  {
    src = "https://github.com/antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
  },
})

vim.cmd.packadd("plenary.nvim")
vim.cmd.packadd("nvim-tree.lua")
vim.cmd.packadd("nvim-lsp-file-operations")

require("lsp-file-operations").setup({
  -- used to see debug logs in file `vim.fn.stdpath("cache") .. lsp-file-operations.log`
  debug = false,
  -- select which file operations to enable
  operations = {
    willRenameFiles = true,
    didRenameFiles = true,
    willCreateFiles = true,
    didCreateFiles = true,
    willDeleteFiles = true,
    didDeleteFiles = true,
  },
  -- how long to wait (in milliseconds) for file rename information before cancelling
  timeout_ms = 10000,
})

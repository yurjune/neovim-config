vim.pack.add({ "https://github.com/brenoprata10/nvim-highlight-colors" })

vim.cmd.packadd("nvim-highlight-colors")
require("nvim-highlight-colors").setup({
  ---@usage 'background'|'foreground'|'virtual'
  render = "background",

  virtual_symbol = "■",
  virtual_symbol_prefix = "",
  virtual_symbol_suffix = "",
  ---@usage 'inline'|'eol'|'eow'
  virtual_symbol_position = "inline",
})

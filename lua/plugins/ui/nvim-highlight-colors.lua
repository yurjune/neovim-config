-- A plugin that highlights color codes.
return {
  "brenoprata10/nvim-highlight-colors",
  event = "BufReadPost",
  config = function()
    require("nvim-highlight-colors").setup({
      ---@usage 'background'|'foreground'|'virtual'
      render = "background",

      virtual_symbol = "■",
      virtual_symbol_prefix = "",
      virtual_symbol_suffix = "",
      ---@usage 'inline'|'eol'|'eow'
      virtual_symbol_position = "inline",
    })
  end,
}

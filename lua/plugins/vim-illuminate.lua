return {
  "RRethy/vim-illuminate",
  event = "VeryLazy",
  config = function()
    require("illuminate").configure({
      delay = 100,
      under_cursor = true,
      min_count_to_highlight = 2,
      filetypes_denylist = {
        "alpha",
        "NvimTree",
        "TelescopePrompt",
        "help",
        "lspinfo",
        "mason",
        "notify",
      },
    })
  end,
}

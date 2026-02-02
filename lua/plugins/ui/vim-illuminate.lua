-- A plugin that highlights references to the word under the cursor.
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
        "markdown",
      },
    })

    -- 즉시 설정
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", {
      bg = "NONE",
      underline = true,
    })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {
      bg = "NONE",
      underline = true,
    })
    vim.api.nvim_set_hl(0, "IlluminatedWordText", {
      bg = "NONE",
      underline = true,
    })
  end,
}

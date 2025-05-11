return {
  "supermaven-inc/supermaven-nvim",
  enabled = false,
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<S-CR>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { cpp = true }, -- or { "cpp", }
      color = {
        -- suggestion_color = ""
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    })
  end,
}

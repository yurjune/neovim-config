-- Scroll animation plugin
return {
  "psliwka/vim-smoothie",
  config = function()
    vim.g.smoothie_enabled = vim.g.neovide and 0 or 1

    vim.g.smoothie_speed_exponentiation_factor = 1 -- if 1, linear easing
    vim.g.smoothie_update_interval = 5
    vim.g.smoothie_base_speed = 30
    vim.g.smoothie_speed_constant_factor = 50
    vim.g.smoothie_speed_linear_factor = 50
  end,
}

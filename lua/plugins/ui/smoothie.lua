-- Scroll animation plugin
return {
  "psliwka/vim-smoothie",
  cond = function()
    return not vim.g.neovide
  end,
  config = function()
    vim.g.smoothie_enabled = 1
    vim.g.smoothie_update_interval = 10 -- update screen every n(ms), default 20

    -- ex) total_time = constant_factor + (linear_factor * distance)
    vim.g.smoothie_speed_constant_factor = 20 -- default 10
    vim.g.smoothie_speed_linear_factor = 20 -- default 10

    -- Generally should be less or equal to 1.0. (1.0 = linear easing)
    -- Lower values produce longer but perceivably smoother animation.
    vim.g.smoothie_speed_exponentiation_factor = 0.9 -- default 0.9
  end,
}

if vim.g.neovide then
  vim.opt.linespace = 4
  -- pass markdown_mode variable to neovide with zshrc alias
  -- zshrc alias: alias nvmd="neovide -- --cmd 'let g:markdown_mode = 1'"
  if vim.g.markdown_mode == 1 then
    vim.opt.linespace = 8
  end

  vim.opt.guifont = "JetBrainsMono NF Medium:h11"

  vim.g.neovide_opacity = 1
  vim.g.neovide_normal_opacity = 1
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_shadow = false

  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_underline_stroke_scale = 2.0
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_hide_mouse_when_typing = false
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"
  vim.g.neovide_input_ime = true

  vim.g.neovide_position_animation_length = 0.15
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_scroll_animation_far_lines = 0 -- check working

  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_animation_length = 0.07 -- default 0.15
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
end

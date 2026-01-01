-- A plugin for rendering images in Neovim
-- For tmux, add following option to .tmux.conf:
-- set -g allow-passthrough on

if not vim.g.leetcode then
  return
end

vim.pack.add({
  "https://github.com/3rd/image.nvim",
})
vim.cmd.packadd("image.nvim")

require("image").setup({
  backend = "kitty",
  -- brew install imagemagick
  processor = "magick_cli", -- ImageMagick
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      only_render_image_at_cursor_mode = "popup",
      floating_windows = false, -- if true, images will be rendered in floating markdown windows
      filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
    },
  },
})

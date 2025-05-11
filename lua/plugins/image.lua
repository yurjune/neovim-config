-- A plugin for rendering images in Neovim
return {
  "3rd/image.nvim",
  event = "VeryLazy",
  build = false,
  opts = {
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
  },
}

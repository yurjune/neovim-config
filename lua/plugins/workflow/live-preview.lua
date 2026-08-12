return {
  "brianhuster/live-preview.nvim",
  dependencies = {
    "ibhagwan/fzf-lua",
  },
  config = function()
    require("livepreview.config").set({
      port = 5500,
      browser = "default",
      dynamic_root = false,
      sync_scroll = true,
      picker = "fzf-lua",
      address = "127.0.0.1",
    })
  end,
}

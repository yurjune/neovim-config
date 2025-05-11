return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local rm = require("render-markdown")
    require("render-markdown").setup({
      enabled = true,
      render_modes = { "n", "c", "t", "i", "v", "V" },
      completions = {
        lsp = { enabled = true },
      },
      heading = {
        position = "inline",
      },
      pipe_table = {
        enabled = false,
        preset = "none",
        padding = 2,
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        vim.keymap.set(
          "n",
          "<leader>mt",
          rm.buf_toggle,
          { desc = "Markdown render toggle", buffer = ev.buf, noremap = true }
        )
      end,
    })
  end,
}

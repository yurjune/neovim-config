return {
  "opdavies/toggle-checkbox.nvim",
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        local M = require("toggle-checkbox")
        vim.keymap.set("n", "<leader>mk", M.toggle, { desc = "Toggle checkbox", buffer = ev.buf })
      end,
    })
  end,
}

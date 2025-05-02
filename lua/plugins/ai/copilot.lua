-- one you install, execute :Copilot setup
return {
  "github/copilot.vim",
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.keymap.set("i", "<S-CR>", function()
      return vim.fn["copilot#Accept"]("")
    end, {
      expr = true,
      silent = true,
      replace_keycodes = false,
    })
  end,
}

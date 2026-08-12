-- A plugin for automatic bullet list management.
return {
  "bullets-vim/bullets.vim",
  ft = { "markdown", "text" },
  enabled = true,
  keys = {
    { "<leader>bt", "<Plug>(bullets-toggle-checkbox)", mode = "n", desc = "toggle checkbox" },
    { "<leader>br", "<Plug>(bullets-renumber)", mode = { "n", "v" }, desc = "renumber bullets" },
  },
  config = function()
    vim.g.bullets_enabled_file_types = {
      "markdown",
      "text",
    }

    vim.g.bullets_outline_levels = { "num", "abc", "rom", "num" }
    vim.g.bullets_auto_indent_after_colon = 1 -- if 1: apply indent on next line when bullet line ends with colon(:)
    vim.g.bullets_delete_last_bullet_if_empty = 1 -- remove bullet and indent when line break on empty bullet
    vim.g.bullets_renumber_on_change = 0 -- if 1: renumber ordered list bullet changes
    vim.g.bullets_nested_checkboxes = 0
  end,
}

-- A plugin to improve basic UI of neovim
-- integrates with plugins which use vim.ui.input, vim.ui.select
return {
  "stevearc/dressing.nvim",
  opts = {
    -- fzf-lua owns vim.ui.select; keep Dressing only for vim.ui.input.
    select = {
      enabled = false,
    },
  },
  config = function(_, opts)
    require("dressing").setup(opts)
    require("fzf-lua").register_ui_select({})
  end,
}

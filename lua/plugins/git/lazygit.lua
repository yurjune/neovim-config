-- A plugin that provides a Git TUI interface.
-- need to install lazygit: brew install jesseduffield/lazygit/lazygit
return {
  "kdheepak/lazygit.nvim",
  init = function()
    vim.g.lazygit_floating_window_scaling_factor = 0.9
  end,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
  },
}

return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    -- remove D-h keymap in MacOS first
    { "<D-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<D-j>", "<cmd>TmuxNavigateDown<cr>" },
    { "<D-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<D-l>", "<cmd>TmuxNavigateRight<cr>" },
  },
}

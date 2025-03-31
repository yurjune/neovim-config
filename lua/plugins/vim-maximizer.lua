-- 현재 사용중인 window 를 임시로 최대화
return {
  "szw/vim-maximizer",
  keys = {
    { "<leader>ms", "<cmd>MaximizerToggle<CR>", desc = "Maximize a split" },
  },
}

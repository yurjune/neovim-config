return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  config = function()
    local rf = require("refactoring")

    vim.keymap.set({ "n", "x" }, "<leader>rr", function()
      require("telescope").extensions.refactoring.refactors()
    end, { desc = "Refactoring" })
    --
    -- -- 기본 리팩토링 명령어
    -- vim.keymap.set("n", "<leader>ri", ":Refactor inline_var<CR>", { desc = "변수 인라인화" })
    -- vim.keymap.set("n", "<leader>re", ":Refactor extract<CR>", { desc = "표현식 추출" })
    -- vim.keymap.set("n", "<leader>rf", ":Refactor extract_to_file<CR>", { desc = "파일로 추출" })
    -- vim.keymap.set("n", "<leader>rv", ":Refactor extract_var<CR>", { desc = "변수 추출" })
    --
    -- -- 시각적 모드에서 사용할 리팩토링 명령어
    -- vim.keymap.set("v", "<leader>re", ":Refactor extract<CR>", { desc = "시각적 선택 추출" })
    -- vim.keymap.set("v", "<leader>rv", ":Refactor extract_var<CR>", { desc = "시각적 변수 추출" })
    -- vim.keymap.set("v", "<leader>rf", ":Refactor extract_to_file<CR>", { desc = "시각적 파일로 추출" })
    --
    -- -- 함수 관련 리팩토링
    -- vim.keymap.set("n", "<leader>rb", ":Refactor extract_block<CR>", { desc = "블록 추출" })
    -- vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file<CR>", { desc = "블록을 파일로 추출" })
    --
    -- -- 함수 수준 리팩토링
    -- vim.keymap.set("n", "<leader>rif", ":Refactor inline_func<CR>", { desc = "함수 인라인화" })
    -- -- vim.keymap.set("n", "<leader>rp", ":Refactor param_change<CR>", { desc = "매개변수 변경" })

    -- For Debuggings
    vim.keymap.set("n", "<leader>pf", rf.debug.printf, { desc = "Insert printf debug statement" })
    vim.keymap.set({ "n", "x" }, "<leader>pv", rf.debug.print_var, { desc = "Print variable under cursor" })

    vim.keymap.set("n", "<leader>pc", rf.debug.cleanup, { desc = "Clear logs for debug" })
  end,
}

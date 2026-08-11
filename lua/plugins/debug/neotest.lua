-- A framework for interacting with tests within NeoVim
-- disabled by default since its test results are not accurate
local test_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

return {
  "nvim-neotest/neotest",
  -- disabled since it's test results are not accurate
  enabled = false,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
  },
  ft = test_filetypes,
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-jest"),
      },
    })
  end,
  keys = {
    {
      "<leader>tr",
      "<cmd>lua require('neotest').run.run()<cr>",
      desc = "Run nearest test",
      ft = test_filetypes,
    },
    {
      "<leader>tf",
      "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>",
      desc = "Run all tests in file",
      ft = test_filetypes,
    },
    {
      "<leader>tl",
      "<cmd>lua require('neotest').run.run_last()<cr>",
      desc = "Run last test",
      ft = test_filetypes,
    },
    {
      "<leader>ta",
      "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<cr>",
      desc = "Run all tests in project",
      ft = test_filetypes,
    },
    {
      "<leader>ts",
      "<cmd>lua require('neotest').run.stop()<cr>",
      desc = "Stop running test",
      ft = test_filetypes,
    },
    {
      "<leader>tt",
      "<cmd>lua require('neotest').summary.open()<cr>",
      desc = "Display summary",
      ft = test_filetypes,
    },
    {
      "<leader>too",
      "<cmd>lua require('neotest').output.open()<cr>",
      desc = "Display output float",
      ft = test_filetypes,
    },
    {
      "<leader>top",
      "<cmd>lua require('neotest').output_panel.open()<cr>",
      desc = "Display output panel",
      ft = test_filetypes,
    },
    {
      "<leader>toc",
      "<cmd>lua require('neotest').output_panel.clear()<cr>",
      desc = "Clear output",
      ft = test_filetypes,
    },
    {
      "<leader>tmr",
      "<cmd>lua require('neotest').summary.run_marked()<cr>",
      desc = "Run marked tests",
      ft = "neotest-summary",
    },
    {
      "<leader>tmc",
      "<cmd>lua require('neotest').summary.clear_marked()<cr>",
      desc = "Clear marked tests",
      ft = "neotest-summary",
    },
    {
      "<leader>tw",
      "<cmd>lua require('neotest').watch.watch()<cr>",
      desc = "Start watching tests",
      ft = test_filetypes,
    },
    {
      "<leader>twc",
      "<cmd>lua require('neotest').watch.stop()<cr>",
      desc = "Stop watching tests",
      ft = test_filetypes,
    },
  },
}

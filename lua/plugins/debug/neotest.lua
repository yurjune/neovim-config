return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
  },
  event = "VeryLazy",
  config = function()
    local neotest = require("neotest")

    ---@diagnostic disable-next-line: missing-fields
    neotest.setup({
      adapters = {
        require("neotest-jest"),
      },
    })

    vim.keymap.set("n", "<leader>tr", neotest.run.run, { desc = "Run nearest test" })

    vim.keymap.set("n", "<leader>tf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Run all tests in file" })

    vim.keymap.set("n", "<leader>tl", neotest.run.run_last, { desc = "Run last test" })

    vim.keymap.set("n", "<leader>ts", neotest.run.stop, { desc = "Stop running test" })

    -- vim.keymap.set("n", "<leader>ta", function()
    --   neotest.run.run(vim.fn.getcwd())
    -- end, { desc = "Run all tests in project" })
    --
    -- vim.keymap.set("n", "<leader>td", function()
    --   neotest.run.run({
    --     strategy = "dap",
    --     suite = true, -- if true, it will run the whole suite, otherwise it will run the nearest test
    --   })
    -- end, { desc = "Debug test" })

    vim.keymap.set("n", "<leader>tt", neotest.summary.open, { desc = "Display summary" })
    vim.keymap.set("n", "<leader>too", neotest.output.open, { desc = "Display output float" })
    vim.keymap.set("n", "<leader>top", neotest.output_panel.open, { desc = "Display output panel" })
    vim.keymap.set("n", "<leader>toc", neotest.output_panel.clear, { desc = "Clear output" })

    -- mark test by using `m` in summary view
    vim.keymap.set("n", "<leader>tmr", neotest.summary.run_marked, { desc = "Run marked tests" })
    vim.keymap.set("n", "<leader>tmc", neotest.summary.clear_marked, { desc = "Clear marked tests" })

    -- watch test by using `w` in summary view
    vim.keymap.set("n", "<leader>tw", neotest.watch.watch, { desc = "Start watching tests" })
    vim.keymap.set("n", "<leader>twc", neotest.watch.stop, { desc = "Stop watching tests" })
  end,
}

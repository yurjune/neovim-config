-- A framework for interacting with tests within NeoVim
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
  event = "VeryLazy",
  config = function()
    local neotest = require("neotest")

    ---@diagnostic disable-next-line: missing-fields
    neotest.setup({
      adapters = {
        require("neotest-jest"),
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        if vim.bo[args.buf].filetype == "markdown" then
          return
        end

        vim.keymap.set("n", "<leader>tr", neotest.run.run, { desc = "Run nearest test", buffer = args.buf })
        vim.keymap.set("n", "<leader>tf", function()
          neotest.run.run(vim.fn.expand("%"))
        end, { desc = "Run all tests in file", buffer = args.buf })

        vim.keymap.set("n", "<leader>tl", neotest.run.run_last, { desc = "Run last test", buffer = args.buf })
        vim.keymap.set("n", "<leader>ta", function()
          neotest.run.run(vim.fn.getcwd())
        end, { desc = "Run all tests in project" })

        vim.keymap.set("n", "<leader>ts", neotest.run.stop, { desc = "Stop running test", buffer = args.buf })

        vim.keymap.set("n", "<leader>tt", neotest.summary.open, { desc = "Display summary", buffer = args.buf })
        vim.keymap.set("n", "<leader>too", neotest.output.open, { desc = "Display output float", buffer = args.buf })
        vim.keymap.set(
          "n",
          "<leader>top",
          neotest.output_panel.open,
          { desc = "Display output panel", buffer = args.buf }
        )
        vim.keymap.set("n", "<leader>toc", neotest.output_panel.clear, { desc = "Clear output", buffer = args.buf })

        -- mark test by using `m` in summary view
        vim.keymap.set("n", "<leader>tmr", neotest.summary.run_marked, { desc = "Run marked tests", buffer = args.buf })
        vim.keymap.set(
          "n",
          "<leader>tmc",
          neotest.summary.clear_marked,
          { desc = "Clear marked tests", buffer = args.buf }
        )

        -- watch test by using `w` in summary view
        vim.keymap.set("n", "<leader>tw", neotest.watch.watch, { desc = "Start watching tests", buffer = args.buf })
        vim.keymap.set("n", "<leader>twc", neotest.watch.stop, { desc = "Stop watching tests", buffer = args.buf })
      end,
    })
  end,
}

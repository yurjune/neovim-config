return {
  "kawre/leetcode.nvim",
  -- build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    arg = "leet",
    lang = "python3",
    plugins = {
      non_standalone = false,
    },
    logging = true,
    injector = {},
    console = {
      open_on_runcode = true,
      dir = "row",
      size = {
        width = "90%",
        height = "75%",
      },
      result = {
        size = "60%",
      },
      testcase = {
        virt_text = true,
        size = "40%",
      },
    },
    description = {
      position = "left",
      width = "40%",
      show_stats = true,
    },
    picker = {
      provider = nil,
    },
    keys = {
      toggle = { "q" },
      confirm = { "<CR>" },
      reset_testcases = "r",
      use_testcase = "U",
      focus_testcases = "H",
      focus_result = "L",
    },
    theme = {},
    image_support = true,
  },

  config = function(_, opts)
    require("leetcode").setup(opts)

    vim.keymap.set("n", "<leader>lr", "<cmd>Leet run<CR>", { desc = "Run Leetcode Testcase" })
    vim.keymap.set("n", "<leader>lc", "<cmd>Leet console<CR>", { desc = "Open Leetcode console" })
    vim.keymap.set("n", "<leader>ls", "<cmd>Leet submit<CR>", { desc = "Submit Leetcode answer" })
    vim.keymap.set("n", "<leader>lls", "<cmd>Leet last_submit<CR>", { desc = "Load Leetcode last submit" })

    vim.keymap.set("n", "<leader>lel", function()
      vim.api.nvim_command("Leet list difficulty=easy")
    end, { desc = "Leetcode problem list - easy" })

    vim.keymap.set("n", "<leader>ler", function()
      vim.api.nvim_command("Leet random difficulty=easy")
    end, { desc = "Leetcode random problem - easy" })
  end,
}

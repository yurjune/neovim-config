-- A plugin to practice LeetCode problems inside Neovim.
return {
  "kawre/leetcode.nvim",
  -- build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
  cond = function()
    return vim.g.leetcode
  end,
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    arg = "leet",
    lang = "cpp",
    plugins = {
      non_standalone = false,
    },
    logging = true,
    injector = {
      ["cpp"] = {
        imports = function()
          return { "#include <vector>", "#include <algorithm>", "using namespace std;" }
        end,
      },
    },
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
      provider = "fzf-lua",
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
    local leetcode = require("leetcode")
    local fzf = require("fzf-lua")

    leetcode.setup(opts)

    -- make wordwrap in question window, since leetcode.nvim set nowrap internally
    vim.api.nvim_create_autocmd({ "BufEnter" }, {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "leetcode.nvim" then -- apply on question window only
          vim.opt_local.wrap = true
        end
      end,
    })

    vim.keymap.set("n", "<leader>lt", "<cmd>Leet run<CR>", { desc = "Run Leetcode Testcase" })
    vim.keymap.set("n", "<leader>lc", "<cmd>Leet console<CR>", { desc = "Open Leetcode console" })
    vim.keymap.set("n", "<leader>lS", "<cmd>Leet submit<CR>", { desc = "Submit Leetcode answer" })
    vim.keymap.set("n", "<leader>lL", "<cmd>Leet last_submit<CR>", { desc = "Load Leetcode last submit" })

    vim.keymap.set("n", "<leader>ll", "<cmd>Leet list<CR>", { desc = "Leetcode all problems" })
    vim.keymap.set("n", "<leader>lr", "<cmd>Leet reset<CR>", { desc = "Reset editor" })

    local function make_difficulty_picker(title, difficulties)
      local entries = {}
      local commands = {}

      for _, difficulty in ipairs(difficulties) do
        entries[#entries + 1] = difficulty.name
        commands[difficulty.name] = difficulty.cmd
      end

      fzf.fzf_exec(entries, {
        prompt = title .. "> ",
        winopts = {
          width = 0.3,
          height = 0.4,
          preview = { hidden = true },
        },
        actions = {
          ["default"] = function(selected)
            local command = commands[selected[1]]
            if command then
              vim.cmd(command)
            end
          end,
        },
      })
    end

    vim.keymap.set("n", "<leader>ld", function()
      local difficulties = {
        { name = "all", cmd = "Leet list" },
        { name = "easy", cmd = "Leet list difficulty=easy" },
        { name = "medium", cmd = "Leet list difficulty=medium" },
        { name = "hard", cmd = "Leet list difficulty=hard" },
      }

      make_difficulty_picker("Leetcode select difficulty", difficulties)
    end, { desc = "Leetcode problem list" })
  end,
}

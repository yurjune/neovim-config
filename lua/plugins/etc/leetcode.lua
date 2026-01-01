if not vim.g.leetcode then
  return
end

vim.pack.add({
  "https://github.com/kawre/leetcode.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
})
vim.cmd.packadd("leetcode.nvim")
vim.cmd.packadd("telescope.nvim")
vim.cmd.packadd("plenary.nvim")
vim.cmd.packadd("nui.nvim")

local leetcode = require("leetcode")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config")

leetcode.setup({
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
})

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

local function make_difficulty_picker(title, difficulties)
  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table({
        results = difficulties,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name, -- 사용자 입력에 대한 필터링 기준
          }
        end,
      }),
      layout_config = {
        width = 0.2,
        height = 0.2,
      },
      sorter = conf.values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        -- replace default enter action with custom action
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.api.nvim_command(selection.value.cmd)
          end
        end)
        return true
      end,
    })
    :find() -- trigger picker ui
end

vim.keymap.set("n", "<leader>ll", function()
  local difficulties = {
    { name = "all", cmd = "Leet list" },
    { name = "easy", cmd = "Leet list difficulty=easy" },
    { name = "medium", cmd = "Leet list difficulty=medium" },
    { name = "hard", cmd = "Leet list difficulty=hard" },
  }

  make_difficulty_picker("Leetcode problem list", difficulties)
end, { desc = "Leetcode problem list" })

vim.keymap.set("n", "<leader>lr", function()
  local difficulties = {
    { name = "all", cmd = "Leet random" },
    { name = "easy", cmd = "Leet random difficulty=easy" },
    { name = "medium", cmd = "Leet random difficulty=medium" },
    { name = "hard", cmd = "Leet random difficulty=hard" },
  }

  make_difficulty_picker("Leetcode random problem", difficulties)
end, { desc = "Leetcode random problem" })

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    {
      "nvim-telescope/telescope-frecency.nvim",
      dependencies = { "kkharji/sqlite.lua" },
      version = "^0.9.0",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local layout = require("telescope.actions.layout")
    local sorters = require("telescope.sorters")

    telescope.setup({
      defaults = {
        sorter = sorters.get_fzy_sorter(),
        path_display = { "smart" }, -- 경로 축약 및 최적화
        preview = {
          treesitter = false, -- Treesitter 비활성화로 미리보기 가볍게
          file_size_limit = 1,
        },
        mappings = {
          i = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- quickfix
            ["<C-f>"] = layout.toggle_preview,
          },
          n = {
            ["<C-f>"] = layout.toggle_preview,
          },
        },
      },
      pickers = {
        lsp_references = {
          show_line = false, -- 코드 라인 미리보기 비활성화
          fname_width = 60, -- 파일명 폭 조정
        },
        find_files = {
          previewer = false, -- 특정 파인더에만 preview 비활성화
        },
      },
    })

    -- 확장 로드
    telescope.load_extension("fzf")
    telescope.load_extension("frecency")

    local builtin = require("telescope.builtin")
    local keymap = vim.keymap

    -- f means find
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })

    keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope old files" })
    keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope grep string under cursor" })
    keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume last picker" })
    keymap.set("n", "<leader>fm", builtin.marks, { desc = "Telescope marks" })
    keymap.set("n", "<leader>fc", builtin.git_commits, { desc = "Telescope git commits" })
    keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Telescope treesitter symbols" })

    keymap.set("n", "<leader>fn", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "알림 기록 검색" })
  end,
}

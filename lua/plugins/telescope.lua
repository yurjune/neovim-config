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
        layout_config = {
          -- 검색창을 상단에 배치
          prompt_position = "top",
        },
        -- 검색 방향을 위에서 아래로
        sorting_strategy = "ascending",
        preview = {
          treesitter = false, -- Treesitter 비활성화로 미리보기 가볍게
          file_size_limit = 1,
        },
        mappings = {
          i = {
            ["<C-p>"] = actions.cycle_history_prev, -- 이전 검색어
            ["<C-n>"] = actions.cycle_history_next, -- 다음 검색어
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-f>"] = layout.toggle_preview,
          },
          n = {
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-f>"] = layout.toggle_preview,
            ["?"] = actions.which_key,
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
    telescope.load_extension("fzf") -- 검색 성능 최적화
    telescope.load_extension("frecency") -- 파일 접근 빈도와 최신성을 고려한 랭킹 시스템 적용 (frequency + recency)

    local builtin = require("telescope.builtin")
    local keymap = vim.keymap

    -- f means find
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope grep string under cursor" })
    keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume last picker" })
    keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope old files" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    keymap.set("n", "<leader>fm", builtin.marks, { desc = "Telescope marks" })
    keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Telescope treesitter symbols" })
    keymap.set("n", "<leader>fc", builtin.git_commits, { desc = "Telescope git commits" })

    keymap.set("n", "<leader>fn", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "알림 기록 검색" })
  end,
}

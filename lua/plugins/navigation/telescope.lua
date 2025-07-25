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
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local layout = require("telescope.actions.layout")
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")
    local sorters = require("telescope.sorters")
    local fb_actions = require("telescope._extensions.file_browser.actions")
    local keymap = vim.keymap

    telescope.setup({
      defaults = {
        -- these case options doesn't work if you use fzf extension
        ignore_case = true,
        smart_case = false,

        sorting_strategy = "ascending", -- 검색 방향을 위에서 아래로
        layout_config = {
          prompt_position = "top", -- 검색창을 상단에 배치
        },
        preview = {
          treesitter = false, -- Treesitter 비활성화로 미리보기 가볍게
          file_size_limit = 1,
        },
        path_display = { -- truncate(default), smart, shorten, hidden
          "smart",
        },
        mappings = {
          i = {
            -- Disable normal mode intensionally
            ["<ESC>"] = actions.close,
            -- ["<C-p>"] = actions.cycle_history_prev, -- 이전 검색어
            -- ["<C-n>"] = actions.cycle_history_next, -- 다음 검색어

            ["<C-?>"] = actions.which_key,
            ["<C-b>"] = actions.results_scrolling_up,
            ["<C-f>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-o>"] = layout.toggle_preview,
          },
          n = {
            ["?"] = actions.which_key,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,
            ["X"] = function(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              -- entry에 bufnr이 있는지 확인 (buffer picker에서만 존재)
              if entry and entry.bufnr then
                actions.delete_buffer(prompt_bufnr)
              end
            end,
            ["<C-b>"] = actions.results_scrolling_up,
            ["<C-f>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-o>"] = layout.toggle_preview,
          },
        },
      },
      pickers = {
        lsp_references = {
          show_line = false, -- 코드 라인 미리보기 비활성화
          fname_width = 60, -- 파일명 폭 조정
        },
        buffers = {
          sorter = sorters.new({
            scoring_function = function(_, _, line, _)
              local bufnr = tonumber(line:match("^%s*(%d+)"))
              return bufnr and -bufnr or 0 -- 음수로 만들어서 버퍼 번호 역순 정렬
            end,
          }),
        },
        marks = {
          sorter = sorters.new({
            -- if returns -1, it will be filtered
            -- show only uppercase marks
            scoring_function = function(_, _, line, _)
              local mark = line:match("^%s*([%w'`])")
              if not mark then
                return -1
              end
              if mark:match("[A-Z]") then
                return mark:byte()
              end
              return -1
            end,
          }),
        },
      },
      extensions = {
        fzf = {
          fuzzy = true, -- activate fuzzy matching
          override_generic_sorter = true, -- 기본 정렬 엔진 대체
          override_file_sorter = true, -- 파일 정렬 엔진 대체
          case_mode = "ignore_case",
        },
        frecency = {
          show_scores = true, -- not working now
        },
        file_browser = {
          theme = "ivy",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            ["i"] = {
              ["<C-.>"] = fb_actions.toggle_hidden,
            },
            ["n"] = {
              ["h"] = fb_actions.toggle_hidden,
            },
          },
        },
      },
    })

    -- load extensions
    telescope.load_extension("fzf") -- 검색 성능 최적화
    telescope.load_extension("frecency")
    telescope.load_extension("file_browser")

    -- keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    keymap.set("n", "<D-p>", builtin.find_files, { desc = "Telescope find files" })
    keymap.set("n", "<M-p>", builtin.find_files, { desc = "Telescope find files" })

    keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume last picker" })
    keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "Telescope live grep" })

    keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope grep string under cursor" })
    keymap.set("v", "<leader>fs", function()
      local visual_selection = function()
        vim.cmd('noau normal! "vy"')
        local text = vim.fn.getreg("v")
        vim.fn.setreg("v", {})
        text = string.gsub(text, "\n", "")
        return #text > 0 and text or ""
      end
      builtin.grep_string({ search = visual_selection() })
    end, { desc = "Telescope grep selected" })

    keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope old files" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    keymap.set("n", "<leader>fm", builtin.marks, { desc = "Telescope marks" })

    keymap.set("n", "<leader>fg", builtin.git_status, { desc = "Telescope git status" })
    keymap.set("n", "<leader>fG", builtin.git_bcommits, { desc = "Telescope git file commits" })

    keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    keymap.set("n", "<leader>fc", builtin.commands, { desc = "Telescope commands" })

    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope keywords=TODO<CR>", { desc = "Telescope TODOs only" })
    keymap.set("n", "<leader>fT", "<cmd>TodoTelescope<CR>", { desc = "Telescope all todos" })

    keymap.set("n", "<space>fe", function()
      telescope.extensions.file_browser.file_browser()
    end, { desc = "Telescope file browser" })

    keymap.set("n", "<leader>fn", "<cmd>Telescope notify<CR>", { desc = "Telescope notifications" })
  end,
}

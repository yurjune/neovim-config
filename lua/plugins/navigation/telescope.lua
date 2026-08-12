-- A plugin that provides finders and pickers
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local layout = require("telescope.actions.layout")
    local builtin = require("telescope.builtin")
    local sorters = require("telescope.sorters")
    local keymap = vim.keymap

    telescope.setup({
      defaults = {
        -- these case options doesn't work if you use fzf extension
        ignore_case = true,
        smart_case = false,
        -- Apply to Telescope grep commands that use ripgrep.
        vimgrep_arguments = {
          -- Default ripgrep arguments from Telescope
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          -- Custom arguments
          "--hidden",
        },
        file_ignore_patterns = {
          "^%.git/",
          "node_modules/",
        },
        sorting_strategy = "ascending", -- Search direction: top to down
        layout_config = {
          prompt_position = "top", -- Place search box at the top
          horizontal = {
            preview_width = 0.4,
          },
        },
        preview = {
          treesitter = false, -- Disable Treesitter for lighter preview
        },
        path_display = { -- truncate(default), smart, shorten, hidden
          "smart",
        },
        mappings = {
          i = {
            ["<ESC>"] = actions.close, -- Disable normal mode intensionally
            ["<C-?>"] = actions.which_key,
            ["<C-b>"] = actions.results_scrolling_up,
            ["<C-f>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-o>"] = layout.toggle_preview,
            -- ["<C-p>"] = actions.cycle_history_prev,
            -- ["<C-n>"] = actions.cycle_history_next,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        lsp_references = {
          show_line = false, -- Hide row:col
          fname_width = 60, -- defines the width of the filename section
        },
        buffers = {
          sorter = sorters.new({
            scoring_function = function(_, _, line, _)
              local bufnr = tonumber(line:match("^%s*(%d+)"))
              return bufnr and -bufnr or 0 -- show higher buffer number first
            end,
          }),
        },
      },
      extensions = {
        fzf = {
          fuzzy = true, -- activate fuzzy matching
          case_mode = "ignore_case", -- ignore_case, smart_case, respect_case
        },
      },
    })

    -- load extensions
    pcall(telescope.load_extension, "fzf") -- Optimize search performance

    keymap.set("n", "<leader>fh", builtin.find_files, { desc = "Telescope find files" })

    keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "Telescope live grep" })
    keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope grep word under cursor" })
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

    keymap.set("n", "<leader>fg", builtin.git_status, { desc = "Telescope git status" })
    keymap.set("n", "<leader>fG", builtin.git_bcommits, { desc = "Telescope git file commits" })

    keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume last picker" })
    keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope old files" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    keymap.set("n", "<leader>fm", builtin.marks, { desc = "Telescope marks" })

    keymap.set("n", "<leader>ft", function()
      local keywords = { "TODO", "FIX", "NOTE", "WARN", "HACK" }
      vim.ui.select(keywords, { prompt = "Todo keyword" }, function(keyword)
        if keyword then
          vim.cmd("TodoTelescope keywords=" .. keyword)
        end
      end)
    end, { desc = "Telescope todos by keyword" })
    keymap.set("n", "<leader>fT", "<cmd>TodoTelescope<CR>", { desc = "Telescope all todos" })

    keymap.set("n", "<leader>fc", builtin.commands, { desc = "Telescope commands" })
    keymap.set("n", "<leader>fn", "<cmd>Telescope notify<CR>", { desc = "Telescope notifications" })
  end,
}

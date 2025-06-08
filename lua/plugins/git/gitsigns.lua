-- A plugin to manage git changes in editor
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = true, -- show blame info on current line
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      virt_text_priority = 100,
      delay = 300,
      ignore_whitespace = false,
      use_focus = true,
    },
    current_line_blame_formatter = "  <author>, <author_time:%R> - <summary>",
    preview_config = {
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },

    signs = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "__" },
      topdelete = { text = "‾‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    signs_staged = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "__" },
      topdelete = { text = "‾‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },

    on_attach = function(bufnr)
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      local gs = package.loaded.gitsigns

      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")

      map("n", "<leader>hs", function()
        gs.stage_hunk()
        vim.notify("Hunk staged", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Stage hunk")

      map("n", "<leader>hr", function()
        gs.reset_hunk()
        vim.notify("Hunk reset", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Reset hunk")

      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        vim.notify("Hunk staged", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Stage hunk")

      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        vim.notify("Hunk reset", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Reset hunk")

      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>ht", gs.toggle_current_line_blame, "Toggle blame")

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
    end,
  },
}

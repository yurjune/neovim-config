-- A plugin to manage git changes in editor
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>gb", "<cmd>Gitsigns blame<CR>", desc = "Git blame" },
  },
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
    blame_formatter = function(_, info, context)
      -- Truncate by display width so wide characters such as Hangul don't overflow.
      local function truncate(text, width)
        if vim.fn.strdisplaywidth(text) <= width then
          return text
        end
        repeat
          text = vim.fn.strcharpart(text, 0, vim.fn.strchars(text) - 1)
        until vim.fn.strdisplaywidth(text) < width
        return text .. "…"
      end

      local is_uncommitted = info.abbrev_sha == "00000000"
      local hash_hl_group = is_uncommitted and "Comment" or context.hash_hl_group
      -- Pad by display width so dates align even when author names contain wide characters.
      local author_padding = context.max_author_width - vim.fn.strdisplaywidth(info.author) + 1
      local summary = truncate(info.summary, 36)

      local chunks = {
        { info.abbrev_sha .. " ", hash_hl_group },
        { info.author .. string.rep(" ", author_padding) },
        { os.date("%y/%m/%d %H:%M", info.author_time), hash_hl_group },
        -- Uncommitted lines have a placeholder summary rather than a real message.
        { is_uncommitted and "" or "  " .. summary },
      }

      return chunks, false -- keep summaries inline instead of adding virtual lines
    end,
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

      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame line")

      map("n", "<leader>hs", function()
        gs.stage_hunk()
        vim.notify("Hunk staged", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Stage hunk")

      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        vim.notify("Hunk staged", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Stage hunk")

      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")

      map("n", "<leader>hr", function()
        gs.reset_hunk()
        vim.notify("Hunk reset", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Reset hunk")

      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        vim.notify("Hunk reset", vim.log.levels.INFO, { title = "Gitsigns" })
      end, "Reset hunk")

      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

      map("n", "<leader>ht", gs.toggle_current_line_blame, "Toggle blame")

      -- Text object
      -- ex) dih: delete inner hunk
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
    end,
  },
}

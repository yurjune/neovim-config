return {
  "hat0uma/csvview.nvim",
  config = function()
    require("csvview").setup({
      parser = { comments = { "#", "//" } },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "csv",
      callback = function()
        vim.cmd("CsvViewEnable")

        vim.keymap.set("n", "gX", function()
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2] + 1

          -- Split line by commas and find which column the cursor is in
          local start_pos = 1
          for field in line:gmatch("([^,]*),?") do
            local end_pos = start_pos + #field
            if col >= start_pos and col <= end_pos then
              local url = field:gsub("^%s+", ""):gsub("%s+$", "")
              if url:match("^https?://") then
                vim.ui.open(url)
                return
              end
              break
            end
            start_pos = end_pos + 1
          end
        end, { desc = "Open link under cursor in CSV" })
      end,
    })
  end,
}

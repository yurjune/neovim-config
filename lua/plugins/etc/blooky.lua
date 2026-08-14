return {
  "atiladefreitas/bloocky",
  config = function()
    require("bloocky").setup({
      -- Where time blocks are persisted
      save_path = vim.fn.stdpath("data") .. "/bloocky_blocks.json",

      -- View shown when the calendar opens: "day" | "week" | "month"
      default_view = "month",

      -- Visible hour range in the day and week views
      hours = {
        start = 8,
        ["end"] = 19, -- last hour shown (22:00)
      },

      granularity = 30,
      window = {
        mode = "float", -- "float" | "sidebar"
        width = {
          month = 0.8,
          week = 0.6,
          day = 46,
        },
        height = "auto",
      },

      integrations = {
        dooing = {
          enabled = true, -- show Dooing todos on their due date
          show_done = false, -- also show completed todos
        },
      },

      keymaps = {
        toggle = "<leader>tb",
      },
    })
  end,
}

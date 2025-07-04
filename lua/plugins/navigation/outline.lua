return {
  "hedyhli/outline.nvim",
  config = function()
    vim.keymap.set("n", "<leader>oo", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

    require("outline").setup({
      outline_window = {
        width = 15,
        -- Automatically scroll to the location in code when navigating outline window.
        auto_jump = false,
        jump_highlight_duration = 1000,
      },
      symbol_folding = {
        -- Depth past which nodes will be folded by default. Set to false to unfold all on open.
        autofold_depth = false,
        auto_unfold = {
          hovered = true,
        },
      },
      keymaps = {
        -- Jump to symbol under cursor.
        -- goto_location = "<Tab>",
        -- Jump to symbol under cursor but keep focus on outline window.
        peek_location = "<Tab>",
        fold_toggle = "<Nop>",
      },
    })
  end,
}
